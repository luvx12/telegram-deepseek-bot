# 使用 Go 官方镜像作为基础镜像
FROM golang:1.24 AS builder

# 设置工作目录
WORKDIR /app

# 复制项目文件到容器内
COPY . .

# 下载依赖
RUN go mod tidy; \
    go build -ldflags="-w -s" -v -o telegram-deepseek-bot main.go

FROM buildpack-deps:curl

# 设置运行环境变量（可选）
ENV TELEGRAM_BOT_TOKEN=""
ENV DEEPSEEK_TOKEN=""
ENV CUSTOM_URL=""
ENV DEEPSEEK_TYPE=""
ENV VOLC_AK=""
ENV VOLC_SK=""
ENV DB_TYPE=""
ENV DB_CONF=""

WORKDIR /app
COPY --from=builder /app/telegram-deepseek-bot .
# 运行程序
CMD ["./telegram-deepseek-bot"]
