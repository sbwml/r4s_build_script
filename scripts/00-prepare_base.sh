#!/bin/bash -e

#################################################################

# Rockchip - target
rm -rf target/linux/rockchip
if [ "$version" = "releases" ] || [ "$version" = "snapshots-21.02" ]; then
	git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_rockchip -b 21.02 target/linux/rockchip
fi

# Rockchip - rkbin & u-boot 2022.04
rm -rf package/boot/uboot-rockchip
git clone https://$gitea/sbwml/package_boot_uboot-rockchip package/boot/uboot-rockchip
git clone https://$gitea/sbwml/arm-trusted-firmware-rockchip-vendor package/boot/arm-trusted-firmware-rockchip-vendor
if [ "$soc" = "r5s" ]; then
    git clone https://$gitea/sbwml/package_boot_uboot-rk356x package/boot/uboot-rk356x
    git clone https://$gitea/sbwml/arm-trusted-firmware-rk356x package/boot/arm-trusted-firmware-rk356x
fi

# Fix
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    curl -s https://$mirror/openwrt/patch/kernel-5.10/config-5.10 > target/linux/generic/config-5.10
    curl -s https://$mirror/openwrt/patch/kernel_modules/5.10-video.mk > package/kernel/linux/modules/video.mk
    if [ "$soc" = "x86" ]; then
        echo "CONFIG_CRYPTO_AES_NI_INTEL=y" >> target/linux/x86/config-5.10
        echo '# CONFIG_DVB_USB is not set' >> target/linux/x86/config-5.10
        sed -i 's/hwmon, +PACKAGE_kmod-thermal:kmod-thermal/hwmon/g' package/kernel/linux/modules/hwmon.mk
    fi
else
    curl -s https://$mirror/openwrt/patch/kernel_modules/5.4-video.mk > package/kernel/linux/modules/video.mk
    if [ "$soc" = "x86" ]; then
        echo "CONFIG_CRYPTO_AES_NI_INTEL=y" >> target/linux/x86/config-5.4
    fi
fi

# tools: fix PKG_SOURCE - openwrt-22.03.3
if [ "$version" = "rc" ]; then
    rm -rf tools/dosfstools
    cp -a ../master/openwrt/tools/dosfstools tools/dosfstools
    rm -rf tools/fakeroot
    cp -a ../master/openwrt/tools/fakeroot tools/fakeroot
    rm -rf tools/mtd-utils
    cp -a ../master/openwrt/tools/mtd-utils tools/mtd-utils
fi

#################################################################

# default LAN IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# Drop uhttpd deps
sed -i 's/+uhttpd //' feeds/luci/collections/luci/Makefile
sed -i 's/+uhttpd-mod-ubus //' feeds/luci/collections/luci/Makefile
sed -i 's/+uhttpd //' feeds/luci/collections/luci-light/Makefile

# NIC driver - x86
if [ "$soc" = "x86" ]; then
    # r8101
    git clone https://github.com/sbwml/package_kernel_r8101 package/kernel/r8101
fi
# R8168 & R8125 & R8152
git clone https://github.com/sbwml/package_kernel_r8168 package/kernel/r8168
git clone https://github.com/sbwml/package_kernel_r8125 package/kernel/r8125
git clone https://github.com/sbwml/package_kernel_r8152 package/kernel/r8152

# Wireless Drivers
rm -rf package/kernel/rtl8812au-ct
git clone https://github.com/sbwml/openwrt-wireless-drivers package/kernel/wireless
if [ "$version" = "releases" ] || [ "$version" = "snapshots-21.02" ]; then
    rm -rf package/kernel/wireless/rtl88x2bu
    git clone https://$gitea/sbwml/rtl88x2bu package/kernel/rtl88x2bu
