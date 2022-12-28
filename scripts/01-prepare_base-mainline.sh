#!/bin/bash

#################################################################

# Rockchip - target - r5s
rm -rf target/linux/rockchip
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_rockchip-6.x target/linux/rockchip

# kernel - 6.x
curl -s https://$mirror/tags/kernel-6.1 > include/kernel-6.1
cat include/kernel-6.1 | grep HASH | awk -F- '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# kernel modules
git checkout package/kernel/linux
curl -s https://$mirror/openwrt/patch/openwrt-6.1/include_netfilter.patch | patch -p1
curl -s https://$mirror/openwrt/patch/openwrt-6.1/linux-firmware-20221214.patch | patch -p1
rm -rf package/kernel/linux/*
curl -Os https://$mirror/openwrt/patch/openwrt-6.1/linux-6.x.tar.gz
tar zxvf linux-6.x.tar.gz -C package/kernel/linux/ && rm -f linux-6.x.tar.gz

# kernel generic patches
pushd target/linux/generic
    svn export https://github.com/sbwml/target_linux_generic/branches/6.1/target/linux/generic/backport-6.1 backport-6.1
    svn export https://github.com/sbwml/target_linux_generic/branches/6.1/target/linux/generic/hack-6.1 hack-6.1
    svn export https://github.com/sbwml/target_linux_generic/branches/6.1/target/linux/generic/pending-6.1 pending-6.1
    curl -s https://raw.githubusercontent.com/sbwml/target_linux_generic/6.1/target/linux/generic/config-6.1 > config-6.1
popd

# kernel patch
curl -s https://$mirror/openwrt/patch/kernel-6.1/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/pending-6.1/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
curl -s https://$mirror/openwrt/patch/kernel-6.1/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-6.1/952-net-conntrack-events-support-multiple-registrant.patch
curl -s https://$mirror/openwrt/patch/kernel-6.1/998-hide-panfrost-logs.patch > target/linux/generic/hack-6.1/998-hide-panfrost-logs.patch
curl -s https://$mirror/openwrt/patch/kernel-6.1/999-hide-irq-logs.patch > target/linux/generic/hack-6.1/999-hide-irq-logs.patch

#################################################################

# tools/meson
rm -rf tools/meson
svn export https://github.com/openwrt/openwrt/branches/master/tools/meson tools/meson

# gcc-12
curl -s https://github.com/openwrt/openwrt/commit/c4bd303086012afe2aebd213c892363512138bb7.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/3c06a344e9c7c03c49c9153342e68a5390651323.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/e6cc3ded0709aa6c7a190c31575bb5c19e204cd2.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/fac1f38d7559230eddbbab996c32b12b314fae15.patch | patch -p1

# switch to gcc-12 by default
sed -i 's/default GCC_USE_VERSION_11/default GCC_USE_VERSION_12/g' toolchain/gcc/Config.in
sed -i 's/11.2.0/12.2.0/g' toolchain/gcc/Config.version

# Fix GCC version check
curl -s https://$mirror/openwrt/patch/openwrt-6.1/toolchain/fix-gcc-version.patch | patch -p1

# binutils 2.38
sed -i 's/default BINUTILS_USE_VERSION_2_37/default BINUTILS_USE_VERSION_2_38/g' toolchain/binutils/Config.in
curl -s https://$mirror/openwrt/patch/openwrt-6.1/toolchain/binutils-2.38.patch | patch -p1

# feeds/packages/libs/libxcrypt - fix build for gcc-12
sed -i "/Build\/InstallDev/iTARGET_CFLAGS += -Wno-strict-overflow\n" feeds/packages/libs/libxcrypt/Makefile

# package/libs/libnl-tiny - fix build for gcc-12
curl -s https://$mirror/openwrt/patch/openwrt-6.1/package_libs_libnl-tiny-2022-11-01.patch | patch -p1

# feeds/packages/libs/libwebsockets - fix build for gcc-12
curl -s https://raw.githubusercontent.com/openwrt/packages/9c5d4fb5a4d2f3157b9b9e4fc2a7a0457adccdf5/libs/libwebsockets/patches/020-gcc12.patch > feeds/packages/libs/libwebsockets/patches/020-gcc12.patch

# feeds/packages/net/gensio - fix linux 6.1
pushd feeds/packages
    curl -s https://github.com/openwrt/packages/commit/ea3ad6b0909b2f5d8a8dcbc4e866c9ed22f3fb10.patch  | patch -p1
popd

#################################################################

# ksmbd luci
rm -rf feeds/luci/applications/luci-app-ksmbd
svn export https://github.com/openwrt/luci/branches/master/applications/luci-app-ksmbd feeds/luci/applications/luci-app-ksmbd
curl -s https://$mirror/openwrt/patch/openwrt-6.1/ksmbd/version.patch | patch -p1
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/luci/applications/luci-app-ksmbd/htdocs/luci-static/resources/view/ksmbd.js

# ksmbd tools
rm -rf feeds/packages/net/ksmbd-tools
svn export https://github.com/openwrt/packages/branches/master/net/ksmbd-tools feeds/packages/net/ksmbd-tools
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/ksmbd-tools/files/ksmbd.config.example
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/ksmbd-tools/files/ksmbd.conf.template

# ksmbd module - fix for linux 6.x
rm -rf package/kernel/ksmbd
