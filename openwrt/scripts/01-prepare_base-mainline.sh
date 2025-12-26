#!/bin/bash -e

#################################################################

# autocore
git clone https://$github/sbwml/autocore-arm -b openwrt-25.12 package/system/autocore

# rockchip - target - r4s/r5s only
rm -rf target/linux/rockchip
if [ "$(whoami)" = "sbwml" ]; then
    git clone https://$gitea/sbwml/target_linux_rockchip-6.x target/linux/rockchip -b v6.18 --depth=1
else
    git clone https://"$git_name":"$git_password"@$gitea/sbwml/target_linux_rockchip-6.x target/linux/rockchip -b v6.18 --depth=1
fi

# bpf-headers - 6.18
sed -ri "s/(PKG_PATCHVER:=)[^\"]*/\16.18/" package/kernel/bpf-headers/Makefile
curl -s $mirror/openwrt/patch/packages-patches/bpf-headers/900-fix-build.patch > package/kernel/bpf-headers/patches/900-fix-build.patch

## x86_64 - target 6.18
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/64/config-6.18 > target/linux/x86/64/config-6.18
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/config-6.18 > target/linux/x86/config-6.18
mkdir -p target/linux/x86/patches-6.18
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/patches-6.18/100-fix_cs5535_clockevt.patch > target/linux/x86/patches-6.18/100-fix_cs5535_clockevt.patch
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/patches-6.18/103-pcengines_apu6_platform.patch > target/linux/x86/patches-6.18/103-pcengines_apu6_platform.patch
## x86_64 - target
sed -ri "s/(KERNEL_PATCHVER:=)[^\"]*/\16.18/" target/linux/x86/Makefile
sed -i '/KERNEL_PATCHVER/a\KERNEL_TESTING_PATCHVER:=6.12' target/linux/x86/Makefile
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/base-files/etc/board.d/01_leds > target/linux/x86/base-files/etc/board.d/01_leds
curl -s $mirror/openwrt/patch/openwrt-6.x/x86/base-files/etc/board.d/02_network > target/linux/x86/base-files/etc/board.d/02_network

# armsr/armv8
rm -rf target/linux/armsr
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_armsr target/linux/armsr -b v6.18

# kernel - 6.18
curl -s $mirror/tags/kernel-6.18 > target/linux/generic/kernel-6.18

# kenrel Vermagic
sed -ie 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
grep HASH target/linux/generic/kernel-6.18 | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# kernel generic patches
curl -s $mirror/openwrt/patch/kernel-6.18/openwrt/linux-6.18-target-linux-generic.patch | patch -p1
if [ "$(whoami)" = "sbwml" ]; then
    git clone https://$gitea/sbwml/target_linux_generic -b openwrt-25.12 target/linux/generic-6.18 --depth=1
else
    git clone https://"$git_name":"$git_password"@$gitea/sbwml/target_linux_generic -b openwrt-25.12 target/linux/generic-6.18 --depth=1
fi
cp -a target/linux/generic-6.18/* target/linux/generic

# kernel modules
rm -rf package/kernel/linux
git checkout package/kernel/linux
pushd package/kernel/linux/modules
    rm -f [a-z]*.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/block.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/bluetooth.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/can.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/crypto.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/firewire.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/fs.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/gpio.mk
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
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/rtc.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/sound.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/spi.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/usb.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/video.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/virt.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/w1.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/wpan.mk
popd

# BBRv3 - linux-6.18
pushd target/linux/generic/backport-6.18
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0007-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0009-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0010-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0011-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0012-net-tcp_bbr-v2-record-app-limited-status-of-TLP-repa.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0013-net-tcp_bbr-v2-inform-CC-module-of-losses-repaired-b.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0014-net-tcp_bbr-v2-introduce-is_acking_tlp_retrans_seq-i.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0015-tcp-introduce-per-route-feature-RTAX_FEATURE_ECN_LOW.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0016-net-tcp_bbr-v3-update-TCP-bbr-congestion-control-mod.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0017-net-tcp_bbr-v3-ensure-ECN-enabled-BBR-flows-set-ECT-.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0018-tcp-export-TCPI_OPT_ECN_LOW-in-tcp_info-tcpi_options.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0019-x86-cfi-bpf-Add-tso_segs-and-skb_marked_lost-to-bpf_.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/bbr3/010-bbr3-0020-net-tcp_bbr-v3-silence-Wconstant-logical-operand.patch
popd

# LRNG - 6.18
pushd target/linux/generic/hack-6.18
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0003-LRNG-proc-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0005-LRNG-add-common-generic-hash-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0016-LRNG-CPU-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0017-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0018-LRNG-add-option-to-enable-runtime-entropy-rate-confi.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0019-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0020-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0021-LRNG-sysctls-and-proc-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0022-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0023-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0024-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/lrng/011-LRNG-0025-LRNG-add-hwrand-framework-interface.patch
popd

# linux-rt - i915
pushd target/linux/generic/hack-6.18
    curl -Os $mirror/openwrt/patch/kernel-6.18/linux-rt/012-RT-0001-drm-i915-Use-preempt_disable-enable_rt-where-recomme.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/linux-rt/012-RT-0002-drm-i915-Don-t-disable-interrupts-on-PREEMPT_RT-duri.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/linux-rt/012-RT-0003-drm-i915-Disable-tracing-points-on-PREEMPT_RT.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/linux-rt/012-RT-0004-drm-i915-gt-Use-spin_lock_irq-instead-of-local_irq_d.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/linux-rt/012-RT-0005-drm-i915-Drop-the-irqs_disabled-check.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/linux-rt/012-RT-0006-drm-i915-guc-Consider-also-RCU-depth-in-busy-loop.patch
    curl -Os $mirror/openwrt/patch/kernel-6.18/linux-rt/012-RT-0007-Revert-drm-i915-Depend-on-PREEMPT_RT.patch
popd

# linux-firmware
rm -rf package/firmware/linux-firmware
git clone https://$github/sbwml/package_firmware_linux-firmware package/firmware/linux-firmware

# mt76
rm -rf package/kernel/mt76
mkdir -p package/kernel/mt76/patches
curl -s $mirror/openwrt/patch/mt76/Makefile > package/kernel/mt76/Makefile
curl -s $mirror/openwrt/patch/mt76/patches/101-fix-build-with-linux-6.12rc2.patch > package/kernel/mt76/patches/101-fix-build-with-linux-6.12rc2.patch
curl -s $mirror/openwrt/patch/mt76/patches/102-fix-build-with-linux-6.18.patch > package/kernel/mt76/patches/102-fix-build-with-linux-6.18.patch

# wireless-regdb
curl -s $mirror/openwrt/patch/openwrt-6.x/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch

# mac80211 - 6.18
rm -rf package/kernel/mac80211
git clone https://$github/sbwml/package_kernel_mac80211 package/kernel/mac80211 -b v6.18

# ath10k-ct
rm -rf package/kernel/ath10k-ct
git clone https://$github/sbwml/package_kernel_ath10k-ct package/kernel/ath10k-ct -b v6.18

# kernel patch
# btf: silence btf module warning messages
curl -s $mirror/openwrt/patch/kernel-6.18/btf/990-btf-silence-btf-module-warning-messages.patch > target/linux/generic/hack-6.18/990-btf-silence-btf-module-warning-messages.patch
# cpu model
curl -s $mirror/openwrt/patch/kernel-6.18/arm64/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/hack-6.18/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# bcm-fullcone
curl -s $mirror/openwrt/patch/kernel-6.18/net/982-add-bcm-fullcone-support.patch > target/linux/generic/hack-6.18/982-add-bcm-fullcone-support.patch
curl -s $mirror/openwrt/patch/kernel-6.18/net/983-add-bcm-fullcone-nft_masq-support.patch > target/linux/generic/hack-6.18/983-add-bcm-fullcone-nft_masq-support.patch
# shortcut-fe
curl -s $mirror/openwrt/patch/kernel-6.18/net/601-netfilter-export-udp_get_timeouts-function.patch > target/linux/generic/hack-6.18/601-netfilter-export-udp_get_timeouts-function.patch
curl -s $mirror/openwrt/patch/kernel-6.18/net/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-6.18/952-net-conntrack-events-support-multiple-registrant.patch
curl -s $mirror/openwrt/patch/kernel-6.18/net/953-net-patch-linux-kernel-to-support-shortcut-fe.patch > target/linux/generic/hack-6.18/953-net-patch-linux-kernel-to-support-shortcut-fe.patch

# rtl8822cs
git clone https://$github/sbwml/package_kernel_rtl8822cs package/kernel/rtl8822cs

# RTC
if [ "$platform" = "rk3399" ] || [ "$platform" = "rk3568" ] || [ "$platform" = "rk3576" ]; then
    curl -s $mirror/openwrt/patch/rtc/sysfixtime > package/base-files/files/etc/init.d/sysfixtime
    chmod 755 package/base-files/files/etc/init.d/sysfixtime
fi

# emmc-install
if [ "$platform" = "rk3568" ] || [ "$platform" = "rk3576" ]; then
    mkdir -p files/sbin
    curl -so files/sbin/emmc-install $mirror/openwrt/files/sbin/emmc-install
    chmod 755 files/sbin/emmc-install
fi
