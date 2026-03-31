# 1. 构建阶段：Node 环境（阿里云镜像）
FROM registry.cn-hangzhou.aliyuncs.com/library/node:22-alpine AS build

WORKDIR /app

# 复制依赖 + 淘宝npm源加速安装
COPY package*.json ./
RUN npm config set registry https://registry.npmmirror.com/ && npm install

COPY . .
# 构建Vue生产包
RUN npm run build

# 2. 运行阶段：Nginx 环境（阿里云镜像）
FROM registry.cn-hangzhou.aliyuncs.com/library/nginx:alpine

# 复制构建产物和Nginx配置
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
