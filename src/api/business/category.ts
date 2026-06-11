import request from '@/utils/request'
import type { AjaxResult, TableDataInfo, DishCategory, CategoryQueryParams } from '@/types'

export function listCategory(query: CategoryQueryParams): Promise<TableDataInfo<DishCategory>> {
  return request({
    url: '/business/category/list',
    method: 'get',
    params: query
  })
}

export function getCategory(categoryId: number): Promise<AjaxResult<DishCategory>> {
  return request({
    url: '/business/category/' + categoryId,
    method: 'get'
  })
}

export function addCategory(data: DishCategory): Promise<AjaxResult> {
  return request({
    url: '/business/category',
    method: 'post',
    data: data
  })
}

export function updateCategory(data: DishCategory): Promise<AjaxResult> {
  return request({
    url: '/business/category',
    method: 'put',
    data: data
  })
}

export function delCategory(categoryId: number | number[]): Promise<AjaxResult> {
  return request({
    url: '/business/category/' + categoryId,
    method: 'delete'
  })
}

export function optionselectCategory(): Promise<AjaxResult<DishCategory[]>> {
  return request({
    url: '/business/category/optionselect',
    method: 'get'
  })
}
