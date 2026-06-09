export interface DrawingElement {
  layout?: 'colFormItem' | 'rowFormItem'
  span?: number
  label?: string
  labelWidth?: number | null
  required?: boolean
  tag?: string
  tagIcon?: string
  document?: string
  formId: string | number
  defaultValue?: unknown
  gutter?: number
  justify?: string
  align?: string
  class?: string
  componentName?: string
  children?: DrawingElement[]
  renderKey?: string | number
  vModel?: string
  placeholder?: string
  [key: string]: unknown
}

export interface FormConf {
  formRef?: string
  formModel?: string
  size?: 'default' | 'small' | 'large' | ''
  labelPosition?: 'right' | 'left' | 'top'
  labelWidth?: number
  formRules?: string
  gutter?: number
  disabled?: boolean
  span?: number
  formBtns?: boolean
  unFocusedComponentBorder?: boolean
  [key: string]: unknown
}

export interface FormGenerateData extends FormConf {
  fields: DrawingElement[]
}
