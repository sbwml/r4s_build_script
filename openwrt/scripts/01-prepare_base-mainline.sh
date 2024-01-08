#!/bin/bash -e

#################################################################

# Rockchip - target - r4s/r5s only
rm -rf target/linux/rockchip
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_rockchip-6.x target/linux/rockchip -b linux-6.6
[ "$platform" = "rk3568" ] && sed -i 's/CONFIG_PREEMPT=y/CONFIG_PREEMPT_DYNAMIC=y/g' target/linux/rockchip/armv8/config-6.6

# x86_64 - target
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/64/config-6.6 > target/linux/x86/64/config-6.6
[ "$platform" = "x86_64" ] && echo "CONFIG_PREEMPT_DYNAMIC=y" >> target/linux/x86/64/config-6.6
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/config-6.6 > target/linux/x86/config-6.6
mkdir -p target/linux/x86/patches-6.6
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/patches-6.6/100-fix_cs5535_clockevt.patch > target/linux/x86/patches-6.6/100-fix_cs5535_clockevt.patch
sed -i '/KERNEL_PATCHVER/a\KERNEL_TESTING_PATCHVER:=6.6' target/linux/x86/Makefile

# kernel - 6.x
curl -s $mirror/tags/kernel-6.6 > include/kernel-6.6

