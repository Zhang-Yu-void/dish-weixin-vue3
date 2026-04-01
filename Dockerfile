# 用法说明（本地构建并推送到阿里云镜像仓库）
# 1) 登录仓库
# docker login --username=zhang2600 crpi-xuhg3aumkquvtuvn.cn-beijing.personal.cr.aliyuncs.com
#
# 2) 变量（按需修改）
# REGISTRY=crpi-xuhg3aumkquvtuvn-vpc.cn-beijing.personal.cr.aliyuncs.com
# NAMESPACE=acs
# IMAGE=agent
#
# 3) 手动指定 tag（示例）
# TAG=1.2.3
# docker build --build-arg APP_VERSION=${TAG} -t ${REGISTRY}/${NAMESPACE}/${IMAGE}:${TAG} .
# docker push ${REGISTRY}/${NAMESPACE}/${IMAGE}:${TAG}
#
# 4) 自动递增 tag（默认从 1.0.0 开始，每次 +0.0.1，十进制）
# LAST_TAG_FILE=.docker_last_tag
# LAST_TAG=$( [ -f "${LAST_TAG_FILE}" ] && cat "${LAST_TAG_FILE}" || echo "0.9.9" )
# TAG=$(echo "${LAST_TAG}" | awk -F. '{ printf "%d.%d.%d", $1, $2, $3+1 }')
# echo "${TAG}" > "${LAST_TAG_FILE}"
# docker build --build-arg APP_VERSION=${TAG} -t ${REGISTRY}/${NAMESPACE}/${IMAGE}:${TAG} .
# docker push ${REGISTRY}/${NAMESPACE}/${IMAGE}:${TAG}

# ===================== 第一阶段：构建阶段 =====================
# 默认从北京 ACR 拉取（构建阶段 node 来自 alinux3/node:20.16 同步的 hardo/node-20）；需其他源可覆盖：
# docker build --build-arg NODE_IMAGE=node:20-alpine --build-arg NGINX_IMAGE=nginx:alpine ...
# 构建前请 docker login crpi-xuhg3aumkquvtuvn.cn-beijing.personal.cr.aliyuncs.com
ARG NODE_IMAGE=crpi-xuhg3aumkquvtuvn.cn-beijing.personal.cr.aliyuncs.com/hardo/node-20:latest
ARG NGINX_IMAGE=crpi-xuhg3aumkquvtuvn.cn-beijing.personal.cr.aliyuncs.com/hardo/nginx-latest:latest
FROM ${NODE_IMAGE} AS builder
# 与 vite/plugins/auto-import.ts 配合：跳过重写 auto-imports.d.ts，避免非 root 用户对 root 属主文件 EACCES
ENV DOCKER_BUILD=1
# 设置工作目录
WORKDIR /build
# 配置淘宝npm镜像源（加速依赖安装）
RUN npm config set registry https://registry.npmmirror.com/
# 复制依赖文件
COPY package*.json ./
# 安装依赖
RUN npm install
# 复制项目代码
COPY . .
# 打包Vue项目（生成dist静态文件）
RUN npm run build:prod

# ===================== 第二阶段：运行阶段 =====================
FROM ${NGINX_IMAGE}
# 可选：把镜像版本记录到 label（构建时通过 --build-arg APP_VERSION=${TAG} 传入）
ARG APP_VERSION=1.0.0
LABEL org.opencontainers.image.version="${APP_VERSION}"
# 复制构建好的dist文件到Nginx
COPY --from=builder /build/dist /usr/share/nginx/html
# 覆盖默认站点配置，启用前端路由与后端代理
COPY nginx.conf /etc/nginx/conf.d/default.conf
# 暴露端口
EXPOSE 80
# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]
