#!/bin/bash -e

# Rockchip - rkbin & u-boot
rm -rf package/boot/uboot-rockchip package/boot/arm-trusted-firmware-rockchip
if [ "$platform" = "rk3568" ]; then
    git clone https://$github/sbwml/package_boot_uboot-rockchip package/boot/uboot-rockchip
    git clone https://$github/sbwml/arm-trusted-firmware-rockchip package/boot/arm-trusted-firmware-rockchip
else
    git clone https://$github/sbwml/package_boot_uboot-rockchip package/boot/uboot-rockchip -b v2023.04
    git clone https://$github/sbwml/arm-trusted-firmware-rockchip package/boot/arm-trusted-firmware-rockchip -b 0419
fi

######## OpenWrt Patches ########

# tools: add llvm/clang toolchain
curl -s https://$mirror/openwrt/patch/generic/0001-tools-add-llvm-clang-toolchain.patch | patch -p1

# tools: add upx tools
curl -s https://$mirror/openwrt/patch/generic/0002-tools-add-upx-tools.patch | patch -p1

# rootfs: upx compression
# include/rootfs.mk
curl -s https://$mirror/openwrt/patch/generic/0003-rootfs-add-upx-compression-support.patch | patch -p1

# rootfs: add r/w (0600) permissions for UCI configuration files
# include/rootfs.mk
curl -s https://$mirror/openwrt/patch/generic/0004-rootfs-add-r-w-permissions-for-UCI-configuration-fil.patch | patch -p1

# rootfs: Add support for local kmod installation sources
curl -s https://$mirror/openwrt/patch/generic/0005-rootfs-Add-support-for-local-kmod-installation-sourc.patch | patch -p1

# BTF: fix failed to validate module
# config/Config-kernel.in patch
curl -s https://$mirror/openwrt/patch/generic/0006-kernel-add-MODULE_ALLOW_BTF_MISMATCH-option.patch | patch -p1

# kernel: Add support for llvm/clang compiler
curl -s https://$mirror/openwrt/patch/generic/0007-kernel-Add-support-for-llvm-clang-compiler.patch | patch -p1

# toolchain: Add libquadmath to the toolchain
curl -s https://$mirror/openwrt/patch/generic/0008-libquadmath-Add-libquadmath-to-the-toolchain.patch | patch -p1

# build: kernel: add out-of-tree kernel config
curl -s https://$mirror/openwrt/patch/generic/0009-build-kernel-add-out-of-tree-kernel-config.patch | patch -p1

# kernel: linux-6.11 config
curl -s https://$mirror/openwrt/patch/generic/0010-include-kernel-add-miss-config-for-linux-6.11.patch | patch -p1

# meson: add platform variable to cross-compilation file
curl -s https://$mirror/openwrt/patch/generic/0011-meson-add-platform-variable-to-cross-compilation-fil.patch | patch -p1

# mold
if [ "$ENABLE_MOLD" = "y" ]; then
    curl -s https://$mirror/openwrt/patch/generic/mold/0001-build-add-support-to-use-the-mold-linker-for-package.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/generic/mold/0002-treewide-opt-out-of-tree-wide-mold-usage.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/generic/mold/0003-toolchain-add-mold-as-additional-linker.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/generic/mold/0004-tools-add-mold-a-modern-linker.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/generic/mold/0005-build-replace-SSTRIP_ARGS-with-SSTRIP_DISCARD_TRAILI.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/generic/mold/0006-config-add-a-knob-to-use-the-mold-linker-for-package.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/generic/mold/0007-rules-prepare-to-use-different-linkers.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/generic/mold/0008-tools-mold-update-to-2.34.0.patch | patch -p1
    # no-mold
    sed -i '/PKG_BUILD_PARALLEL/aPKG_BUILD_FLAGS:=no-mold' feeds/packages/utils/attr/Makefile
fi

######## OpenWrt Patches End ########

# dwarves: Fix a dwarf type DW_ATE_unsigned_1024 to btf encoding issue
mkdir -p tools/dwarves/patches
curl -s https://$mirror/openwrt/patch/openwrt-6.x/dwarves/100-btf_encoder-Fix-a-dwarf-type-DW_ATE_unsigned_1024-to-btf-encoding-issue.patch > tools/dwarves/patches/100-btf_encoder-Fix-a-dwarf-type-DW_ATE_unsigned_1024-to-btf-encoding-issue.patch

