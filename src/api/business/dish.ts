import request from '@/utils/request'
import type { AjaxResult, TableDataInfo, Dish, DishQueryParams } from '@/types'

export function listDish(query: DishQueryParams): Promise<TableDataInfo<Dish>> {
  return request({
    url: '/business/dish/list',
    method: 'get',
    params: query
  })
}

export function getDish(dishId: number): Promise<AjaxResult<Dish>> {
  return request({
    url: '/business/dish/' + dishId,
    method: 'get'
  })
}

export function addDish(data: Dish): Promise<AjaxResult> {
  return request({
    url: '/business/dish',
    method: 'post',
    data: data
  })
}

export function updateDish(data: Dish): Promise<AjaxResult> {
  return request({
    url: '/business/dish',
    method: 'put',
    data: data
  })
}

export function delDish(dishId: number | number[]): Promise<AjaxResult> {
  return request({
    url: '/business/dish/' + dishId,
    method: 'delete'
  })
}