else
    # hostapd: make LAR-friendly AP mode for AX200/AX210
    curl -s https://$mirror/openwrt/patch/hostapd-22.03/999-hostapd-2.10-lar.patch > package/network/services/hostapd/patches/999-hostapd-2.10-lar.patch
    # hostapd: hack version
    sed -ri "s/(PKG_RELEASE:=)[^\"]*/\199.2/" package/network/services/hostapd/Makefile
fi

# Optimization level -Ofast
if [ "$soc" = "rk3328" ]; then
    curl -s https://$mirror/openwrt/patch/target-modify_for_rk3328.patch | patch -p1
elif [ "$soc" = "rk3399" ]; then
    curl -s https://$mirror/openwrt/patch/target-modify_for_rk3399.patch | patch -p1
elif [ "$soc" = "rk3568" ] || [ "$soc" = "r5s" ]; then
    curl -s https://$mirror/openwrt/patch/target-modify_for_rk3568.patch | patch -p1
fi

# IF USE GLIBC
if [ "$USE_GLIBC" = "y" ]; then
    # O3 optimization
    git checkout include/target.mk && \
        curl -s https://$mirror/openwrt/patch/target-modify_for_glibc.patch | patch -p1
    # musl-libc
    git clone https://$gitea/sbwml/package_libs_musl-libc package/libs/musl-libc
    # bump fstools version
    rm -rf package/system/fstools
    cp -a ../master/openwrt/package/system/fstools package/system/fstools
    # glibc-common
    curl -s https://$mirror/openwrt/patch/openwrt-6.1/toolchain/glibc-common.patch | patch -p1
    # locale data
    mkdir -p files/lib/locale
    curl -so files/lib/locale/locale-archive https://us.cooluc.com/gnu-locale/locale-archive
    [ "$?" -ne 0 ] && echo -e "${RED_COLOR} Locale file download failed... ${RES}"
    # GNU LANG
    mkdir package/base-files/files/etc/profile.d
    echo 'export LANG="en_US.UTF-8" I18NPATH="/usr/share/i18n"' > package/base-files/files/etc/profile.d/sys_locale.sh
fi

# Mbedtls AES & GCM Crypto Extensions
if [ ! "$soc" = "x86" ]; then
    if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
       curl -s https://$mirror/openwrt/patch/mbedtls-5.10/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch > package/libs/mbedtls/patches/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch
    else
       curl -s https://$mirror/openwrt/patch/mbedtls/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch > package/libs/mbedtls/patches/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch
    fi
    curl -s https://$mirror/openwrt/patch/mbedtls/mbedtls.patch | patch -p1
fi

# NTFS3
mkdir -p package/system/fstools/patches
curl -s https://$mirror/openwrt/patch/fstools/ntfs3.patch > package/system/fstools/patches/ntfs3.patch
curl -s https://$mirror/openwrt/patch/util-linux/util-linux_ntfs3.patch > package/utils/util-linux/patches/util-linux_ntfs3.patch
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    curl -s https://$mirror/openwrt/patch/ntfs3-5.10/997-fs-ntfs3-Add-paragon-ntfs3-driver.patch > target/linux/generic/hack-5.10/997-fs-ntfs3-Add-paragon-ntfs3-driver.patch
    curl -s https://$mirror/openwrt/patch/ntfs3-5.10/22.03-add-ntfs3-support.patch | patch -p1
else
    curl -s https://$mirror/openwrt/patch/ntfs3-5.4/997-fs-ntfs3-Add-paragon-ntfs3-driver.patch > target/linux/generic/hack-5.4/997-fs-ntfs3-Add-paragon-ntfs3-driver.patch
    curl -s https://$mirror/openwrt/patch/ntfs3-5.4/21.02-add-ntfs3-support.patch | patch -p1
fi