# x86 - disable intel_pstate & mitigations
sed -i 's/noinitrd/noinitrd intel_pstate=disable mitigations=off/g' target/linux/x86/image/grub-efi.cfg

# default LAN IP
sed -i "s/192.168.1.1/$LAN/g" package/base-files/files/bin/config_generate

# Use nginx instead of uhttpd
if [ "$ENABLE_UHTTPD" != "y" ]; then
    sed -i 's/+uhttpd /+luci-nginx /g' feeds/luci/collections/luci/Makefile
    sed -i 's/+uhttpd-mod-ubus //' feeds/luci/collections/luci/Makefile
    sed -i 's/+uhttpd /+luci-nginx /g' feeds/luci/collections/luci-light/Makefile
    sed -i "s/+luci /+luci-nginx /g" feeds/luci/collections/luci-ssl-openssl/Makefile
    sed -i "s/+luci /+luci-nginx /g" feeds/luci/collections/luci-ssl/Makefile
    if [ "$version" = "snapshots-23.05" ] || [ "$version" = "rc2" ]; then
        sed -i 's/+uhttpd +uhttpd-mod-ubus /+luci-nginx /g' feeds/packages/net/wg-installer/Makefile
        sed -i '/uhttpd-mod-ubus/d' feeds/luci/collections/luci-light/Makefile
        sed -i 's/+luci-nginx \\$/+luci-nginx/' feeds/luci/collections/luci-light/Makefile
    fi
fi

# Realtek driver - R8168 & R8125 & R8126 & R8152 & R8101
rm -rf package/kernel/r8168 package/kernel/r8101 package/kernel/r8125 package/kernel/r8126
git clone https://$github/sbwml/package_kernel_r8168 package/kernel/r8168
git clone https://$github/sbwml/package_kernel_r8152 package/kernel/r8152
git clone https://$github/sbwml/package_kernel_r8101 package/kernel/r8101
git clone https://$github/sbwml/package_kernel_r8125 package/kernel/r8125
git clone https://$github/sbwml/package_kernel_r8126 package/kernel/r8126

# GCC Optimization level -O3
if [ "$platform" = "x86_64" ]; then
    curl -s https://$mirror/openwrt/patch/target-modify_for_x86_64.patch | patch -p1
elif [ "$platform" = "armv8" ]; then
    curl -s https://$mirror/openwrt/patch/target-modify_for_armsr.patch | patch -p1
else
    curl -s https://$mirror/openwrt/patch/target-modify_for_rockchip.patch | patch -p1
fi

# DPDK & NUMACTL
if [ "$ENABLE_DPDK" = "y" ]; then
    mkdir -p package/new/{dpdk/patches,numactl}
    curl -s https://$mirror/openwrt/patch/dpdk/dpdk/Makefile > package/new/dpdk/Makefile
    curl -s https://$mirror/openwrt/patch/dpdk/dpdk/Config.in > package/new/dpdk/Config.in
    curl -s https://$mirror/openwrt/patch/dpdk/dpdk/patches/010-dpdk_arm_build_platform_fix.patch > package/new/dpdk/patches/010-dpdk_arm_build_platform_fix.patch
    curl -s https://$mirror/openwrt/patch/dpdk/dpdk/patches/201-r8125-add-r8125-ethernet-poll-mode-driver.patch > package/new/dpdk/patches/201-r8125-add-r8125-ethernet-poll-mode-driver.patch
    curl -s https://$mirror/openwrt/patch/dpdk/numactl/Makefile > package/new/numactl/Makefile
fi

