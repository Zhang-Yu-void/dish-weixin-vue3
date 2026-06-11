<template>
  <div class="app-container home">
    <el-row :gutter="20">
      <el-col :span="24">
        <h2>点餐小程序后台管理</h2>
        <p class="desc">管理菜品分类、菜品信息及顾客订单，顾客下单后将自动发送邮件通知。</p>
      </el-col>
    </el-row>
    <el-row :gutter="20" class="stats-row">
      <el-col :xs="24" :sm="12">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">{{ stats.todayCount }}</div>
            <div class="stat-label">今日订单</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12">
        <el-card shadow="hover">
          <div class="stat-item pending">
            <div class="stat-value">{{ stats.pendingCount }}</div>
            <div class="stat-label">待处理订单</div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    <el-divider />
    <el-row :gutter="20">
      <el-col :span="24">
        <h4>快捷入口</h4>
        <div class="quick-links">
          <el-button type="primary" plain @click="goTo('/business/category')">分类管理</el-button>
          <el-button type="primary" plain @click="goTo('/business/dish')">菜品管理</el-button>
          <el-button type="primary" plain @click="goTo('/business/order')">订单管理</el-button>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts" name="Index">
import { getOrderStats } from '@/api/business/order'
import type { DishOrderStats } from '@/types/api/business/order'

const router = useRouter()

const stats = ref<DishOrderStats>({
  todayCount: 0,
  pendingCount: 0
})

function loadStats() {
  getOrderStats()
    .then((res) => {
      if (res.data) {
        stats.value = res.data
      }
    })
    .catch(() => {})
}

function goTo(path: string) {
  router.push(path)
}

loadStats()
</script>

<style scoped lang="scss">
.home {
  .desc {
    color: #606266;
    margin-top: 8px;
  }

  .stats-row {
    margin-top: 20px;
  }

  .stat-item {
    text-align: center;
    padding: 20px 0;

    .stat-value {
      font-size: 36px;
      font-weight: bold;
      color: #409eff;
    }

    &.pending .stat-value {
      color: #e6a23c;
    }

    .stat-label {
      margin-top: 8px;
      color: #909399;
      font-size: 14px;
    }
  }

  .quick-links {
    margin-top: 12px;
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
  }
}
</style>
