#!/bin/bash -e

#################################################################

# Rockchip - target - r4s/r5s
rm -rf target/linux/rockchip
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_rockchip-6.x target/linux/rockchip
[ "$platform" = "rk3568" ] && sed -i 's/CONFIG_PREEMPT=y/CONFIG_PREEMPT_DYNAMIC=y/g' target/linux/rockchip/armv8/config-6.1

# x86_64 - target
curl -s https://$mirror/openwrt/patch/openwrt-6.1/x86/64/config-6.1 > target/linux/x86/64/config-6.1
[ "$platform" = "x86_64" ] && echo "CONFIG_PREEMPT_DYNAMIC=y" >> target/linux/x86/64/config-6.1
curl -s https://$mirror/openwrt/patch/openwrt-6.1/x86/config-6.1 > target/linux/x86/config-6.1
mkdir -p target/linux/x86/patches-6.1
curl -s https://$mirror/openwrt/patch/openwrt-6.1/x86/patches-6.1/100-fix_cs5535_clockevt.patch > target/linux/x86/patches-6.1/100-fix_cs5535_clockevt.patch
curl -s https://$mirror/openwrt/patch/openwrt-6.1/x86/patches-6.1/103-pcengines_apu6_platform.patch > target/linux/x86/patches-6.1/103-pcengines_apu6_platform.patch
sed -i '/KERNEL_PATCHVER/a\KERNEL_TESTING_PATCHVER:=6.1' target/linux/x86/Makefile

# kernel - 6.x
curl -s https://$mirror/tags/kernel-6.1 > include/kernel-6.1