# fstools - enable any device with non-MTD rootfs_data volume
curl -s https://$mirror/openwrt/patch/fstools/block-mount-add-fstools-depends.patch | patch -p1
if [ "$USE_GLIBC" = "y" ]; then
    curl -s https://$mirror/openwrt/patch/fstools/fstools-set-ntfs3-utf8-new.patch > package/system/fstools/patches/ntfs3-utf8.patch
    curl -s https://$mirror/openwrt/patch/fstools/glibc/0001-libblkid-tiny-add-support-for-XFS-superblock.patch > package/system/fstools/patches/0001-libblkid-tiny-add-support-for-XFS-superblock.patch
    curl -s https://$mirror/openwrt/patch/fstools/glibc/0002-libblkid-tiny-add-support-for-exFAT-superblock.patch > package/system/fstools/patches/0002-libblkid-tiny-add-support-for-exFAT-superblock.patch
    curl -s https://$mirror/openwrt/patch/fstools/glibc/0003-block-add-xfsck-support.patch > package/system/fstools/patches/0003-block-add-xfsck-support.patch
else
    curl -s https://$mirror/openwrt/patch/fstools/ntfs3-utf8.patch > package/system/fstools/patches/ntfs3-utf8.patch
fi
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    if [ "$USE_GLIBC" = "y" ]; then
        curl -s https://$mirror/openwrt/patch/fstools/22-fstools-support-extroot-for-non-MTD-rootfs_data-new-version.patch > package/system/fstools/patches/22-fstools-support-extroot-for-non-MTD-rootfs_data.patch
    else
        curl -s https://$mirror/openwrt/patch/fstools/22-fstools-support-extroot-for-non-MTD-rootfs_data.patch > package/system/fstools/patches/22-fstools-support-extroot-for-non-MTD-rootfs_data.patch
    fi
else
    curl -s https://$mirror/openwrt/patch/fstools/21-fstools-support-extroot-for-non-MTD-rootfs_data.patch > package/system/fstools/patches/21-fstools-support-extroot-for-non-MTD-rootfs_data.patch
fi

# QEMU for aarch64
pushd feeds/packages
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    curl -s https://$mirror/openwrt/patch/qemu/qemu-aarch64_master.patch > qemu-aarch64.patch
else
    curl -s https://$mirror/openwrt/patch/qemu/qemu-aarch64_21.02.patch > qemu-aarch64.patch
fi
git apply qemu-aarch64.patch && rm qemu-aarch64.patch
popd

# KVM
if [ "$version" = "releases" ] || [ "$version" = "snapshots-21.02" ]; then
    cat >> target/linux/rockchip/config-default <<EOF
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_ARM_HOST=y
CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
CONFIG_KVM_INDIRECT_VECTORS=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_VFIO=y
CONFIG_VHOST_NET=y
EOF
fi

# util-linux
if [ "$version" = "releases" ] || [ "$version" = "snapshots-21.02" ]; then
    curl -s https://$mirror/openwrt/patch/util-linux/util-linux-2.38.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/util-linux/util-linux_taskset.patch | patch -p1
fi

# Patch arm64 model name
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    curl -s https://$mirror/openwrt/patch/kernel-5.10/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/hack-5.10/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
else
    curl -s https://$mirror/openwrt/patch/kernel/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/pending-5.4/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
fi

# Dnsmasq
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    # Dnsmasq Latest version
    DNSMASQ_VERSION=2.89
    DNSMASQ_HASH=02bd230346cf0b9d5909f5e151df168b2707103785eb616b56685855adebb609
    rm -rf package/network/services/dnsmasq
    cp -a ../master/openwrt/package/network/services/dnsmasq package/network/services/dnsmasq
    sed -ri "s/(PKG_UPSTREAM_VERSION:=)[^\"]*/\1$DNSMASQ_VERSION/;s/(PKG_HASH:=)[^\"]*/\1$DNSMASQ_HASH/" package/network/services/dnsmasq/Makefile
    curl -s https://$mirror/openwrt/patch/dnsmasq-5.10/luci-add-filter-aaaa-option.patch | patch -p1