# IF USE GLIBC
if [ "$ENABLE_GLIBC" = "y" ]; then
    # musl-libc
    git clone https://$gitea/sbwml/package_libs_musl-libc package/libs/musl-libc
    # bump fstools version
    rm -rf package/system/fstools
    cp -a ../master/openwrt/package/system/fstools package/system/fstools
    # glibc-common
    curl -s https://$mirror/openwrt/patch/glibc/glibc-common.patch | patch -p1
    # glibc-common - locale data
    mkdir -p package/libs/toolchain/glibc-locale
    curl -Lso package/libs/toolchain/glibc-locale/locale-archive https://github.com/sbwml/r4s_build_script/releases/download/locale/locale-archive
    [ "$?" -ne 0 ] && echo -e "${RED_COLOR} Locale file download failed... ${RES}"
    # GNU LANG
    mkdir package/base-files/files/etc/profile.d
    echo 'export LANG="en_US.UTF-8" I18NPATH="/usr/share/i18n"' > package/base-files/files/etc/profile.d/sys_locale.sh
    # build - drop `--disable-profile`
    sed -i "/disable-profile/d" toolchain/glibc/common.mk
fi

# Mbedtls AES & GCM Crypto Extensions
if [ ! "$platform" = "x86_64" ]; then
    curl -s https://$mirror/openwrt/patch/mbedtls-23.05/200-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch > package/libs/mbedtls/patches/200-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch
    curl -s https://$mirror/openwrt/patch/mbedtls-23.05/mbedtls.patch | patch -p1
fi

# NTFS3
mkdir -p package/system/fstools/patches
curl -s https://$mirror/openwrt/patch/fstools/ntfs3.patch > package/system/fstools/patches/ntfs3.patch
curl -s https://$mirror/openwrt/patch/util-linux/util-linux_ntfs3.patch > package/utils/util-linux/patches/util-linux_ntfs3.patch

# fstools - enable any device with non-MTD rootfs_data volume
sed -i 's|$(PROJECT_GIT)/project|https://github.com/openwrt|g' package/system/fstools/Makefile
curl -s https://$mirror/openwrt/patch/fstools/block-mount-add-fstools-depends.patch | patch -p1
if [ "$ENABLE_GLIBC" = "y" ]; then
    curl -s https://$mirror/openwrt/patch/fstools/fstools-set-ntfs3-utf8-new.patch > package/system/fstools/patches/ntfs3-utf8.patch
    curl -s https://$mirror/openwrt/patch/fstools/glibc/0001-libblkid-tiny-add-support-for-XFS-superblock.patch > package/system/fstools/patches/0001-libblkid-tiny-add-support-for-XFS-superblock.patch
    curl -s https://$mirror/openwrt/patch/fstools/glibc/0003-block-add-xfsck-support.patch > package/system/fstools/patches/0003-block-add-xfsck-support.patch
else
    curl -s https://$mirror/openwrt/patch/fstools/fstools-set-ntfs3-utf8-new.patch > package/system/fstools/patches/ntfs3-utf8.patch
fi
if [ "$ENABLE_GLIBC" = "y" ]; then
    curl -s https://$mirror/openwrt/patch/fstools/22-fstools-support-extroot-for-non-MTD-rootfs_data-new-version.patch > package/system/fstools/patches/22-fstools-support-extroot-for-non-MTD-rootfs_data.patch
else
    curl -s https://$mirror/openwrt/patch/fstools/22-fstools-support-extroot-for-non-MTD-rootfs_data.patch > package/system/fstools/patches/22-fstools-support-extroot-for-non-MTD-rootfs_data.patch
fi

# Shortcut Forwarding Engine
git clone https://$gitea/sbwml/shortcut-fe package/new/shortcut-fe

