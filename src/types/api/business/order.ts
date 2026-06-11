import type { BaseEntity, PageDomain } from '../common'

export interface DishOrderItem {
  itemId?: number
  orderId?: number
  dishId?: number
  dishName?: string
  price?: number
  quantity?: number
  subtotal?: number
}

export interface DishOrder extends BaseEntity {
  orderId?: number
  orderNo?: string
  contactName?: string
  contactPhone?: string
  diningType?: string
  tableNo?: string
  totalAmount?: number
  status?: string
  createTime?: string
  items?: DishOrderItem[]
}

export interface OrderQueryParams extends PageDomain {
  orderNo?: string
  contactPhone?: string
  status?: string
  params?: {
    beginTime?: string
    endTime?: string
  }
}

export interface DishOrderStats {
  todayCount: number
  pendingCount: number
}

export interface OrderSubmitRequest {
  contactName: string
  contactPhone: string
  diningType: string
  tableNo?: string
  remark?: string
  items: { dishId: number; quantity: number }[]
}
