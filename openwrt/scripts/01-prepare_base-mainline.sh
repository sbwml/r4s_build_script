#!/bin/bash -e

#################################################################

# Rockchip - target - r4s/r5s
rm -rf target/linux/rockchip
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_rockchip-6.x target/linux/rockchip

# kernel - 6.x
curl -s https://$mirror/tags/kernel-6.1 > include/kernel-6.1
grep HASH include/kernel-6.1 | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# kernel generic patches
git clone https://github.com/sbwml/target_linux_generic
rm -rf target/linux/generic/*-6.* target/linux/generic/files
mv target_linux_generic/target/linux/generic/* target/linux/generic/
rm -rf target_linux_generic

# kernel modules
rm -rf package/kernel/linux package/kernel/hwmon-gsc
git checkout package/kernel/linux
[ "$version" = "rc" ] && curl -s https://$mirror/openwrt/patch/openwrt-6.1/include_netfilter.patch | patch -p1
curl -s https://$mirror/openwrt/patch/openwrt-6.1/files/sysctl-tcp-bbr2.conf > package/kernel/linux/files/sysctl-tcp-bbr2.conf
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

# BBRv2 - linux-6.1
pushd target/linux/generic/backport-6.1
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0007-net-tcp_bbr-v2-factor-out-tx.in_flight-setting-into-.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0009-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0010-net-tcp_bbr-v2-set-tx.in_flight-for-skbs-in-repair-w.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0011-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0012-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0013-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0014-net-tcp_bbr-v2-BBRv2-bbr2-congestion-control-for-Lin.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0015-net-test-add-.config-for-kernel-circa-v5.10-with-man.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0016-net-test-adds-a-gce-install.sh-script-to-build-and-i.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0017-net-test-scripts-for-testing-bbr2-with-upstream-Linu.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0018-net-tcp_bbr-v2-add-a-README.md-for-TCP-BBR-v2-alpha-.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0019-net-tcp_bbr-v2-remove-unnecessary-rs.delivered_ce-lo.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0020-net-gbuild-add-Gconfig.bbr2-to-gbuild-kernel-with-CO.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0021-net-tcp_bbr-v2-remove-field-bw_rtts-that-is-unused-i.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0022-net-tcp_bbr-v2-remove-cycle_rand-parameter-that-is-u.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0023-net-test-use-crt-namespace-when-nsperf-disables-crt..patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0024-net-tcp_bbr-v2-don-t-assume-prior_cwnd-was-set-enter.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0025-net-tcp_bbr-v2-Fix-missing-ECT-markings-on-retransmi.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0026-net-tcp_bbr-v2-add-support-for-PLB-in-TCP-and-BBRv2.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.1/0027-net-test-tcp-plb-Add-PLB-tests.patch
popd

# LRNG v48 - linux-6.1
curl -s https://$mirror/openwrt/patch/kernel-6.1/config-lrng >> target/linux/generic/config-6.1
pushd target/linux/generic/hack-6.1
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0003-LRNG-proc-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0005-LRNG-add-common-generic-hash-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0016-LRNG-CPU-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0017-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0018-LRNG-add-option-to-enable-runtime-entropy-rate-confi.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0019-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0020-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0021-LRNG-sysctls-and-proc-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0022-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0023-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0024-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/960-v50-0025-LRNG-add-hwrand-framework-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/961-v50-01-add_arch_get_random_longs_early.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng_v50_6.1/961-v50-02-revert_add_hwgenerator_randomness_update.patch
popd

# linux-firmware
if [ "$version" = "rc" ]; then
    rm -rf package/firmware/linux-firmware
    git clone https://nanopi:nanopi@$gitea/sbwml/package_firmware_linux-firmware package/firmware/linux-firmware
else
    # rtw89 /  rtl8723d / rtl8821c firmware
    curl -s https://github.com/openwrt/openwrt/commit/145fc631e6205850a1c2f575abb3d15b0ce9995b.patch | patch -p1
    curl -s https://github.com/openwrt/openwrt/commit/42bf7656730d5422e6022bae4d5df3ae2f6fa39b.patch | patch -p1
fi

# rtl8812au-ct - fix linux-6.1
rm -rf package/kernel/rtl8812au-ct
cp -a ../master/openwrt/package/kernel/rtl8812au-ct package/kernel/rtl8812au-ct

# ath10k-ct - fix mac80211 6.1-rc
if [ "$version" = "rc" ]; then
    rm -rf package/kernel/ath10k-ct
    cp -a ../master/openwrt/package/kernel/ath10k-ct package/kernel/ath10k-ct
fi
curl -s https://$mirror/openwrt/patch/openwrt-6.1/kmod-patches/ath10k-ct.patch | patch -p1

# mt76 - add mt7922 firmware
sed -i '/define KernelPackage\/mt7921-common/idefine KernelPackage\/mt7922-firmware\n  $(KernelPackage\/mt76-default)\n  DEPENDS+=+kmod-mt7921-common\n  TITLE:=MediaTek MT7922 firmware\nendef\n' package/kernel/mt76/Makefile
sed -i '/define Package\/mt76-test\/install/idefine KernelPackage\/mt7922-firmware\/install\n\t$(INSTALL_DIR) $(1)\/lib\/firmware\/mediatek\n\tcp \\\n\t\t$(PKG_BUILD_DIR)\/firmware\/WIFI_MT7922_patch_mcu_1_1_hdr.bin \\\n\t\t$(PKG_BUILD_DIR)\/firmware\/WIFI_RAM_CODE_MT7922_1.bin \\\n\t\t$(1)\/lib\/firmware\/mediatek\nendef\n' package/kernel/mt76/Makefile
sed -i '/$(eval \$(call KernelPackage,mt7921-firmware))/a $(eval \$(call KernelPackage,mt7922-firmware))' package/kernel/mt76/Makefile

# iwinfo: add mt7922 device id
if [ "$version" = "rc" ]; then
    rm -rf package/network/utils/iwinfo
    cp -a ../master/openwrt/package/network/utils/iwinfo package/network/utils/iwinfo
fi
mkdir -p package/network/utils/iwinfo/patches
curl -s https://$mirror/openwrt/patch/openwrt-6.1/iwinfo/0001-devices-add-MediaTek-MT7922-device-id.patch > package/network/utils/iwinfo/patches/0001-devices-add-MediaTek-MT7922-device-id.patch

# iwinfo: add rtl8812/14/21au devices
curl -s https://$mirror/openwrt/patch/openwrt-6.1/iwinfo/0004-add-rtl8812au-devices.patch > package/network/utils/iwinfo/patches/0004-add-rtl8812au-devices.patch

# iw
if [ "$version" = "rc" ]; then
    rm -rf package/network/utils/iw
    cp -a ../master/openwrt/package/network/utils/iw package/network/utils/iw
fi

# wireless-regdb
curl -s https://$mirror/openwrt/patch/openwrt-6.1/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch

# mac80211 - fix linux 6.1
rm -rf package/kernel/mac80211
cp -a ../master/openwrt/package/kernel/mac80211 package/kernel/mac80211

# mac80211 - add rtw89
curl -s https://github.com/openwrt/openwrt/commit/88e6100f21ef179466825c0a4e9e41a270527cbe.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/06d383fa4f8d297654f3b566a779e7473262d76c.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/b4e32778056db6342016b25d30e105cfddb3ef6e.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/7a9758d5a5b9224aa4ecb7288611d42976193e95.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/2dd03f5a2fe71baa2cb984bf5a17dc3cb13ed2bb.patch | patch -p1
curl -s https://github.com/openwrt/openwrt/commit/d8a9ab8798388a3b9c9c9b703fee4735d0f18568.patch | patch -p1

# kernel patch
# 6.1
curl -s https://$mirror/openwrt/patch/kernel-6.1/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/pending-6.1/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
curl -s https://$mirror/openwrt/patch/kernel-6.1/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-6.1/952-net-conntrack-events-support-multiple-registrant.patch
curl -s https://$mirror/openwrt/patch/kernel-6.1/998-hide-panfrost-logs.patch > target/linux/generic/hack-6.1/998-hide-panfrost-logs.patch

# feeds/packages/net/gensio - fix linux 6.1
pushd feeds/packages
    [ "$version" = "rc" ] && curl -s https://github.com/openwrt/packages/commit/ea3ad6b0909b2f5d8a8dcbc4e866c9ed22f3fb10.patch | patch -p1
popd

# ubnt-ledbar - fix linux-6.1
if [ "$version" = "snapshots-23.05" ] || [ "$version" = "rc2" ]; then
    rm -rf package/kernel/ubnt-ledbar
    cp -a ../master/openwrt/package/kernel/ubnt-ledbar package/kernel/ubnt-ledbar
fi

# RTC
if [ "$platform" = "rk3399" ] || [ "$platform" = "rk3568" ]; then
    curl -s https://$mirror/openwrt/patch/rtc/sysfixtime > package/base-files/files/etc/init.d/sysfixtime
    chmod 755 package/base-files/files/etc/init.d/sysfixtime
fi