else
    curl -s https://$mirror/openwrt/patch/dnsmasq/dnsmasq-add-filter-aaaa-option.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/dnsmasq/luci-add-filter-aaaa-option.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/dnsmasq/900-add-filter-aaaa-option.patch > package/network/services/dnsmasq/patches/900-add-filter-aaaa-option.patch
fi

# Patch FireWall - FullCone
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    # firewall4
    rm -rf package/network/config/firewall4
    cp -a ../master/openwrt/package/network/config/firewall4 package/network/config/firewall4
    mkdir -p package/network/config/firewall4/patches
    curl -s https://$mirror/openwrt/patch/firewall4/999-01-firewall4-add-fullcone-support.patch > package/network/config/firewall4/patches/999-01-firewall4-add-fullcone-support.patch
    # kernel version
    curl -s https://$mirror/openwrt/patch/firewall4/002-fix-fw4.uc-adept-kernel-version-type-of-x.x.patch > package/network/config/firewall4/patches/002-fix-fw4.uc-adept-kernel-version-type-of-x.x.patch
    # libnftnl
    rm -rf package/libs/libnftnl
    cp -a ../master/openwrt/package/libs/libnftnl package/libs/libnftnl
    mkdir -p package/libs/libnftnl/patches
    curl -s https://$mirror/openwrt/patch/firewall4/libnftnl/001-libnftnl-add-fullcone-expression-support.patch > package/libs/libnftnl/patches/001-libnftnl-add-fullcone-expression-support.patch
    sed -i '/PKG_INSTALL:=1/iPKG_FIXUP:=autoreconf' package/libs/libnftnl/Makefile
    # nftables
    rm -rf package/network/utils/nftables
    cp -a ../master/openwrt/package/network/utils/nftables package/network/utils/nftables
    mkdir -p package/network/utils/nftables/patches
    curl -s https://$mirror/openwrt/patch/firewall4/nftables/002-nftables-add-fullcone-expression-support.patch > package/network/utils/nftables/patches/002-nftables-add-fullcone-expression-support.patch
    # hide nftables warning message
    pushd feeds/luci
        curl -s https://$mirror/openwrt/patch/luci/luci-nftables.patch | patch -p1
    popd
else
    # firewall3
    mkdir -p package/network/config/firewall/patches
    curl -s https://$mirror/openwrt/patch/firewall/fullconenat.patch > package/network/config/firewall/patches/fullconenat.patch
fi

# Patch Kernel - FullCone
if [ "$version" = "rc" ]; then
    curl -s https://$mirror/openwrt/patch/kernel-5.10/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch
elif [ "$version" = "snapshots-22.03" ]; then
    curl -s https://$mirror/openwrt/patch/kernel-5.10/22-952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch
else
    curl -s https://$mirror/openwrt/patch/kernel/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
fi

# Patch FullCone Option  21/22
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    curl -s https://$mirror/openwrt/patch/firewall4/luci-app-firewall_add_fullcone.patch | patch -p1
else
    curl -s https://$mirror/openwrt/patch/firewall/luci-app-firewall_add_fullcone.patch | patch -p1
fi

# FullCone module
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    git clone https://$gitea/sbwml/nft-fullcone package/new/nft-fullcone
else
    git clone https://$gitea/sbwml/fullconenat package/network/fullconenat
fi

# TCP performance optimizations backport from linux/net-next
if [ ! "$version" = "rc" ] && [ ! "$version" = "snapshots-22.03" ]; then
    curl -s https://$mirror/openwrt/patch/backport/695-tcp-optimizations.patch > target/linux/generic/backport-5.4/695-tcp-optimizations.patch
else
    curl -s https://$mirror/openwrt/patch/backport-5.10/780-v5.17-tcp-defer-skb-freeing-after-socket-lock-is-released.patch > target/linux/generic/backport-5.10/780-v5.17-tcp-defer-skb-freeing-after-socket-lock-is-released.patch
fi

