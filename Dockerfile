# 构建阶段：Node.js 22
FROM node:22-alpine AS build
WORKDIR /app
ARG BUILD_MODE=stage
COPY package*.json ./
RUN npm install --registry=https://registry.npmmirror.com
COPY . .
RUN npm run build:${BUILD_MODE}

# 运行阶段：Nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
