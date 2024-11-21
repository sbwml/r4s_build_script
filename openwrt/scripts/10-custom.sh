#!/bin/bash

# 自定义脚本

# 增加插件

# Syncthing 存储同步工具
git clone https://github.com/Turing-China/luci-app-syncthing package/new/luci-app-syncthing
# 迅雷下载
git clone https://github.com/sbwml/luci-app-xunlei package/new/luci-app-xunlei
# Lucky大吉
git clone https://github.com/sirpdboy/luci-app-lucky package/new/luci-app-lucky
#风扇控制
git clone https://github.com/JiaY-shi/fancontrol package/new/luci-app-fancontrol


# 更新软件版本
# 使用 sha256sum 校验HASH

# ZeroTier
# 定义软件文件路径
ZEROTIER_MAKEFILE_PATH="./feeds/packages/net/zerotier/Makefile"
# 定义软件版本信息
ZEROTIER_PKG_VERSION="1.14.2"
ZEROTIER_PKG_HASH="c2f64339fccf5148a7af089b896678d655fbfccac52ddce7714314a59d7bddbb"
# 使用 sed 命令替换文件中的值
sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=${ZEROTIER_PKG_VERSION}/" $ZEROTIER_MAKEFILE_PATH
sed -i "s/^PKG_HASH:=.*/PKG_HASH:=${ZEROTIER_PKG_HASH}/" $ZEROTIER_MAKEFILE_PATH

# Syncthing
# 定义软件文件路径
SYNCTHING_MAKEFILE_PATH="./feeds/packages/utils/syncthing/Makefile"
# 定义软件版本信息
SYNCTHING_PKG_VERSION="1.28.0"
SYNCTHING_PKG_HASH="73b4030f9fca381f58f4966db48cc135cd8232fe9e8853b5651de0f0bf4cfbf7"
# 使用 sed 命令替换文件中的值
sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=${SYNCTHING_PKG_VERSION}/" $SYNCTHING_MAKEFILE_PATH
sed -i "s/^PKG_HASH:=.*/PKG_HASH:=${SYNCTHING_PKG_HASH}/" $SYNCTHING_MAKEFILE_PATH
