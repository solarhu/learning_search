# 阶段1: 构建 Go 后端
FROM golang:1.22-alpine AS builder

WORKDIR /app

# 复制后端代码
COPY server/ .

# 构建
RUN go build -o server main.go

# 阶段2: 运行镜像
FROM alpine:3.19

WORKDIR /app

# 复制后端二进制
COPY --from=builder /app/server .
# 复制 .env 示例
COPY .env.example ./.env

# 暴露默认端口
EXPOSE 8081

# 启动命令
CMD ["./server"]