# MGLRU
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
  pushd target/linux/generic/pending-5.10
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-00-BACKPORT-mmvmscan.c-use-add_page_to_lru_list().patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-01-BACKPORT-includelinuxmm_inline.h-shuffle-lru-list-addition-and-deletion-functions.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-02-BACKPORT-mm-don't-pass-enum-lru_list-to-lru-list-addition-functions.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-03-UPSTREAM-mmswap.c-don't-pass-enum-lru_list-to-trace_mm_lru_insertion().patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-04-BACKPORT-mmswap.c-don't-pass-enum-lru_list-to-del_page_from_lru_list().patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-05-BACKPORT-mm-add-__clear_page_lru_flags()-to-replace-page_off_lru().patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-06-BACKPORT-mm-VM_BUG_ON-lru-page-flags.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-07-UPSTREAM-includelinuxmm_inline.h-fold-page_lru_base_type()-into-its-sole-caller.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-08-UPSTREAM-mmswap-don't-SetPageWorkingset-unconditionally-during-swapin.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-09-UPSTREAM-includelinuxpage-flags-layout.h-correctly-determine-LAST_CPUPID_WIDTH.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-10-UPSTREAM-includelinuxpage-flags-layout.h-cleanups.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-11-FROMLIST-mm-x86,-arm64-add-arch_has_hw_pte_young().patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-12-FROMLIST-mm-x86-add-CONFIG_ARCH_HAS_NONLEAF_PMD_YOUNG.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-13-FROMLIST-mmvmscan.c-refactor-shrink_node().patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-14-FROMLIST-mm-multi-gen-LRU-groundwork.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-15-FROMLIST-mm-multi-gen-LRU-minimal-implementation.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-16-FROMLIST-mm-multi-gen-LRU-exploit-locality-in-rmap.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-17-FROMLIST-mm-multi-gen-LRU-support-page-table-walks.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-18-FROMLIST-mm-multi-gen-LRU-optimize-multiple-memcgs.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-19-FROMLIST-mm-multi-gen-LRU-kill-switch.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-20-FROMLIST-mm-multi-gen-LRU-thrashing-prevention.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-21-FROMLIST-mm-multi-gen-LRU-debugfs-interface.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-22-FROMLIST-mm-multi-gen-LRU-admin-guide.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel-5.10/MGLRU/020-23-FROMLIST-mm-multi-gen-LRU-design-doc.patch"
  popd
  cat >> target/linux/generic/config-5.10 <<"EOF"
CONFIG_LRU_GEN=y
CONFIG_LRU_GEN_ENABLED=y
# CONFIG_LRU_GEN_STATS is not set
EOF
else
  pushd target/linux/generic/backport-5.4
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-01-UPSTREAM-mm-vmscan.c-use-update_lru_size-in-update_l.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-02-BACKPORT-mm-remove-superfluous-__ClearPageActive.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-03-BACKPORT-mm-use-self-explanatory-macros-rather-than-.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-04-BACKPORT-mm-vmscan.c-use-add_page_to_lru_list.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-05-BACKPORT-include-linux-mm_inline.h-shuffle-lru-list-.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-06-BACKPORT-mm-don-t-pass-enum-lru_list-to-lru-list-add.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-07-UPSTREAM-mm-swap.c-don-t-pass-enum-lru_list-to-trace.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-08-BACKPORT-mm-swap.c-don-t-pass-enum-lru_list-to-del_p.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-09-BACKPORT-mm-add-__clear_page_lru_flags-to-replace-pa.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-10-UPSTREAM-mm-VM_BUG_ON-lru-page-flags.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-11-BACKPORT-include-linux-mm_inline.h-fold-page_lru_bas.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-12-UPSTREAM-include-linux-mm_inline.h-fold-__update_lru.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-13-BACKPORT-mm-swapcache-support-to-handle-the-shadow-e.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-14-BACKPORT-FROMLIST-include-linux-mm.h-do-not-warn-in-.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-15-FROMLIST-include-linux-nodemask.h-define-next_memory.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-16-FROMLIST-include-linux-cgroup.h-export-cgroup_mutex.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-17-BACKPORT-FROMLIST-mm-x86-support-the-access-bit-on-n.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-18-FROMLIST-mm-workingset.c-refactor-pack_shadow-and-un.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-19-BACKPORT-FROMLIST-mm-multigenerational-lru-groundwor.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-20-BACKPORT-FROMLIST-mm-multigenerational-lru-activatio.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-21-BACKPORT-FROMLIST-mm-multigenerational-lru-mm_struct.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-22-BACKPORT-FROMLIST-mm-multigenerational-lru-aging.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-23-BACKPORT-FROMLIST-mm-multigenerational-lru-eviction.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-24-BACKPORT-FROMLIST-mm-multigenerational-lru-user-inte.patch"
    curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-25-BACKPORT-FROMLIST-mm-multigenerational-lru-Kconfig.patch"
    if [ "$version" = "releases" ]; then
      curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-26-CHROMIUM-mm-multigenerational-lru-add-arch_has_hw_pt.patch"
    else
      curl -sO "https://$mirror/openwrt/patch/kernel/MGLRU/020-26-new-CHROMIUM-mm-multigenerational-lru-add-arch_has_hw_pt.patch"
    fi
  popd
  cat >> target/linux/generic/config-5.4 <<"EOF"
