import { defineConfig, loadEnv } from 'vite'
import path from 'path'
import { VitePWA } from 'vite-plugin-pwa'
import createVitePlugins from './vite/plugins'

// https://vitejs.dev/config/
export default defineConfig(({ mode, command }) => {
  const env = loadEnv(mode, process.cwd())
  const { VITE_APP_ENV, VITE_PROXY_TARGET } = env
  const proxyTarget = VITE_PROXY_TARGET || 'http://localhost:8080' // 后端接口
  return {
    // 部署生产环境和开发环境下的URL。
    // 默认情况下，vite 会假设你的应用是被部署在一个域名的根路径上
    // 例如 https://www.ruoyi.vip/。如果应用被部署在一个子路径上，你就需要用这个选项指定这个子路径。例如，如果你的应用被部署在 https://www.ruoyi.vip/admin/，则设置 baseUrl 为 /admin/。
    base: VITE_APP_ENV === 'production' ? '/' : '/',
    plugins: [
      createVitePlugins(env, command === 'build'),
      VitePWA({
        manifestFilename: 'manifest.json',
        injectRegister: 'auto',
        registerType: 'autoUpdate',
        devOptions: {
          enabled: true
        },
        workbox: {
          // 不预缓存 index.html，避免 SW 覆盖 nginx 的不缓存策略，发版后更易加载新入口
          globPatterns: ['**/*.{js,css,ico,png,svg}'],
          // index.html 不在预缓存中时，必须关闭导航回退，否则报 non-precached-url
          navigateFallback: null,
          maximumFileSizeToCacheInBytes: 10 * 1024 * 1024
        },
        includeAssets: ['favicon.ico'],
        manifest: {
          id: '/',
          name: '点餐小程序',
          short_name: '点餐',
          theme_color: '#373737',
          start_url: '/',
          scope: '/',
          display: 'standalone',
          background_color: '#373737',
          icons: [
            {
              src: '/favicon.ico',
              sizes: '48x48',
              type: 'image/x-icon',
              purpose: 'any'
            }
          ]
        }
      })
    ],
    resolve: {
      // https://cn.vitejs.dev/config/#resolve-alias
      alias: {
        // 设置路径
        '~': path.resolve(__dirname, './'),
        // 设置别名
        '@': path.resolve(__dirname, './src')
      },
      // https://cn.vitejs.dev/config/#resolve-extensions
      extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json', '.vue']
    },
    // 打包配置
    build: {
      // https://vite.dev/config/build-options.html
      sourcemap: command === 'build' ? false : 'inline',
      outDir: 'dist',
      assetsDir: 'assets',
      chunkSizeWarningLimit: 2000,
      rollupOptions: {
        output: {
          chunkFileNames: 'static/js/[name]-[hash].js',
          entryFileNames: 'static/js/[name]-[hash].js',
          assetFileNames: 'static/[ext]/[name]-[hash].[ext]'
        }
      }
    },
    // vite 相关配置
    server: {
      port: 80,
      host: true,
      open: true,
      proxy: {
        // https://cn.vitejs.dev/config/#server-proxy
        '/dev-api': {
          target: proxyTarget,
          changeOrigin: true,
          rewrite: (p) => p.replace(/^\/dev-api/, '')
        },
        '/stage-api': {
          target: proxyTarget,
          changeOrigin: true,
          rewrite: (p) => p.replace(/^\/stage-api/, '')
        },
        '/prod-api': {
          target: proxyTarget,
          changeOrigin: true,
          rewrite: (p) => p.replace(/^\/prod-api/, '')
        },
        // springdoc proxy
        '^/v3/api-docs/(.*)': {
          target: proxyTarget,
          changeOrigin: true
        }
      }
    },
    css: {
      postcss: {
        plugins: [
          {
            postcssPlugin: 'internal:charset-removal',
            AtRule: {
              charset: (atRule: any) => {
                if (atRule.name === 'charset') {
                  atRule.remove()
                }
              }
            }
          }
        ]
      }
    }
  }
})
