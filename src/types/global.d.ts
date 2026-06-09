/** Vue 类型增强：文件必须是 module，否则会覆盖整个 vue 模块 */
export {}

declare module 'vue' {
  interface ComponentCustomProperties {
    useDict: typeof import('@/utils/dict').useDict
    download: typeof import('@/utils/request').download
    parseTime: typeof import('@/utils/ruoyi').parseTime
    resetForm: typeof import('@/utils/ruoyi').resetForm
    handleTree: typeof import('@/utils/ruoyi').handleTree
    addDateRange: typeof import('@/utils/ruoyi').addDateRange
    getConfigKey: typeof import('@/api/system/config').getConfigKey
    selectDictLabel: typeof import('@/utils/ruoyi').selectDictLabel
    selectDictLabels: typeof import('@/utils/ruoyi').selectDictLabels
    $modal: typeof import('@/plugins/modal').default
    $tab: typeof import('@/plugins/tab').default
    $auth: typeof import('@/plugins/auth').default
    $cache: typeof import('@/plugins/cache').default
    $download: typeof import('@/plugins/download').default
  }
}
