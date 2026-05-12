#!/bin/bash

if [ "$KERNEL_CLANG_LTO" = "y" ]; then 
    # linux-atm
    curl -s $mirror/openwrt/patch/packages-patches/clang/linux-atm/openwrt-fix-build-with-clang.patch | patch -p1
fi

if [ "$ENABLE_MOLD" = "y" ]; then
    # attr
    sed -i '/PKG_BUILD_PARALLEL/aPKG_BUILD_FLAGS:=no-mold' feeds/packages/utils/attr/Makefile
fi

# irqbalance
curl -s $mirror/openwrt/patch/packages-patches/irqbalance/901-meson-disable-numa-option-by-default.patch > feeds/packages/utils/irqbalance/patches/901-meson-disable-numa-option-by-default.patch

# libsodium - fix build with lto (GNU BUG - 89147)
sed -i "/CONFIGURE_ARGS/i\TARGET_CFLAGS += -ffat-lto-objects\n" feeds/packages/libs/libsodium/Makefile

# haproxy - fix build with quictls
sed -i '/USE_QUIC_OPENSSL_COMPAT/d' feeds/packages/net/haproxy/Makefile

# xdp-tools
rm -rf package/network/utils/xdp-tools
git clone https://$github/sbwml/package_network_utils_xdp-tools package/network/utils/xdp-tools

# ksmbd luci
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/luci/applications/luci-app-ksmbd/htdocs/luci-static/resources/view/ksmbd.js

# ksmbd tools
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/ksmbd-tools/files/ksmbd.config.example
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/ksmbd-tools/files/ksmbd.conf.template

# perf
curl -s $mirror/openwrt/patch/openwrt-6.x/musl/990-add-typedefs-for-Elf64_Relr-and-Elf32_Relr.patch > toolchain/musl/patches/990-add-typedefs-for-Elf64_Relr-and-Elf32_Relr.patch
curl -s $mirror/openwrt/patch/openwrt-6.x/perf/Makefile > package/devel/perf/Makefile

# kselftests-bpf
curl -s $mirror/openwrt/patch/packages-patches/kselftests-bpf/Makefile > package/devel/kselftests-bpf/Makefile

#######################################

# fix gcc-15.0.1 gnu17
if [ "$USE_GCC15" = y ] || [ "$USE_GCC16" = y ]; then
    # xl2tpd
    sed -i '/ifneq (0,0)/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/xl2tpd/Makefile
fi

# fix gcc-16.1.0
if [ "$USE_GCC16" = y ]; then
    # elfutils lto
    curl -s $mirror/openwrt/patch/packages-patches_gcc16/elfutils/900-fix-gcc16-null-dereference-with-lto.patch > package/libs/elfutils/patches/900-fix-gcc16-null-dereference-with-lto.patch
    # libwebsockets
    mkdir -p feeds/packages/libs/libwebsockets/patches
    curl -s $mirror/openwrt/patch/packages-patches_gcc16/libwebsockets/900-fix-build-for-gcc-16.patch > feeds/packages/libs/libwebsockets/patches/900-fix-build-for-gcc-16.patch
    # bash
    sed -i "/PKG_INSTALL:=/i\PKG_BUILD_FLAGS:=no-lto" feeds/packages/utils/bash/Makefile
fi
