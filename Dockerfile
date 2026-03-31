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
# 若直连 Docker Hub 超时（auth.docker.io），构建时可覆盖基础镜像，例如：
# NODE_IMAGE=docker.m.daocloud.io/library/node:20-alpine \
# NGINX_IMAGE=docker.m.daocloud.io/library/nginx:alpine \
# docker build --build-arg NODE_IMAGE=... --build-arg NGINX_IMAGE=... -t ...
ARG NODE_IMAGE=node:20-alpine
ARG NGINX_IMAGE=nginx:alpine
FROM ${NODE_IMAGE} AS builder
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
# 暴露端口
EXPOSE 80
# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]
