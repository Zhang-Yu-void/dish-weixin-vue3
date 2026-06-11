<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="订单编号" prop="orderNo">
        <el-input
          v-model="queryParams.orderNo"
          placeholder="请输入订单编号"
          clearable
          style="width: 200px"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="联系电话" prop="contactPhone">
        <el-input
          v-model="queryParams.contactPhone"
          placeholder="请输入联系电话"
          clearable
          style="width: 200px"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="订单状态" clearable style="width: 200px">
          <el-option v-for="dict in dish_order_status" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="下单时间" style="width: 308px">
        <el-date-picker
          v-model="dateRange"
          value-format="YYYY-MM-DD"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="orderList">
      <el-table-column label="订单编号" align="center" prop="orderNo" min-width="180" :show-overflow-tooltip="true" />
      <el-table-column label="联系人" align="center" prop="contactName" />
      <el-table-column label="联系电话" align="center" prop="contactPhone" />
      <el-table-column label="就餐方式" align="center" prop="diningType">
        <template #default="scope">
          <dict-tag :options="dish_dining_type" :value="scope.row.diningType" />
        </template>
      </el-table-column>
      <el-table-column label="桌号" align="center" prop="tableNo" />
      <el-table-column label="金额" align="center" prop="totalAmount">
        <template #default="scope">
          <span>￥{{ scope.row.totalAmount }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <dict-tag :options="dish_order_status" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="下单时间" align="center" prop="createTime" min-width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="220" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button
            link
            type="primary"
            icon="View"
            @click="handleDetail(scope.row)"
            v-hasPermi="['business:order:query']"
            >详情</el-button
          >
          <el-button
            v-if="scope.row.status === '0'"
            link
            type="primary"
            @click="handleStatus(scope.row, '1')"
            v-hasPermi="['business:order:edit']"
            >开始制作</el-button
          >
          <el-button
            v-if="scope.row.status === '1'"
            link
            type="success"
            @click="handleStatus(scope.row, '2')"
            v-hasPermi="['business:order:edit']"
            >完成</el-button
          >
          <el-button
            v-if="scope.row.status === '0' || scope.row.status === '1'"
            link
            type="danger"
            @click="handleStatus(scope.row, '3')"
            v-hasPermi="['business:order:edit']"
            >取消</el-button
          >
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />

    <el-drawer v-model="detailOpen" title="订单详情" size="480px" append-to-body>
      <el-descriptions :column="1" border v-if="detail">
        <el-descriptions-item label="订单编号">{{ detail.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="联系人">{{ detail.contactName }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ detail.contactPhone }}</el-descriptions-item>
        <el-descriptions-item label="就餐方式">
          <dict-tag :options="dish_dining_type" :value="detail.diningType" />
        </el-descriptions-item>
        <el-descriptions-item label="桌号">{{ detail.tableNo || '-' }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ detail.remark || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <dict-tag :options="dish_order_status" :value="detail.status" />
        </el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ parseTime(detail.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="合计金额">￥{{ detail.totalAmount }}</el-descriptions-item>
      </el-descriptions>
      <el-table :data="detail?.items || []" style="margin-top: 16px">
        <el-table-column label="菜品" prop="dishName" />
        <el-table-column label="单价" prop="price" width="80">
          <template #default="scope">￥{{ scope.row.price }}</template>
        </el-table-column>
        <el-table-column label="数量" prop="quantity" width="60" />
        <el-table-column label="小计" prop="subtotal" width="80">
          <template #default="scope">￥{{ scope.row.subtotal }}</template>
        </el-table-column>
      </el-table>
    </el-drawer>
  </div>
</template>

<script setup lang="ts" name="Order">
import { listOrder, getOrder, updateOrderStatus } from '@/api/business/order'
import type { DishOrder, OrderQueryParams } from '@/types/api/business/order'

const proxy = useProxy()
const { dish_order_status, dish_dining_type } = proxy.useDict('dish_order_status', 'dish_dining_type')

const orderList = ref<DishOrder[]>([])
const loading = ref<boolean>(true)
const showSearch = ref<boolean>(true)
const total = ref<number>(0)
const dateRange = ref<string[]>([])
const detailOpen = ref<boolean>(false)
const detail = ref<DishOrder | null>(null)

const data = reactive({
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    orderNo: undefined,
    contactPhone: undefined,
    status: undefined
  } as OrderQueryParams
})

const { queryParams } = toRefs(data)

function getList() {
  loading.value = true
  const params = { ...queryParams.value }
  params.params = {
    beginTime: dateRange.value?.[0],
    endTime: dateRange.value?.[1]
  }
  listOrder(params).then((response) => {
    orderList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

function resetQuery() {
  dateRange.value = []
  proxy.resetForm('queryRef')
  handleQuery()
}

function handleDetail(row: DishOrder) {
  getOrder(row.orderId!).then((response) => {
    detail.value = response.data!
    detailOpen.value = true
  })
}

function handleStatus(row: DishOrder, status: string) {
  const statusLabel = dish_order_status.value.find((d: { value: string }) => d.value === status)?.label || ''
  proxy.$modal
    .confirm('确认将订单"' + row.orderNo + '"状态改为"' + statusLabel + '"？')
    .then(() => {
      return updateOrderStatus({ orderId: row.orderId!, status })
    })
    .then(() => {
      proxy.$modal.msgSuccess('操作成功')
      getList()
    })
    .catch(() => {})
}

getList()
</script>
