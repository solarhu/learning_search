#!/bin/bash

# Vercel 构建脚本 - 安装 Flutter 并构建项目

set -e

echo "=== 开始 Vercel 构建 ==="
echo "当前目录: $(pwd)"
echo "目录内容: $(ls -la)"

# 定义 Flutter 版本 - 使用更新的稳定版本
FLUTTER_VERSION="3.19.3"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

# 创建临时目录
BUILD_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)
echo "临时目录: $TEMP_DIR"

cd "$TEMP_DIR"

echo "下载 Flutter $FLUTTER_VERSION ..."
if ! curl -L -o flutter.tar.xz "$FLUTTER_URL"; then
    echo "下载失败，尝试使用备用版本"
    FLUTTER_VERSION="3.16.0"
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    curl -L -o flutter.tar.xz "$FLUTTER_URL"
fi

echo "解压 Flutter ..."
tar xf flutter.tar.xz

# 配置 Git safe.directory 来避免所有权问题
git config --global --add safe.directory "$TEMP_DIR/flutter"

# 设置 Flutter 路径
export PATH="$TEMP_DIR/flutter/bin:$PATH"
export FLUTTER_ROOT="$TEMP_DIR/flutter"

# 禁用 analytics 和 telemetry
flutter config --no-analytics
flutter config --no-cli-animations

echo "Flutter 版本:"
flutter --version
flutter doctor -v || true

# 回到项目目录
cd "$BUILD_DIR"

echo "项目目录内容: $(ls -la)"

echo "获取 Flutter 依赖 ..."
flutter pub get --verbose

echo "构建 Flutter Web ..."
flutter build web --release --base-href="/" --web-renderer html --dart-define=API_BASE_URL=http://47.253.106.52:18080

echo "构建输出目录内容:"
ls -la build/web/

echo "=== 构建完成 ==="
