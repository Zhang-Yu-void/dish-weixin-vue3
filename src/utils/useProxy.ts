import { getCurrentInstance, type ComponentPublicInstance } from 'vue'

export type AppProxy = ComponentPublicInstance & {
  $refs: Record<string, any>
  idGlobal?: number
}

/**
 * 在 script setup 中访问挂载在 globalProperties 上的若依全局方法。
 * 替代 getCurrentInstance().proxy，避免 null 与类型缺失问题。
 */
export function useProxy(): AppProxy {
  const instance = getCurrentInstance()
  if (!instance?.proxy) {
    throw new Error('useProxy() must be called in setup().')
  }
  return instance.proxy as AppProxy
}