CONFIG_LRU_GEN=y
CONFIG_LRU_GEN_ENABLED=y
# CONFIG_LRU_GEN_STATS is not set
CONFIG_NR_LRU_GENS=7
CONFIG_TIERS_PER_GEN=4
EOF
fi

# OpenSSL
sed -i "s/O3/Ofast/g" package/libs/openssl/Makefile
curl -s https://$mirror/openwrt/patch/openssl/11895.patch > package/libs/openssl/patches/11895.patch
curl -s https://$mirror/openwrt/patch/openssl/14578.patch > package/libs/openssl/patches/14578.patch
curl -s https://$mirror/openwrt/patch/openssl/16575.patch > package/libs/openssl/patches/16575.patch
curl -s https://$mirror/openwrt/patch/openssl/999-Ofast.patch > package/libs/openssl/patches/999-Ofast.patch
if [ "$version" = "stable" ] || [ "$version" = "dev" ]; then
    curl -s https://$mirror/openwrt/patch/openssl/600-eng_dyn-Avoid-spurious-errors-when-checking-for-3.x-engine.patch > package/libs/openssl/patches/600-eng_dyn-Avoid-spurious-errors-when-checking-for-3.x-engine.patch
fi

# enable cryptodev
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    curl -s https://$mirror/openwrt/patch/openssl/22-openssl_cryptodev.patch | patch -p1
else
    curl -s https://$mirror/openwrt/patch/openssl/21-openssl_cryptodev.patch | patch -p1
fi

# SQM Translation
mkdir -p feeds/packages/net/sqm-scripts/patches
curl -s https://$mirror/openwrt/patch/sqm/001-help-translation.patch > feeds/packages/net/sqm-scripts/patches/001-help-translation.patch

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://$gitea/sbwml/luci-app-dockerman -b master feeds/luci/applications/luci-app-dockerman
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    pushd feeds/packages
        curl -s https://$mirror/openwrt/patch/docker/dockerd-fix-bridge-network.patch | patch -p1
    popd
fi
pushd feeds/packages
    curl -s https://$mirror/openwrt/patch/docker/0001-dockerd-defer-starting-docker-service.patch | patch -p1
popd

# procps-ng - top
sed -i 's/enable-skill/enable-skill --disable-modern-top/g' feeds/packages/utils/procps-ng/Makefile

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json

