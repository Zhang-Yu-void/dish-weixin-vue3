# 1. 构建阶段：Node 环境（阿里云官方Docker Hub代理，无权限/无超时）
FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/node:20.16 AS build

WORKDIR /app

# 复制依赖 + 淘宝npm镜像加速
COPY package*.json ./
RUN npm config set registry https://registry.npmmirror.com/ && npm install

# 复制项目代码并构建
COPY . .
RUN npm run build

# 2. 运行阶段：Nginx 环境（阿里云官方镜像）
FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/nginx_optimized:20240221-1.20.1-2.3.0

# 复制前端打包产物 + Nginx配置
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
