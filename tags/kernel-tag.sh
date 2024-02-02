#!/bin/bash

ROOT="./"

# RT PATCH
RT_PATCH_VERSION=`curl -s https://us.cooluc.com/kernel/projects/rt/6.6/ | grep -o 'patch-.*\.patch\.xz' | sed 's/.*">//'`
curl -s "https://us.cooluc.com/kernel/projects/rt/6.6/$RT_PATCH_VERSION" | xzcat > $ROOT/rt/patch-6.6.x-rt.patch

# LTS
KERNEL_VERSION=`echo $RT_PATCH_VERSION | grep -oP 'patch-(\d+\.\d+\.\d+)-rt\d+\.patch\.xz' | grep -oP '\d+\.\d+\.\d+'`
KERNEL_HASH=`curl -s https://us.cooluc.com/kernel/v6.x/sha256sums.asc | grep linux-$KERNEL_VERSION | grep tar.xz | awk '{print $1}'`
TAG=`echo $KERNEL_VERSION | awk -F"." '{print $3}'`

[ -z $TAG ] && TAG="" || TAG=.$TAG
echo "LINUX_VERSION-6.6 = $TAG
LINUX_KERNEL_HASH-$KERNEL_VERSION = $KERNEL_HASH" > $ROOT/kernel-6.6