# Patch FireWall 4
if [ "$version" = "snapshots-23.05" ] || [ "$version" = "rc2" ]; then
    # firewall4 - master
    rm -rf package/network/config/firewall4
    cp -a ../master/openwrt/package/network/config/firewall4 package/network/config/firewall4
    sed -i 's|$(PROJECT_GIT)/project|https://github.com/openwrt|g' package/network/config/firewall4/Makefile
    mkdir -p package/network/config/firewall4/patches
    # fix ct status dnat
    curl -s https://$mirror/openwrt/patch/firewall4/firewall4_patches/990-unconditionally-allow-ct-status-dnat.patch > package/network/config/firewall4/patches/990-unconditionally-allow-ct-status-dnat.patch
    # fullcone
    curl -s https://$mirror/openwrt/patch/firewall4/firewall4_patches/999-01-firewall4-add-fullcone-support.patch > package/network/config/firewall4/patches/999-01-firewall4-add-fullcone-support.patch
    # bcm fullcone
    curl -s https://$mirror/openwrt/patch/firewall4/firewall4_patches/999-02-firewall4-add-bcm-fullconenat-support.patch > package/network/config/firewall4/patches/999-02-firewall4-add-bcm-fullconenat-support.patch
    # kernel version
    curl -s https://$mirror/openwrt/patch/firewall4/firewall4_patches/002-fix-fw4.uc-adept-kernel-version-type-of-x.x.patch > package/network/config/firewall4/patches/002-fix-fw4.uc-adept-kernel-version-type-of-x.x.patch
    # fix flow offload
    curl -s https://$mirror/openwrt/patch/firewall4/firewall4_patches/001-fix-fw4-flow-offload.patch > package/network/config/firewall4/patches/001-fix-fw4-flow-offload.patch
    # add custom nft command support
    curl -s https://$mirror/openwrt/patch/firewall4/100-openwrt-firewall4-add-custom-nft-command-support.patch | patch -p1
    # libnftnl
    rm -rf package/libs/libnftnl
    cp -a ../master/openwrt/package/libs/libnftnl package/libs/libnftnl
    mkdir -p package/libs/libnftnl/patches
    curl -s https://$mirror/openwrt/patch/firewall4/libnftnl/001-libnftnl-add-fullcone-expression-support.patch > package/libs/libnftnl/patches/001-libnftnl-add-fullcone-expression-support.patch
    curl -s https://$mirror/openwrt/patch/firewall4/libnftnl/002-libnftnl-add-brcm-fullcone-support.patch > package/libs/libnftnl/patches/002-libnftnl-add-brcm-fullcone-support.patch
    sed -i '/PKG_INSTALL:=1/iPKG_FIXUP:=autoreconf' package/libs/libnftnl/Makefile
    # nftables
    rm -rf package/network/utils/nftables
    cp -a ../master/openwrt/package/network/utils/nftables package/network/utils/nftables
    mkdir -p package/network/utils/nftables/patches
    curl -s https://$mirror/openwrt/patch/firewall4/nftables/002-nftables-add-fullcone-expression-support.patch > package/network/utils/nftables/patches/002-nftables-add-fullcone-expression-support.patch
    curl -s https://$mirror/openwrt/patch/firewall4/nftables/003-nftables-add-brcm-fullconenat-support.patch > package/network/utils/nftables/patches/003-nftables-add-brcm-fullconenat-support.patch
    # hide nftables warning message
    pushd feeds/luci
        curl -s https://$mirror/openwrt/patch/luci/luci-nftables.patch | patch -p1
    popd
fi

# FullCone module
git clone https://$gitea/sbwml/nft-fullcone package/new/nft-fullcone

# IPv6 NAT
git clone https://$github/sbwml/packages_new_nat6 package/new/nat6

# natflow
git clone https://$github/sbwml/package_new_natflow package/new/natflow

# Patch Luci add nft_fullcone/bcm_fullcone & shortcut-fe & natflow & ipv6-nat & custom nft command option
pushd feeds/luci
    curl -s https://$mirror/openwrt/patch/firewall4/0001-luci-app-firewall-add-nft-fullcone-and-bcm-fullcone-.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/firewall4/0002-luci-app-firewall-add-shortcut-fe-option.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/firewall4/0003-luci-app-firewall-add-ipv6-nat-option.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/firewall4/0004-luci-add-firewall-add-custom-nft-rule-support.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/firewall4/0005-luci-app-firewall-add-natflow-offload-support.patch | patch -p1
popd

# openssl - quictls
if [ "$version" = "rc2" ]; then
    rm -rf package/libs/openssl
    cp -a ../master/openwrt-23.05/package/libs/openssl package/libs/openssl
