#!/bin/bash

set -e

ROOT="./"

# LTS
KERNEL_VERSION=`curl -s https://raw.githubusercontent.com/andreoss/kernel-overlay/refs/heads/master/sources.json | jq -r '.[] | select(.package.name == "mainline") | .version'`
KERNEL_HASH=`curl -s https://raw.githubusercontent.com/andreoss/kernel-overlay/refs/heads/master/sources.json | jq -r '.[] | select(.package.name == "mainline") | .checksum'`
TAG=`echo $KERNEL_VERSION | awk -F"." '{print $3}'`

[ -z $TAG ] && TAG="" || TAG=.$TAG
echo "LINUX_VERSION-6.18 = $TAG
LINUX_KERNEL_HASH-$KERNEL_VERSION = $KERNEL_HASH" > $ROOT/kernel-6.18