# UPnP - fix 22.03
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    rm -rf feeds/packages/net/miniupnpd
    git clone https://$gitea/sbwml/miniupnpd feeds/packages/net/miniupnpd
    rm -rf feeds/luci/applications/luci-app-upnp
    git clone https://$gitea/sbwml/luci-app-upnp feeds/luci/applications/luci-app-upnp
    pushd feeds/packages
        curl -s https://$mirror/openwrt/patch/miniupnpd/1.patch | patch -p1
        curl -s https://$mirror/openwrt/patch/miniupnpd/2.patch | patch -p1
        curl -s https://$mirror/openwrt/patch/miniupnpd/3.patch | patch -p1
        curl -s https://$mirror/openwrt/patch/miniupnpd/4.patch | patch -p1
    popd
fi

# UPnP - Move to network
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json

# iproute2 - fix build with glibc
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    curl -s https://github.com/openwrt/openwrt/commit/fb15cb4ce9559021d463b5cb3816d8a9eeb8f3f9.patch | patch -p1
fi

# nginx - latest version
rm -rf feeds/packages/net/nginx
git clone https://github.com/sbwml/feeds_packages_net_nginx feeds/packages/net/nginx
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g;s/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/net/nginx/files/nginx.init

# nginx - ubus
sed -i 's/ubus_parallel_req 2/ubus_parallel_req 6/g' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 600;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support

# nginx - uwsgi timeout & enable brotli
curl -s https://$mirror/openwrt/nginx/luci.locations > feeds/packages/net/nginx/files-luci-support/luci.locations
curl -s https://$mirror/openwrt/nginx/uci.conf.template > feeds/packages/net/nginx-util/files/uci.conf.template

# uwsgi - fix timeout
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i '/limit-as/c\limit-as = 5000' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# disable error log
sed -i "s/procd_set_param stderr 1/procd_set_param stderr 0/g" feeds/packages/net/uwsgi/files/uwsgi.init

# rpcd bump version
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ] && [ "$soc" != "x86" ]; then
    rm -rf package/system/rpcd
    cp -a ../master/openwrt/package/system/rpcd package/system/rpcd
fi

# rpcd - fix timeout
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

# luci - 20_memory
curl -s https://$mirror/openwrt/patch/luci/20_memory.js.patch | patch -p1

# Luci refresh interval
curl -s https://$mirror/openwrt/patch/luci/luci-refresh-interval.patch | patch -p1

# Luci ui.js
curl -s https://$mirror/openwrt/patch/luci/upload-ui.js.patch | patch -p1

# samba4 default permissions
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    rm -rf feeds/packages/net/samba4
    cp -a ../master/packages/net/samba4 feeds/packages/net/samba4
    # enable multi-channel
    sed -i "/workgroup/a\ \n\ \t## enable multi-channel" feeds/packages/net/samba4/files/smb.conf.template
    sed -i "/enable multi-channel/a\ \tmultichannel server support = yes" feeds/packages/net/samba4/files/smb.conf.template
fi
sed -i 's/invalid users = root/#invalid users = root/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#create mask/create mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#directory mask/directory mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/0666/0644/g;s/0744/0755/g;s/0777/0755/g' feeds/luci/applications/luci-app-samba4/htdocs/luci-static/resources/view/samba4.js
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/samba.config
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/smb.conf.template

# Max connection limite
[ "$version" = "releases" ] || [ "$version" = "snapshots-21.02" ] && sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

# profile
sed -i 's#\\u@\\h:\\w\\\$#\\[\\e[32;1m\\][\\u@\\h\\[\\e[0m\\] \\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\[\\e[32;1m\\]]\\[\\e[0m\\]\\\$#g' package/base-files/files/etc/profile
sed -ri 's/(export PATH=")[^"]*/\1%PATH%:\/opt\/bin:\/opt\/sbin:\/opt\/usr\/bin:\/opt\/usr\/sbin/' package/base-files/files/etc/profile

# bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
curl -so files/root/.bash_profile https://$mirror/openwrt/files/root/.bash_profile
curl -so files/root/.bashrc https://$mirror/openwrt/files/root/.bashrc