fi
pushd package/libs/openssl/patches
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0001-QUIC-Add-support-for-BoringSSL-QUIC-APIs.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0002-QUIC-New-method-to-get-QUIC-secret-length.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0003-QUIC-Make-temp-secret-names-less-confusing.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0004-QUIC-Move-QUIC-transport-params-to-encrypted-extensi.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0005-QUIC-Use-proper-secrets-for-handshake.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0006-QUIC-Handle-partial-handshake-messages.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0007-QUIC-Fix-quic_transport-constructors-parsers.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0008-QUIC-Reset-init-state-in-SSL_process_quic_post_hands.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0009-QUIC-Don-t-process-an-incomplete-message.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0010-QUIC-Quick-fix-s2c-to-c2s-for-early-secret.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0011-QUIC-Add-client-early-traffic-secret-storage.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0012-QUIC-Add-OPENSSL_NO_QUIC-wrapper.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0013-QUIC-Correctly-disable-middlebox-compat.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0014-QUIC-Move-QUIC-code-out-of-tls13_change_cipher_state.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0015-QUIC-Tweeks-to-quic_change_cipher_state.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0016-QUIC-Add-support-for-more-secrets.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0017-QUIC-Fix-resumption-secret.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0018-QUIC-Handle-EndOfEarlyData-and-MaxEarlyData.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0019-QUIC-Fall-through-for-0RTT.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0020-QUIC-Some-cleanup-for-the-main-QUIC-changes.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0021-QUIC-Prevent-KeyUpdate-for-QUIC.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0022-QUIC-Test-KeyUpdate-rejection.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0023-QUIC-Buffer-all-provided-quic-data.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0024-QUIC-Enforce-consistent-encryption-level-for-handsha.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0025-QUIC-add-v1-quic_transport_parameters.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0026-QUIC-return-success-when-no-post-handshake-data.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0027-QUIC-__owur-makes-no-sense-for-void-return-values.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0028-QUIC-remove-SSL_R_BAD_DATA_LENGTH-unused.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0029-QUIC-SSLerr-ERR_raise-ERR_LIB_SSL.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0030-QUIC-Add-compile-run-time-checking-for-QUIC.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0031-QUIC-Add-early-data-support.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0032-QUIC-Make-SSL_provide_quic_data-accept-0-length-data.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0033-QUIC-Process-multiple-post-handshake-messages-in-a-s.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0034-QUIC-Fix-CI.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0035-QUIC-Break-up-header-body-processing.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0036-QUIC-Don-t-muck-with-FIPS-checksums.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0037-QUIC-Update-RFC-references.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0038-QUIC-revert-white-space-change.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0039-QUIC-use-SSL_IS_QUIC-in-more-places.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0040-QUIC-Error-when-non-empty-session_id-in-CH.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0041-QUIC-Update-SSL_clear-to-clear-quic-data.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0042-QUIC-Better-SSL_clear.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0043-QUIC-Fix-extension-test.patch
    curl -sO https://$mirror/openwrt/patch/openssl/quic/0044-QUIC-Update-metadata-version.patch
popd

# openssl hwrng
if [ "$platform" = "rk3399" ] || [ "$platform" = "rk3568" ]; then
    sed -i "/-openwrt/iOPENSSL_OPTIONS += enable-ktls '-DDEVRANDOM=\"\\\\\"/dev/hwrng\\\\\"\"\'\n" package/libs/openssl/Makefile
else
    sed -i "/-openwrt/iOPENSSL_OPTIONS += enable-ktls '-DDEVRANDOM=\"\\\\\"/dev/urandom\\\\\"\"\'\n" package/libs/openssl/Makefile
fi
# openssl -Ofast
sed -i "s/-O3/-Ofast/g" package/libs/openssl/Makefile

# openssl - lto
if [ "$ENABLE_LTO" = "y" ]; then
    sed -i "s/ no-lto//g" package/libs/openssl/Makefile
    sed -i "/TARGET_CFLAGS +=/ s/\$/ -ffat-lto-objects/" package/libs/openssl/Makefile
fi

# nghttp3
rm -rf feeds/packages/libs/nghttp3
git clone https://$github/sbwml/package_libs_nghttp3 package/libs/nghttp3

# ngtcp2
rm -rf feeds/packages/libs/ngtcp2
git clone https://$github/sbwml/package_libs_ngtcp2 package/libs/ngtcp2

