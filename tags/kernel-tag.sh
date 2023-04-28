#!/bin/bash

ROOT="./"

# LTS
KERNEL_VERSION=`curl -s https://us.cooluc.com/kernel/v6.x/sha256sums.asc | awk '{print $2}' | grep -E ^linux-6.1 | grep tar.xz | sed 's/linux-//g;s/.tar.xz//g' | tail -n 1`
KERNEL_HASH=`curl -s https://us.cooluc.com/kernel/v6.x/sha256sums.asc | grep linux-$KERNEL_VERSION | grep tar.xz | awk '{print $1}'`
TAG=`echo $KERNEL_VERSION | awk -F"." '{print $3}'`

# MAIN
KERNEL_VERSION_MAIN=`curl -s https://us.cooluc.com/kernel/v6.x/sha256sums.asc | awk '{print $2}' | grep -E ^linux-6.3 | grep tar.xz | sed 's/linux-//g;s/.tar.xz//g' | tail -n 1`
KERNEL_HASH_MAIN=`curl -s https://us.cooluc.com/kernel/v6.x/sha256sums.asc | grep linux-$KERNEL_VERSION_MAIN | grep tar.xz | awk '{print $1}'`
TAG_MAIN=`echo $KERNEL_VERSION_MAIN | awk -F"." '{print $3}'`

[ -z $TAG ] && TAG="" || TAG=.$TAG
[ "$1" = 1 ] && echo "LINUX_VERSION-6.1 = $TAG
LINUX_KERNEL_HASH-$KERNEL_VERSION = $KERNEL_HASH" > $ROOT/kernel-6.1

[ -z $TAG_MAIN ] && TAG_MAIN="" || TAG_MAIN=.$TAG_MAIN
[ "$1" = 3 ] && echo "LINUX_VERSION-6.3 = $TAG_MAIN
LINUX_KERNEL_HASH-$KERNEL_VERSION_MAIN = $KERNEL_HASH_MAIN" > $ROOT/kernel-6.3
