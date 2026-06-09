import autoImport from 'unplugin-auto-import/vite'

export default function createAutoImport() {
  return autoImport({
    imports: [
      'vue',
      'vue-router',
      'pinia',
      {
        '@/utils/useProxy': ['useProxy']
      }
    ],
    eslintrc: {
      enabled: true,
      filepath: './.eslintrc-auto-import.json',
      globalsPropValue: true
    },
    // Docker 里 COPY 常为 root 属主，非 root 构建用户无法覆盖此文件 → EACCES。
    // 生产构建不依赖重写 dts（仓库已含 auto-imports.d.ts）。
    dts: process.env.DOCKER_BUILD !== '1'
  })
}
