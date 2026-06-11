import request from '@/utils/request'
import type { AjaxResult, TableDataInfo, DishOrder, DishOrderStats, OrderQueryParams } from '@/types'

export function listOrder(query: OrderQueryParams): Promise<TableDataInfo<DishOrder>> {
  return request({
    url: '/business/order/list',
    method: 'get',
    params: query
  })
}

export function getOrder(orderId: number): Promise<AjaxResult<DishOrder>> {
  return request({
    url: '/business/order/' + orderId,
    method: 'get'
  })
}

export function getOrderStats(): Promise<AjaxResult<DishOrderStats>> {
  return request({
    url: '/business/order/stats',
    method: 'get'
  })
}

export function updateOrderStatus(data: { orderId: number; status: string }): Promise<AjaxResult> {
  return request({
    url: '/business/order/status',
    method: 'put',
    data: data
  })
}
