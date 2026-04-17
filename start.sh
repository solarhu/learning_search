#!/bin/bash
# learning-search 启动脚本

set -e

# 读取 .env 文件
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# 默认端口
PORT=${PORT:-8081}

echo "Starting learning-search server..."
echo "Port: $PORT"
echo "OpenAI API Key: ${OPENAI_API_KEY:0:6}...${OPENAI_API_KEY: -6}"

cd server
./server
