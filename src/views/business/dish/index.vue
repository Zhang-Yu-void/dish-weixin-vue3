<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="菜品名称" prop="dishName">
        <el-input
          v-model="queryParams.dishName"
          placeholder="请输入菜品名称"
          clearable
          style="width: 200px"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="分类" prop="categoryId">
        <el-select v-model="queryParams.categoryId" placeholder="请选择分类" clearable style="width: 200px">
          <el-option
            v-for="item in categoryOptions"
            :key="item.categoryId"
            :label="item.categoryName"
            :value="item.categoryId"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="菜品状态" clearable style="width: 200px">
          <el-option v-for="dict in dish_shelf_status" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['business:dish:add']"
          >新增</el-button
        >
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="() => handleUpdate()"
          v-hasPermi="['business:dish:edit']"
          >修改</el-button
        >
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="() => handleDelete()"
          v-hasPermi="['business:dish:remove']"
          >删除</el-button
        >
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="dishList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="菜品编号" align="center" prop="dishId" width="90" />
      <el-table-column label="图片" align="center" prop="image" width="80">
        <template #default="scope">
          <image-preview :src="scope.row.image" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="菜品名称" align="center" prop="dishName" :show-overflow-tooltip="true" />
      <el-table-column label="分类" align="center" prop="categoryName" width="120" />
      <el-table-column label="价格" align="center" prop="price" width="100">
        <template #default="scope">
          <span>￥{{ scope.row.price }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template #default="scope">
          <dict-tag :options="dish_shelf_status" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="排序" align="center" prop="sortOrder" width="80" />
      <el-table-column label="操作" align="center" width="180" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button
            link
            type="primary"
            icon="Edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['business:dish:edit']"
            >修改</el-button
          >
          <el-button
            link
            type="primary"
            icon="Delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['business:dish:remove']"
            >删除</el-button
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

    <el-dialog :title="title" v-model="open" width="600px" append-to-body>
      <el-form ref="dishRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="菜品名称" prop="dishName">
          <el-input v-model="form.dishName" placeholder="请输入菜品名称" />
        </el-form-item>
        <el-form-item label="分类" prop="categoryId">
          <el-select v-model="form.categoryId" placeholder="请选择分类" style="width: 100%">
            <el-option
              v-for="item in categoryOptions"
              :key="item.categoryId"
              :label="item.categoryName"
              :value="item.categoryId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="价格" prop="price">
          <el-input-number v-model="form.price" :precision="2" :min="0" :step="1" controls-position="right" />
        </el-form-item>
        <el-form-item label="菜品图片" prop="image">
          <image-upload v-model="form.image" :limit="1" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入菜品描述" />
        </el-form-item>
        <el-form-item label="显示排序" prop="sortOrder">
          <el-input-number v-model="form.sortOrder" controls-position="right" :min="0" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio v-for="dict in dish_shelf_status" :key="dict.value" :value="dict.value">{{
              dict.label
            }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts" name="Dish">
import { listDish, getDish, delDish, addDish, updateDish } from '@/api/business/dish'
import { optionselectCategory } from '@/api/business/category'
import type { Dish, DishQueryParams } from '@/types/api/business/dish'
import type { DishCategory } from '@/types/api/business/category'

const proxy = useProxy()
const { dish_shelf_status } = proxy.useDict('dish_shelf_status')

const dishList = ref<Dish[]>([])
const categoryOptions = ref<DishCategory[]>([])
const open = ref<boolean>(false)
const loading = ref<boolean>(true)
const showSearch = ref<boolean>(true)
const ids = ref<number[]>([])
const single = ref<boolean>(true)
const multiple = ref<boolean>(true)
const total = ref<number>(0)
const title = ref<string>('')

const data = reactive({
  form: {} as Dish,
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    dishName: undefined,
    categoryId: undefined,
    status: undefined
  } as DishQueryParams,
  rules: {
    dishName: [{ required: true, message: '菜品名称不能为空', trigger: 'blur' }],
    categoryId: [{ required: true, message: '分类不能为空', trigger: 'change' }],
    price: [{ required: true, message: '价格不能为空', trigger: 'blur' }]
  }
})

const { queryParams, form, rules } = toRefs(data)

function getCategoryOptions() {
  optionselectCategory().then((response) => {
    categoryOptions.value = response.data || []
  })
}

function getList() {
  loading.value = true
  listDish(queryParams.value).then((response) => {
    dishList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  form.value = {
    dishId: undefined,
    categoryId: undefined,
    dishName: undefined,
    price: 0,
    image: undefined,
    description: undefined,
    sortOrder: 0,
    status: '0',
    remark: undefined
  }
  proxy.resetForm('dishRef')
}

function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

function resetQuery() {
  proxy.resetForm('queryRef')
  handleQuery()
}

function handleSelectionChange(selection: Dish[]) {
  ids.value = selection.map((item) => item.dishId!)
  single.value = selection.length != 1
  multiple.value = !selection.length
}

function handleAdd() {
  reset()
  open.value = true
  title.value = '添加菜品'
}

function handleUpdate(row?: Dish) {
  reset()
  const dishId = row?.dishId || ids.value[0]
  getDish(dishId).then((response) => {
    form.value = response.data!
    open.value = true
    title.value = '修改菜品'
  })
}

function submitForm() {
  proxy.$refs['dishRef'].validate((valid: boolean) => {
    if (valid) {
      if (form.value.dishId != undefined) {
        updateDish(form.value).then(() => {
          proxy.$modal.msgSuccess('修改成功')
          open.value = false
          getList()
        })
      } else {
        addDish(form.value).then(() => {
          proxy.$modal.msgSuccess('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleDelete(row?: Dish) {
  const dishIds = row?.dishId || ids.value
  proxy.$modal
    .confirm('是否确认删除菜品编号为"' + dishIds + '"的数据项？')
    .then(function () {
      return delDish(dishIds)
    })
    .then(() => {
      getList()
      proxy.$modal.msgSuccess('删除成功')
    })
    .catch(() => {})
}

getCategoryOptions()
getList()
</script>
