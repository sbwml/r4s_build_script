#!/bin/bash

ROOT="./"

# LTS
KERNEL_VERSION=`curl -s https://us.cooluc.com/kernel/v6.x/sha256sums.asc | awk '{print $2}' | grep -E ^linux-6.6 | grep tar.xz | sed 's/linux-//g;s/.tar.xz//g' | tail -n 1`
KERNEL_HASH=`curl -s https://us.cooluc.com/kernel/v6.x/sha256sums.asc | grep linux-$KERNEL_VERSION | grep tar.xz | awk '{print $1}'`
TAG=`echo $KERNEL_VERSION | awk -F"." '{print $3}'`

[ -z $TAG ] && TAG="" || TAG=.$TAG
echo "LINUX_VERSION-6.6 = $TAG
LINUX_KERNEL_HASH-$KERNEL_VERSION = $KERNEL_HASH" > $ROOT/kernel-6.6
