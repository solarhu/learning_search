#!/bin/bash

# Vercel 构建脚本 - 安装 Flutter 并构建项目

set -e

echo "=== 开始 Vercel 构建 ==="

# 定义 Flutter 版本
FLUTTER_VERSION="3.29.0"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

# 创建临时目录
BUILD_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "下载 Flutter $FLUTTER_VERSION ..."
curl -L -o flutter.tar.xz "$FLUTTER_URL"

echo "解压 Flutter ..."
tar xf flutter.tar.xz

# 设置 Flutter 路径
export PATH="$TEMP_DIR/flutter/bin:$PATH"
export FLUTTER_ROOT="$TEMP_DIR/flutter"

echo "Flutter 版本:"
flutter --version

# 回到项目目录
cd "$BUILD_DIR"

echo "获取 Flutter 依赖 ..."
flutter pub get

echo "构建 Flutter Web ..."
flutter build web --release

echo "=== 构建完成 ==="