# kenrel Vermagic
sed -ie 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
grep HASH include/kernel-6.6 | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# kernel generic patches
git clone https://github.com/sbwml/target_linux_generic -b linux-6.6
rm -rf target/linux/generic/*-6.6 target/linux/generic/files
mv target_linux_generic/target/linux/generic/* target/linux/generic/
rm -rf target_linux_generic

# kernel modules
rm -rf package/kernel/linux
git checkout package/kernel/linux
pushd package/kernel/linux/modules
    rm -f [a-z]*.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/block.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/can.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/crypto.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/firewire.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/fs.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/gpio-cascade.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/hwmon.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/i2c.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/iio.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/input.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/leds.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/lib.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/multiplexer.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netdevices.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netfilter.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netsupport.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/nls.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/other.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/pcmcia.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/sound.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/spi.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/usb.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/video.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/virt.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/w1.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/wpan.mk
popd

# BBRv3 - linux-6.6
pushd target/linux/generic/backport-6.6
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0007-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0009-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0010-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0011-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0012-net-tcp_bbr-v2-record-app-limited-status-of-TLP-repa.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0013-net-tcp_bbr-v2-inform-CC-module-of-losses-repaired-b.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0014-net-tcp_bbr-v2-introduce-is_acking_tlp_retrans_seq-i.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0015-tcp-introduce-per-route-feature-RTAX_FEATURE_ECN_LOW.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0016-net-tcp_bbr-v3-update-TCP-bbr-congestion-control-mod.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0017-net-tcp_bbr-v3-ensure-ECN-enabled-BBR-flows-set-ECT-.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0018-tcp-export-TCPI_OPT_ECN_LOW-in-tcp_info-tcpi_options.patch
popd

# LRNG v51 - linux-6.6
curl -s $mirror/openwrt/patch/kernel-6.6/config-lrng >> target/linux/generic/config-6.6
if [ "$platform" = "rk3399" ] || [ "$platform" = "rk3568" ]; then
    echo 'CONFIG_LRNG_HWRAND_IF=y' >> target/linux/generic/config-6.6
else
    echo '# CONFIG_LRNG_HWRAND_IF is not set' >> target/linux/generic/config-6.6
fi
pushd target/linux/generic/hack-6.6
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0003-LRNG-proc-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0005-LRNG-add-common-generic-hash-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0016-LRNG-CPU-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0017-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0018-LRNG-add-option-to-enable-runtime-entropy-rate-confi.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0019-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0020-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0021-LRNG-sysctls-and-proc-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0022-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0023-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0024-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng_v52_6.6/0025-LRNG-add-hwrand-framework-interface.patch
popd

# linux-firmware: rtw89 / rtl8723d / rtl8821c firmware
rm -rf package/firmware/linux-firmware
cp -a ../master/mj22226_openwrt/package/firmware/linux-firmware package/firmware/linux-firmware

# rtl8812au-ct - fix linux-6.1
rm -rf package/kernel/rtl8812au-ct
cp -a ../master/openwrt/package/kernel/rtl8812au-ct package/kernel/rtl8812au-ct

# add rtl8812au-ac
cp -a ../master/mj22226_openwrt/package/kernel/rtl8812au-ac package/kernel/rtl8812au-ac

# ath10k-ct - fix mac80211 6.1-rc
curl -s $mirror/openwrt/patch/openwrt-6.x/kmod-patches/ath10k-ct.patch | patch -p1

# mt76 - update to 2023-12-18
rm -rf package/kernel/mt76
git clone https://github.com/sbwml/package_kernel_mt76 package/kernel/mt76

# iwinfo: add mt7922 device id
mkdir -p package/network/utils/iwinfo/patches
curl -s $mirror/openwrt/patch/openwrt-6.x/iwinfo/0001-devices-add-MediaTek-MT7922-device-id.patch > package/network/utils/iwinfo/patches/0001-devices-add-MediaTek-MT7922-device-id.patch

# iwinfo: add rtl8812/14/21au devices
curl -s $mirror/openwrt/patch/openwrt-6.x/iwinfo/0004-add-rtl8812au-devices.patch > package/network/utils/iwinfo/patches/0004-add-rtl8812au-devices.patch

# wireless-regdb
curl -s $mirror/openwrt/patch/openwrt-6.x/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch

# mac80211 - fix linux 6.6 & add rtw89
rm -rf package/kernel/mac80211
cp -a ../master/mj22226_openwrt/package/kernel/mac80211 package/kernel/mac80211
rm -f package/kernel/mac80211/patches/ath11k/100-wifi-ath11k-use-unique-QRTR-instance-ID.patch package/kernel/mac80211/patches/build/200-Revert-wifi-iwlwifi-Use-generic-thermal_zone_get_tri.patch

# mac80211/patches/rtl - rtw88
mkdir -p package/kernel/mac80211/patches/rtl
curl -s $mirror/openwrt/patch/mac80211/900-hack-rtw88-phy.patch > package/kernel/mac80211/patches/rtl/900-hack-rtw88-phy.patch
curl -s $mirror/openwrt/patch/mac80211/901-wifi-rtw88-8822b-disable-call-trace-when-write-RF-mo.patch > package/kernel/mac80211/patches/rtl/901-wifi-rtw88-8822b-disable-call-trace-when-write-RF-mo.patch
curl -s $mirror/openwrt/patch/mac80211/903-wifi-rtw88-Remove-duplicate-NULL-check-before-callin.patch > package/kernel/mac80211/patches/rtl/903-wifi-rtw88-Remove-duplicate-NULL-check-before-callin.patch
curl -s $mirror/openwrt/patch/mac80211/904-wifi-rtw88-usb-kill-and-free-rx-urbs-on-probe-failur.patch > package/kernel/mac80211/patches/rtl/904-wifi-rtw88-usb-kill-and-free-rx-urbs-on-probe-failur.patch
curl -s $mirror/openwrt/patch/mac80211/905-wifi-rtw88-add-missing-call-to-cancel_work_sync.patch > package/kernel/mac80211/patches/rtl/905-wifi-rtw88-add-missing-call-to-cancel_work_sync.patch

# kernel patch
# cpu model
curl -s $mirror/openwrt/patch/kernel-6.6/arm64/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/pending-6.6/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# fullcone
curl -s $mirror/openwrt/patch/kernel-6.6/net/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-6.6/952-net-conntrack-events-support-multiple-registrant.patch
# shortcut-fe
curl -s $mirror/openwrt/patch/kernel-6.6/net/953-net-patch-linux-kernel-to-support-shortcut-fe.patch > target/linux/generic/hack-6.6/953-net-patch-linux-kernel-to-support-shortcut-fe.patch

# ubnt-ledbar - fix linux-6.x
rm -rf package/kernel/ubnt-ledbar
cp -a ../master/openwrt/package/kernel/ubnt-ledbar package/kernel/ubnt-ledbar

# RTC
if [ "$platform" = "rk3399" ] || [ "$platform" = "rk3568" ]; then
    curl -s $mirror/openwrt/patch/rtc/sysfixtime > package/base-files/files/etc/init.d/sysfixtime
    chmod 755 package/base-files/files/etc/init.d/sysfixtime
fi
