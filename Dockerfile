# ===================== 第一阶段：构建阶段（国内极速Node镜像）=====================
FROM node:20-alpine AS builder
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
RUN npm run build

# ===================== 第二阶段：运行阶段（国内极速Nginx镜像）=====================
FROM nginx:alpine
# 复制构建好的dist文件到Nginx
COPY --from=builder /build/dist /usr/share/nginx/html
# 暴露端口
EXPOSE 80
# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]
