#!/bin/bash

set -e

ROOT="./"

# 获取所有 stable 版本中最新的 6.18.x
KERNEL_VERSION=$(curl -s https://www.kernel.org/releases.json \
  | jq -r '.releases[] | select(.moniker=="longterm") | .version' \
  | grep '^6\.18\.' \
  | sort -V \
  | tail -n1)

# 从自建镜像获取对应 tar.xz 的 SHA256
KERNEL_HASH=$(curl -s https://us.cooluc.com/kernel/v6.x/sha256sums.asc \
  | grep "linux-$KERNEL_VERSION.tar.xz" \
  | awk '{print $1}')

# 如果没有匹配到 SHA256，立即退出
if [ -z "$KERNEL_HASH" ]; then
    echo "Error: SHA256 for linux-$KERNEL_VERSION.tar.xz not found. Mirror may not be synced."
    exit 1
fi

# 提取 TAG（第三段版本号）
TAG=$(echo "$KERNEL_VERSION" | awk -F"." '{print $3}')
[ -z "$TAG" ] && TAG="" || TAG=".$TAG"

# 输出到文件
echo "LINUX_VERSION-6.18 = $TAG
LINUX_KERNEL_HASH-$KERNEL_VERSION = $KERNEL_HASH" > "$ROOT/kernel-6.18"
