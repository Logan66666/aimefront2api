FROM node:22-alpine

WORKDIR /app

# 安装依赖
COPY package.json ./
RUN npm install --production

# 复制源码
COPY server.js ./

# 暴露端口
EXPOSE 3000

# 启动
CMD ["node", "server.js"]
