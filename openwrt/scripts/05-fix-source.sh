#!/bin/bash

# libsodium - fix build with lto (GNU BUG - 89147)
sed -i "/CONFIGURE_ARGS/i\TARGET_CFLAGS += -ffat-lto-objects\n" feeds/packages/libs/libsodium/Makefile

# grub2 -  disable `gc-sections` flag
sed -i '/PKG_BUILD_FLAGS/ s/$/ no-gc-sections/' package/boot/grub2/Makefile

# fix gcc13
if [ "$USE_GCC13" = "y" ] || [ "$USE_GCC14" = y ]; then
    # libwebsockets
    mkdir feeds/packages/libs/libwebsockets/patches
    pushd feeds/packages/libs/libwebsockets/patches
        curl -sLO https://raw.githubusercontent.com/openwrt/packages/bcd970fb4ff6029fbf612dccf6d8c2902a65e20e/libs/libwebsockets/patches/010-fix-enum-int-mismatch-openssl.patch
        curl -sLO https://raw.githubusercontent.com/openwrt/packages/bcd970fb4ff6029fbf612dccf6d8c2902a65e20e/libs/libwebsockets/patches/011-fix-enum-int-mismatch-mbedtls.patch
        curl -sLO https://raw.githubusercontent.com/openwrt/packages/94bd1ca8bad053a772a3ea8cb06ce59241fb9a57/libs/libwebsockets/patches/100-fix-uninitialized-variable-usage.patch
    popd
fi

# fix gcc14
if [ "$USE_GCC14" = y ]; then
    # iproute2
    sed -i '/TARGET_LDFLAGS/iTARGET_CFLAGS += -Wno-incompatible-pointer-types' package/network/utils/iproute2/Makefile
    # ppp
    sed -i '/MAKE_FLAGS += COPTS/iTARGET_CFLAGS += -Wno-implicit-function-declaration' package/network/services/ppp/Makefile
    # openvswitch
    sed -i 's/-std=gnu99/-std=gnu99 -Wno-implicit-function-declaration -Wno-int-conversion/' feeds/packages/net/openvswitch/Makefile
    # wsdd2
    sed -i '/Build\/Compile/iTARGET_CFLAGS += -Wno-int-conversion' feeds/packages/net/wsdd2/Makefile
    # libunwind
    rm -rf package/libs/libunwind
    git clone https://github.com/sbwml/package_libs_libunwind package/libs/libunwind
    # uboot
    [ "$platform" != "x86_64" ] && curl -s https://$mirror/openwrt/patch/packages-patches/gcc-14/990-uboot-fix-gcc14.patch > package/boot/uboot-rockchip/patches/990-uboot-fix-gcc14.patch
    # lrzsz
    curl -s https://$mirror/openwrt/patch/packages-patches/gcc-14/900-lrzsz-fix-gcc14.patch > package/new/lrzsz/patches/900-lrzsz-fix-gcc14.patch
    sed -i '/lrzsz\/install/iTARGET_CFLAGS += -Wno-implicit-function-declaration -Wno-builtin-declaration-mismatch -Wno-incompatible-pointer-types' package/new/lrzsz/Makefile
    # mbedtls
    curl -s https://$mirror/openwrt/patch/mbedtls-23.05/900-fix-build-with-gcc14.patch > package/libs/mbedtls/patches/900-fix-build-with-gcc14.patch
    # linux-atm
    curl -s https://$mirror/openwrt/patch/packages-patches/gcc-14/linux-atm-fix-gcc14.patch | patch -p1
    # lsof
    rm -rf feeds/packages/utils/lsof
    cp -a ../master/packages/utils/lsof feeds/packages/utils/lsof
    # screen
    SCREEN_VERSION=4.9.1
    SCREEN_HASH=26cef3e3c42571c0d484ad6faf110c5c15091fbf872b06fa7aa4766c7405ac69
    sed -ri "s/(PKG_VERSION:=)[^\"]*/\1$SCREEN_VERSION/;s/(PKG_HASH:=)[^\"]*/\1$SCREEN_HASH/" feeds/packages/utils/screen/Makefile
    sed -i '/CONFIGURE_ARGS/iTARGET_CFLAGS += -Wno-implicit-function-declaration' feeds/packages/utils/screen/Makefile
    rm -rf feeds/packages/utils/screen/patches
    # irqbalance
    sed -i '/MESON_ARGS/iTARGET_CFLAGS += -Wno-int-conversion' feeds/packages/utils/irqbalance/Makefile
    # xdp-tools
    curl -s https://$mirror/openwrt/patch/packages-patches/gcc-14/xdp-tools/900-Fix-transposed-calloc-arguments.patch > package/network/utils/xdp-tools/patches/900-Fix-transposed-calloc-arguments.patch
    # perl
    sed -i '/Filter -g3/aTARGET_CFLAGS += -Wno-implicit-function-declaration' feeds/packages/lang/perl/Makefile
    # grub2
    sed -i '/define Host\/Configure/iTARGET_CFLAGS += -Wno-incompatible-pointer-types' package/boot/grub2/Makefile
fi

# xdp-tools
[ "$platform" != "x86_64" ] && sed -i '/TARGET_LDFLAGS +=/iTARGET_CFLAGS += -Wno-error=maybe-uninitialized -ffat-lto-objects\n' package/network/utils/xdp-tools/Makefile
[ "$platform" = "x86_64" ] && sed -i '/TARGET_LDFLAGS +=/iTARGET_CFLAGS += -ffat-lto-objects\n' package/network/utils/xdp-tools/Makefile

# ksmbd luci
rm -rf feeds/luci/applications/luci-app-ksmbd
cp -a ../master/luci/applications/luci-app-ksmbd feeds/luci/applications/luci-app-ksmbd
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
curl -s https://$mirror/openwrt/patch/openwrt-6.x/musl/990-add-typedefs-for-Elf64_Relr-and-Elf32_Relr.patch > toolchain/musl/patches/990-add-typedefs-for-Elf64_Relr-and-Elf32_Relr.patch
curl -s https://$mirror/openwrt/patch/openwrt-6.x/perf/Makefile > package/devel/perf/Makefile
