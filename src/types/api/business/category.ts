import type { BaseEntity, PageDomain } from '../common'

export interface DishCategory extends BaseEntity {
  categoryId?: number
  categoryName?: string
  sortOrder?: number
  status?: string
}

export interface CategoryQueryParams extends PageDomain {
  categoryName?: string
  status?: string
}
