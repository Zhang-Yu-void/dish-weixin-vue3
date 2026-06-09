/** Redis 缓存监控信息 */
export interface CacheMonitorInfo {
  redis_version?: string
  redis_mode?: string
  tcp_port?: string
  connected_clients?: string
  uptime_in_days?: string
  used_memory_human?: string
  used_cpu_user_children?: string
  maxmemory_human?: string
  aof_enabled?: string
  rdb_last_bgsave_status?: string
  instantaneous_input_kbps?: string
  instantaneous_output_kbps?: string
  [key: string]: string | undefined
}

/** 缓存监控数据 */
export interface CacheMonitorData {
  info: CacheMonitorInfo
  dbSize: number
  commandStats: { name: string; value: string }[]
}

/** 缓存信息 */
export interface SysCache {
  /** 缓存名称 */
  cacheName?: string
  /** 缓存键名 */
  cacheKey?: string
  /** 缓存内容 */
  cacheValue?: string
  /** 备注 */
  remark?: string
}
