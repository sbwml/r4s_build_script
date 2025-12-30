#!/bin/bash

# odhcp6c - fix for openwrt-v25.12.0-rc1
if [ "$branch" = "v25.12.0-rc1" ]; then
    curl -s $mirror/openwrt/patch/odhcp6c/0001-odhcp6c-update-to-25.12-Git-HEAD-2025-12-29.patch | patch -p1
fi

if [ "$KERNEL_CLANG_LTO" = "y" ]; then 
    # linux-atm
    curl -s $mirror/openwrt/patch/packages-patches/clang/linux-atm/openwrt-fix-build-with-clang.patch | patch -p1
fi

if [ "$ENABLE_MOLD" = "y" ]; then
    # attr
    sed -i '/PKG_BUILD_PARALLEL/aPKG_BUILD_FLAGS:=no-mold' feeds/packages/utils/attr/Makefile
fi

# apk-tools
curl -s $mirror/openwrt/patch/apk-tools/999-hack-for-linux-pre-releases.patch > package/system/apk/patches/999-hack-for-linux-pre-releases.patch

# irqbalance
curl -s $mirror/openwrt/patch/packages-patches/irqbalance/900-meson-add-numa-option.patch > feeds/packages/utils/irqbalance/patches/900-meson-add-numa-option.patch

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
if [ "$USE_GCC15" = y ]; then
    # libtirpc
    sed -i '/TARGET_CFLAGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/libtirpc/Makefile
    # libsepol
    sed -i '/HOST_MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/libs/libsepol/Makefile
    # tree
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/tree/Makefile
    # gdbm
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/gdbm/Makefile
    # libical
    sed -i '/CMAKE_OPTIONS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/libical/Makefile
    # libconfig
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/feeds/packages/libconfig/Makefile
    # lsof
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/lsof/Makefile
    # screen
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/screen/Makefile
    # ppp
    sed -i '/CONFIGURE_VARS/i \\nTARGET_CFLAGS += -std=gnu17\n' package/network/services/ppp/Makefile
    # vim
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/vim/Makefile
    # mtd
    sed -i '/target=/i TARGET_CFLAGS += -std=gnu17\n' package/system/mtd/Makefile
    # libselinux
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/libs/libselinux/Makefile
    # avahi
    sed -i '/TARGET_CFLAGS +=/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/avahi/Makefile
    # xl2tpd
    sed -i '/ifneq (0,0)/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/xl2tpd/Makefile
    # bluez
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/bluez/Makefile
    # e2fsprogs
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/utils/e2fsprogs/Makefile
    # f2fs-tools
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/utils/f2fs-tools/Makefile
    # krb5
    sed -i '/CONFIGURE_VARS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/krb5/Makefile
    # parted
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/parted/Makefile
    # iperf3
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/iperf3/Makefile
    # db
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/db/Makefile
    # python3
    sed -i '/TARGET_CONFIGURE_OPTS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/lang/python/python3/Makefile
    # uwsgi
    sed -i '/MAKE_VARS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/uwsgi/Makefile
    # perl
    sed -i '/Target perl/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/lang/perl/Makefile
    # rsync
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/rsync/Makefile
    # shine
    sed -i '/Build\/InstallDev/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/sound/shine/Makefile
    # jq
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/jq/Makefile
fi