# kenrel Vermagic
sed -ie 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
grep HASH include/kernel-6.1 | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# kernel generic patches
git clone https://github.com/sbwml/target_linux_generic
rm -rf target/linux/generic/*-6.* target/linux/generic/files
mv target_linux_generic/target/linux/generic/* target/linux/generic/
rm -rf target_linux_generic

# kernel modules
rm -rf package/kernel/linux package/kernel/hwmon-gsc
git checkout package/kernel/linux
pushd package/kernel/linux/modules
    rm -f [a-z]*.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/block.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/can.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/crypto.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/firewire.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/fs.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/gpio-cascade.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/hwmon.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/i2c.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/iio.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/input.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/leds.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/lib.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/multiplexer.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/netdevices.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/netfilter.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/netsupport.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/nls.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/other.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/pcmcia.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/sound.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/spi.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/usb.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/video.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/virt.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/w1.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/wpan.mk
popd

# BBRv3 - linux-6.1
pushd target/linux/generic/backport-6.1
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0007-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0009-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0010-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0011-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0012-net-tcp_bbr-v2-record-app-limited-status-of-TLP-repa.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0013-net-tcp_bbr-v2-inform-CC-module-of-losses-repaired-b.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0014-net-tcp_bbr-v2-introduce-is_acking_tlp_retrans_seq-i.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0015-tcp-introduce-per-route-feature-RTAX_FEATURE_ECN_LOW.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0016-tcp-add-sysctls-for-TCP-PLB-parameters.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0017-tcp-add-PLB-functionality-for-TCP.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0018-net-tcp_bbr-v3-update-TCP-bbr-congestion-control-mod.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0019-net-tcp_bbr-v3-ensure-ECN-enabled-BBR-flows-set-ECT-.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr3_6.1/010-bbr3-0020-tcp-export-TCPI_OPT_ECN_LOW-in-tcp_info-tcpi_options.patch
popd

# LRNG v51 - linux-6.1
curl -s https://$mirror/openwrt/patch/kernel-6.1/config-lrng >> target/linux/generic/config-6.1
if [ "$platform" = "rk3399" ] || [ "$platform" = "rk3568" ]; then
    echo 'CONFIG_LRNG_HWRAND_IF=y' >> target/linux/generic/config-6.1
else
    echo '# CONFIG_LRNG_HWRAND_IF is not set' >> target/linux/generic/config-6.1
fi
pushd target/linux/generic/hack-6.1
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0003-LRNG-proc-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0005-LRNG-add-common-generic-hash-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0016-LRNG-CPU-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0017-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0018-LRNG-add-option-to-enable-runtime-entropy-rate-confi.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0019-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0020-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0021-LRNG-sysctls-and-proc-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0022-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0023-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0024-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/960-v51-0025-LRNG-add-hwrand-framework-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/961-v50-01-add_arch_get_random_longs_early.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v51_6.1/961-v50-02-revert_add_hwgenerator_randomness_update.patch
popd

# linux-firmware: rtw89 / rtl8723d / rtl8821c firmware
curl -s https://github.com/openwrt/openwrt/commit/145fc631e6205850a1c2f575abb3d15b0ce9995b.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/42bf7656730d5422e6022bae4d5df3ae2f6fa39b.patch | patch -p1

# rtl8812au-ct - fix linux-6.1
rm -rf package/kernel/rtl8812au-ct
cp -a ../master/openwrt/package/kernel/rtl8812au-ct package/kernel/rtl8812au-ct

# ath10k-ct - fix mac80211 6.1-rc
curl -s https://$mirror/openwrt/patch/openwrt-6.1/kmod-patches/ath10k-ct.patch | patch -p1

# mt76 - add mt7922 firmware
sed -i '/define KernelPackage\/mt7921-common/idefine KernelPackage\/mt7922-firmware\n  $(KernelPackage\/mt76-default)\n  DEPENDS+=+kmod-mt7921-common\n  TITLE:=MediaTek MT7922 firmware\nendef\n' package/kernel/mt76/Makefile
sed -i '/define Package\/mt76-test\/install/idefine KernelPackage\/mt7922-firmware\/install\n\t$(INSTALL_DIR) $(1)\/lib\/firmware\/mediatek\n\tcp \\\n\t\t$(PKG_BUILD_DIR)\/firmware\/WIFI_MT7922_patch_mcu_1_1_hdr.bin \\\n\t\t$(PKG_BUILD_DIR)\/firmware\/WIFI_RAM_CODE_MT7922_1.bin \\\n\t\t$(1)\/lib\/firmware\/mediatek\nendef\n' package/kernel/mt76/Makefile
sed -i '/$(eval \$(call KernelPackage,mt7921-firmware))/a $(eval \$(call KernelPackage,mt7922-firmware))' package/kernel/mt76/Makefile

# iwinfo: add mt7922 device id
mkdir -p package/network/utils/iwinfo/patches
curl -s https://$mirror/openwrt/patch/openwrt-6.1/iwinfo/0001-devices-add-MediaTek-MT7922-device-id.patch > package/network/utils/iwinfo/patches/0001-devices-add-MediaTek-MT7922-device-id.patch

# iwinfo: add rtl8812/14/21au devices
curl -s https://$mirror/openwrt/patch/openwrt-6.1/iwinfo/0004-add-rtl8812au-devices.patch > package/network/utils/iwinfo/patches/0004-add-rtl8812au-devices.patch

# wireless-regdb
curl -s https://$mirror/openwrt/patch/openwrt-6.1/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch

# mac80211 - fix linux 6.1
rm -rf package/kernel/mac80211
cp -a ../master/openwrt/package/kernel/mac80211 package/kernel/mac80211

# mac80211 - add rtw89
curl -s https://github.com/openwrt/openwrt/commit/11003cfd1a80fc63d354433d2449ee41879c7748.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/c7323f2dc9449ed38446400535e3212fdf777439.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/775802f81bdf98ba270583010a34f45b9ecf1ef7.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/c6a2f99275adeb57226504b5de6f68082aca7c93.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/390a2ff20f9af9e22a48cd9ebde513d616bea840.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/1c726bfea3d2f0ffbc90c486e5dffc45020c101e.patch | patch -p1

# kernel patch
# cpu model
curl -s https://$mirror/openwrt/patch/kernel-6.1/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/pending-6.1/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# fullcone
curl -s https://$mirror/openwrt/patch/kernel-6.1/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-6.1/952-net-conntrack-events-support-multiple-registrant.patch
# logs
curl -s https://$mirror/openwrt/patch/kernel-6.1/998-hide-panfrost-logs.patch > target/linux/generic/hack-6.1/998-hide-panfrost-logs.patch

# Shortcut-FE - linux-6.1
curl -s https://$mirror/openwrt/patch/kernel-6.1/shortcut-fe/953-net-patch-linux-kernel-to-support-shortcut-fe.patch > target/linux/generic/hack-6.1/953-net-patch-linux-kernel-to-support-shortcut-fe.patch

# ubnt-ledbar - fix linux-6.1
rm -rf package/kernel/ubnt-ledbar
cp -a ../master/openwrt/package/kernel/ubnt-ledbar package/kernel/ubnt-ledbar

# RTC
if [ "$platform" = "rk3399" ] || [ "$platform" = "rk3568" ]; then
    curl -s https://$mirror/openwrt/patch/rtc/sysfixtime > package/base-files/files/etc/init.d/sysfixtime
    chmod 755 package/base-files/files/etc/init.d/sysfixtime
fi

# Fix BPF Type Format - Linux-6.1 GCC11
if [ "$ENABLE_BPF" = "y" ]; then
    sed -i "s/CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y/# CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT is not set/g" target/linux/generic/config-6.1
    sed -i "s/# CONFIG_DEBUG_INFO_DWARF4 is not set/CONFIG_DEBUG_INFO_DWARF4=y/g" target/linux/generic/config-6.1
fi