# curl - fix passwall `time_pretransfer` check
rm -rf feeds/packages/net/curl
git clone https://$github/sbwml/feeds_packages_net_curl feeds/packages/net/curl

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://$gitea/sbwml/luci-app-dockerman -b openwrt-23.05 feeds/luci/applications/luci-app-dockerman
if [ "$version" = "snapshots-23.05" ] || [ "$version" = "rc2" ]; then
    rm -rf feeds/packages/utils/{docker,dockerd,docker-compose,containerd,runc}
    git clone https://$github/sbwml/packages_utils_docker feeds/packages/utils/docker
    git clone https://$github/sbwml/packages_utils_dockerd feeds/packages/utils/dockerd
    git clone https://$github/sbwml/packages_utils_containerd feeds/packages/utils/containerd
    git clone https://$github/sbwml/packages_utils_runc feeds/packages/utils/runc
    cp -a ../master/packages/utils/docker-compose feeds/packages/utils/docker-compose
fi
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
pushd feeds/packages
    curl -s https://$mirror/openwrt/patch/docker/0001-dockerd-fix-bridge-network.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/docker/0002-docker-add-buildkit-experimental-support.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/docker/0003-dockerd-disable-ip6tables-for-bridge-network-by-defa.patch | patch -p1
popd

# cgroupfs-mount
# fix unmount hierarchical mount
pushd feeds/packages
    curl -s https://$mirror/openwrt/patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch | patch -p1
popd
# mount cgroup v2 hierarchy to /sys/fs/cgroup/cgroup2
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
curl -s https://$mirror/openwrt/patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch > feeds/packages/utils/cgroupfs-mount/patches/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch
curl -s https://$mirror/openwrt/patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch > feeds/packages/utils/cgroupfs-mount/patches/901-fix-cgroupfs-umount.patch
# docker systemd support
curl -s https://$mirror/openwrt/patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch > feeds/packages/utils/cgroupfs-mount/patches/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch

# procps-ng - top
sed -i 's/enable-skill/enable-skill --disable-modern-top/g' feeds/packages/utils/procps-ng/Makefile

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# UPnP
rm -rf feeds/packages/net/miniupnpd
git clone https://$gitea/sbwml/miniupnpd feeds/packages/net/miniupnpd -b v2.3.6
rm -rf feeds/luci/applications/luci-app-upnp
git clone https://$gitea/sbwml/luci-app-upnp feeds/luci/applications/luci-app-upnp
pushd feeds/packages
    curl -s https://$mirror/openwrt/patch/miniupnpd/01-set-presentation_url.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/miniupnpd/02-force_forwarding.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/miniupnpd/04-enable-force_forwarding-by-default.patch | patch -p1
popd

# UPnP - Move to network
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json

# nginx-util - fix gcc13
pushd feeds/packages
    curl -s https://$mirror/openwrt/nginx/nginx-util/0001-nginx-util-fix-compilation-with-GCC13.patch | patch -p1
    curl -s https://$mirror/openwrt/nginx/nginx-util/0002-nginx-util-move-to-pcre2.patch | patch -p1
popd

# nginx - latest version
rm -rf feeds/packages/net/nginx
git clone https://$github/sbwml/feeds_packages_net_nginx feeds/packages/net/nginx -b quic+zstd
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g;s/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/net/nginx/files/nginx.init

# nginx - ubus
sed -i 's/ubus_parallel_req 2/ubus_parallel_req 6/g' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 600;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support

# nginx - uwsgi timeout & enable brotli
curl -s https://$mirror/openwrt/nginx/luci.locations > feeds/packages/net/nginx/files-luci-support/luci.locations
curl -s https://$mirror/openwrt/nginx/uci.conf.template > feeds/packages/net/nginx-util/files/uci.conf.template

# zstd - bump version
rm -rf feeds/packages/utils/zstd
cp -a ../master/packages/utils/zstd feeds/packages/utils/zstd

# opkg
mkdir -p package/system/opkg/patches
curl -s https://$mirror/openwrt/patch/opkg/900-opkg-download-disable-hsts.patch > package/system/opkg/patches/900-opkg-download-disable-hsts.patch

