# Frontend deployment (dish-weixin-vue3)

Production uses **direct deployment**: host Nginx on **:8080** serves static files and proxies `/prod-api/*` to Spring Boot on **:8082**.

## Ports

| Service                           | Port |
| --------------------------------- | ---- |
| Nginx (frontend)                  | 8080 |
| Spring Boot (backend, other repo) | 8082 |

## Local build + remote deploy (recommended)

Build on Mac, upload `dist/` to server (server does not need Node):

```bash
# Set SSH_HOST=aliyun in .env.prod (or root@8.141.20.44)
bash deploy/local/build.sh              # build dist only
bash deploy/local/deploy-remote.sh      # upload dist + reload Nginx
```

## Server deploy (build on server)

```bash
cd /opt/ruoyi/dish-weixin-vue3
bash deploy/direct/install-deps.sh          # first time: Node + Nginx
bash deploy/direct/run-on-server.sh         # build + sync + nginx reload
bash deploy/scripts/verify-e2e.sh           # verify static + proxy
```

## First-time bootstrap

```bash
export RUOYI_HOME=$HOME/ruoyi
bash deploy/direct/bootstrap-server.sh
cd $RUOYI_HOME/dish-weixin-vue3
bash deploy/direct/run-on-server.sh
```

## Migrate from Docker

If `vue-front-app` container is still running:

```bash
bash deploy/direct/migrate-from-docker.sh
```

## Local development

Backend runs on `:8082`. Set in `.env.development`:

```
VITE_PROXY_TARGET=http://localhost:8082
```

```bash
# terminal 1: backend (dish-weixin-springboot3)
export SERVER_PORT=8082 SPRING_PROFILES_ACTIVE=dev
mvn spring-boot:run -pl ruoyi-admin

# terminal 2: frontend
pnpm run dev
```

## Nginx template

[deploy/nginx/ruoyi.conf](nginx/ruoyi.conf)
