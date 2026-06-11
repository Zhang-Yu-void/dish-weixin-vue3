import type { BaseEntity, PageDomain } from '../common'

export interface Dish extends BaseEntity {
  dishId?: number
  categoryId?: number
  categoryName?: string
  dishName?: string
  price?: number
  image?: string
  description?: string
  status?: string
  sortOrder?: number
}

export interface DishQueryParams extends PageDomain {
  dishName?: string
  categoryId?: number
  status?: string
}