# uwsgi - bump version
if [ "$version" = "snapshots-23.05" ] || [ "$version" = "rc2" ]; then
    rm -rf feeds/packages/net/uwsgi
    cp -a ../master/packages/net/uwsgi feeds/packages/net/uwsgi
fi

# uwsgi - fix timeout
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i '/limit-as/c\limit-as = 5000' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# disable error log
sed -i "s/procd_set_param stderr 1/procd_set_param stderr 0/g" feeds/packages/net/uwsgi/files/uwsgi.init

# uwsgi - performance
sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# rpcd - fix timeout
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

# luci-mod extra
pushd feeds/luci
    curl -s https://$mirror/openwrt/patch/luci/0001-luci-mod-system-add-modal-overlay-dialog-to-reboot.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/luci/0002-luci-mod-status-displays-actual-process-memory-usage.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/luci/0003-luci-mod-status-storage-index-applicable-only-to-val.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/luci/0004-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/luci/0005-luci-mod-system-add-refresh-interval-setting.patch | patch -p1
popd

# Luci diagnostics.js
sed -i "s/openwrt.org/www.qq.com/g" feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/diagnostics.js

# luci - drop ethernet port status
rm -f feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/29_ports.js

# luci - rollback dhcp.js
curl -s https://$mirror/openwrt/patch/luci/dhcp/dhcp.js > feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/dhcp.js

# luci - disable wireless WPA3
[ "$platform" = "bcm53xx" ] && sed -i -e '/if (has_ap_sae || has_sta_sae) {/{N;N;N;N;d;}' feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/wireless.js

# ppp - 2.5.0
rm -rf package/network/services/ppp
git clone https://$github/sbwml/package_network_services_ppp package/network/services/ppp

# odhcpd RFC-9096
mkdir -p package/network/services/odhcpd/patches
curl -s https://$mirror/openwrt/patch/odhcpd/001-odhcpd-RFC-9096-compliance.patch > package/network/services/odhcpd/patches/001-odhcpd-RFC-9096-compliance.patch
pushd feeds/luci
    curl -s https://$mirror/openwrt/patch/odhcpd/luci-mod-network-add-option-for-ipv6-max-plt-vlt.patch | patch -p1
popd

# urngd - 2020-01-21
rm -rf package/system/urngd
git clone https://$github/sbwml/package_system_urngd package/system/urngd

# zlib - 1.3
ZLIB_VERSION=1.3.1
ZLIB_HASH=38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32
sed -ri "s/(PKG_VERSION:=)[^\"]*/\1$ZLIB_VERSION/;s/(PKG_HASH:=)[^\"]*/\1$ZLIB_HASH/" package/libs/zlib/Makefile

# profile
sed -i 's#\\u@\\h:\\w\\\$#\\[\\e[32;1m\\][\\u@\\h\\[\\e[0m\\] \\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\[\\e[32;1m\\]]\\[\\e[0m\\]\\\$#g' package/base-files/files/etc/profile
sed -ri 's/(export PATH=")[^"]*/\1%PATH%:\/opt\/bin:\/opt\/sbin:\/opt\/usr\/bin:\/opt\/usr\/sbin/' package/base-files/files/etc/profile
sed -i '/PS1/a\export TERM=xterm-color' package/base-files/files/etc/profile

# bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
curl -so files/root/.bash_profile https://$mirror/openwrt/files/root/.bash_profile
curl -so files/root/.bashrc https://$mirror/openwrt/files/root/.bashrc

# rootfs files
mkdir -p files/etc/sysctl.d
curl -so files/etc/sysctl.d/15-vm-swappiness.conf https://$mirror/openwrt/files/etc/sysctl.d/15-vm-swappiness.conf
curl -so files/etc/sysctl.d/16-udp-buffer-size.conf https://$mirror/openwrt/files/etc/sysctl.d/16-udp-buffer-size.conf
if [ "$platform" = "bcm53xx" ]; then
    mkdir -p files/etc/hotplug.d/block
    curl -so files/etc/hotplug.d/block/20-usbreset https://$mirror/openwrt/files/etc/hotplug.d/block/20-usbreset
fi

# NTP
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate
