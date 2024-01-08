#!/bin/bash

# libsodium - fix build with lto (GNU BUG - 89147)
sed -i "/CONFIGURE_ARGS/i\TARGET_CFLAGS += -ffat-lto-objects\n" feeds/packages/libs/libsodium/Makefile

# grub2 -  disable `gc-sections` flag
sed -i '/PKG_BUILD_FLAGS/ s/$/ no-gc-sections/' package/boot/grub2/Makefile

# uqmi - fix gcc11
if [ "$USE_GLIBC" != "y" ]; then
    sed -i '/dangling-pointer/d' package/network/utils/uqmi/Makefile
fi

# xdp-tools
[ "$platform" != "x86_64" ] && sed -i '/TARGET_LDFLAGS +=/iTARGET_CFLAGS += -Wno-error=maybe-uninitialized -ffat-lto-objects\n' package/network/utils/xdp-tools/Makefile
[ "$platform" = "x86_64" ] && sed -i '/TARGET_LDFLAGS +=/iTARGET_CFLAGS += -ffat-lto-objects\n' package/network/utils/xdp-tools/Makefile

# ksmbd luci
rm -rf feeds/luci/applications/luci-app-ksmbd
cp -a ../master/luci/applications/luci-app-ksmbd feeds/luci/applications/luci-app-ksmbd
curl -s $mirror/openwrt/patch/openwrt-6.x/ksmbd/version.patch | patch -p1
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/luci/applications/luci-app-ksmbd/htdocs/luci-static/resources/view/ksmbd.js

# ksmbd tools
rm -rf feeds/packages/net/ksmbd-tools
cp -a ../master/packages/net/ksmbd-tools feeds/packages/net/ksmbd-tools
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/ksmbd-tools/files/ksmbd.config.example
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/ksmbd-tools/files/ksmbd.conf.template

# vim - fix E1187: Failed to source defaults.vim
pushd feeds/packages
    curl -s https://github.com/openwrt/packages/commit/699d3fbee266b676e21b7ed310471c0ed74012c9.patch | patch -p1
popd

# bpf - add host clang-15/17 support
sed -i 's/command -v clang/command -v clang clang-17 clang-15/g' include/bpf.mk

# perf
curl -s $mirror/openwrt/patch/openwrt-6.x/musl/990-add-typedefs-for-Elf64_Relr-and-Elf32_Relr.patch > toolchain/musl/patches/990-add-typedefs-for-Elf64_Relr-and-Elf32_Relr.patch
curl -s $mirror/openwrt/patch/openwrt-6.x/perf/Makefile > package/devel/perf/Makefile
