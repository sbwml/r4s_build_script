#!/bin/bash -e

#################################################################

# autocore
if [ "$version" = "rc2" ]; then
    git clone https://$github/sbwml/autocore-arm -b openwrt-23.05 package/system/autocore
else
    git clone https://$github/sbwml/autocore-arm -b openwrt-24.10 package/system/autocore
fi

# rockchip - target - r4s/r5s only
rm -rf target/linux/rockchip
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_rockchip-6.x target/linux/rockchip -b linux-6.6

# x86_64 - target 6.6
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/64/config-6.6 > target/linux/x86/64/config-6.6
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/config-6.6 > target/linux/x86/config-6.6
mkdir -p target/linux/x86/patches-6.6
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/patches-6.6/100-fix_cs5535_clockevt.patch > target/linux/x86/patches-6.6/100-fix_cs5535_clockevt.patch
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/patches-6.6/103-pcengines_apu6_platform.patch > target/linux/x86/patches-6.6/103-pcengines_apu6_platform.patch
# x86_64 - target 6.12
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/64/config-6.12 > target/linux/x86/64/config-6.12
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/config-6.12 > target/linux/x86/config-6.12
mkdir -p target/linux/x86/patches-6.12
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/patches-6.12/100-fix_cs5535_clockevt.patch > target/linux/x86/patches-6.12/100-fix_cs5535_clockevt.patch
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/patches-6.12/103-pcengines_apu6_platform.patch > target/linux/x86/patches-6.12/103-pcengines_apu6_platform.patch
# x86_64 - target
sed -ri "s/(KERNEL_PATCHVER:=)[^\"]*/\16.6/" target/linux/x86/Makefile
sed -i '/KERNEL_PATCHVER/a\KERNEL_TESTING_PATCHVER:=6.12' target/linux/x86/Makefile
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/base-files/etc/board.d/01_leds > target/linux/x86/base-files/etc/board.d/01_leds
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/base-files/etc/board.d/02_network > target/linux/x86/base-files/etc/board.d/02_network

# bcm53xx - target
rm -rf target/linux/bcm53xx
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_bcm53xx target/linux/bcm53xx
git clone https://nanopi:nanopi@$gitea/sbwml/brcmfmac-firmware-4366c-pcie package/firmware/brcmfmac-firmware-4366c-pcie
git clone https://nanopi:nanopi@$gitea/sbwml/brcmfmac-firmware-4366b-pcie package/firmware/brcmfmac-firmware-4366b-pcie

# armsr/armv8
rm -rf target/linux/armsr
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_armsr target/linux/armsr

# kernel - 6.x
curl -s https://$mirror/tags/kernel-6.6 > include/kernel-6.6
curl -s https://$mirror/tags/kernel-6.12 > include/kernel-6.12

# kenrel Vermagic
sed -ie 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
grep HASH include/kernel-$kernel_version | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# kernel generic patches
rm -rf target/linux/generic
local_kernel_version=$(sed -n 's/^LINUX_KERNEL_HASH-\([0-9.]\+\) = .*/\1/p' include/kernel-$kernel_version)
release_kernel_version=$(curl -sL https://raw.githubusercontent.com/sbwml/r4s_build_script/master/tags/kernel-$kernel_version | sed -n 's/^LINUX_KERNEL_HASH-\([0-9.]\+\) = .*/\1/p')
if [ "$local_kernel_version" = "$release_kernel_version" ] && [ -z "$git_password" ] && [ "$(whoami)" != "sbwml" ]; then
    git clone https://$github/sbwml/target_linux_generic -b main target/linux/generic --depth=1
else
    if [ "$(whoami)" = "runner" ]; then
        git_name=private
        git clone https://"$git_name":"$git_password"@$gitea/sbwml/target_linux_generic -b main target/linux/generic --depth=1
    elif [ "$(whoami)" = "sbwml" ]; then
        git clone https://$gitea/sbwml/target_linux_generic -b main target/linux/generic --depth=1
    fi
fi

# bcm53xx - fix build kernel with clang
[ "$platform" = "bcm53xx" ] && [ "$KERNEL_CLANG_LTO" = "y" ] && rm -f target/linux/generic/hack-6.6/220-arm-gc_sections.patch target/linux/generic/hack-6.12/220-arm-gc_sections.patch

# kernel modules
rm -rf package/kernel/linux
git checkout package/kernel/linux
pushd package/kernel/linux/modules
    rm -f [a-z]*.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/block.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/can.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/crypto.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/firewire.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/fs.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/gpio-cascade.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/hwmon.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/i2c.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/iio.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/input.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/leds.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/lib.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/multiplexer.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/netdevices.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/netfilter.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/netsupport.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/nls.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/other.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/pcmcia.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/sound.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/spi.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/usb.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/video.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/virt.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/w1.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.x/modules/wpan.mk
popd

# BBRv3 - linux-6.6/6.12
pushd target/linux/generic/backport-"$kernel_version"
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0007-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0009-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0010-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0011-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0012-net-tcp_bbr-v2-record-app-limited-status-of-TLP-repa.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0013-net-tcp_bbr-v2-inform-CC-module-of-losses-repaired-b.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0014-net-tcp_bbr-v2-introduce-is_acking_tlp_retrans_seq-i.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0015-tcp-introduce-per-route-feature-RTAX_FEATURE_ECN_LOW.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0016-net-tcp_bbr-v3-update-TCP-bbr-congestion-control-mod.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0017-net-tcp_bbr-v3-ensure-ECN-enabled-BBR-flows-set-ECT-.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0018-tcp-export-TCPI_OPT_ECN_LOW-in-tcp_info-tcpi_options.patch
    [ "$TESTING_KERNEL" = "y" ] && curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/bbr3/010-bbr3-0019-x86-cfi-bpf-Add-tso_segs-and-skb_marked_lost-to-bpf_.patch
popd

# LRNG v54/56 - linux-6.6/6.12
pushd target/linux/generic/hack-$kernel_version
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0003-LRNG-proc-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0005-LRNG-add-common-generic-hash-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0016-LRNG-CPU-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0017-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0018-LRNG-add-option-to-enable-runtime-entropy-rate-confi.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0019-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0020-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0021-LRNG-sysctls-and-proc-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0022-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0023-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0024-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-"$kernel_version"/lrng/011-LRNG-0025-LRNG-add-hwrand-framework-interface.patch
popd

# linux-rt - i915
if [ "$TESTING_KERNEL" = "y" ]; then
    pushd target/linux/generic/hack-6.12
        curl -Os https://$mirror/openwrt/patch/kernel-6.12/linux-rt/012-0001-drm-i915-Use-preempt_disable-enable_rt-where-recomme.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.12/linux-rt/012-0002-drm-i915-Don-t-disable-interrupts-on-PREEMPT_RT-duri.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.12/linux-rt/012-0003-drm-i915-Don-t-check-for-atomic-context-on-PREEMPT_R.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.12/linux-rt/012-0004-drm-i915-Disable-tracing-points-on-PREEMPT_RT.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.12/linux-rt/012-0005-drm-i915-gt-Use-spin_lock_irq-instead-of-local_irq_d.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.12/linux-rt/012-0006-drm-i915-Drop-the-irqs_disabled-check.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.12/linux-rt/012-0007-drm-i915-guc-Consider-also-RCU-depth-in-busy-loop.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.12/linux-rt/012-0008-Revert-drm-i915-Depend-on-PREEMPT_RT.patch
    popd
fi

# linux-firmware: rtw89 / rtl8723d / rtl8821c /i915 firmware
rm -rf package/firmware/linux-firmware
git clone https://$github/sbwml/package_firmware_linux-firmware package/firmware/linux-firmware

if [ "$TESTING_KERNEL" = "y" ]; then
    # rtl8812au-ct - fix linux-6.12
    rm -rf package/kernel/rtl8812au-ct
    git clone https://$github/sbwml/package_kernel_rtl8812au-ct package/kernel/rtl8812au-ct -b v6.11
    # add rtl8812au-ac
    git clone https://$github/sbwml/package_kernel_rtl8812au-ac package/kernel/rtl8812au-ac -b v6.11
else
    # rtl8812au-ct - fix linux-6.6
    rm -rf package/kernel/rtl8812au-ct
    git clone https://$github/sbwml/package_kernel_rtl8812au-ct package/kernel/rtl8812au-ct
    # add rtl8812au-ac
    git clone https://$github/sbwml/package_kernel_rtl8812au-ac package/kernel/rtl8812au-ac
fi

# mt76 - 2024-09-29
rm -rf package/kernel/mt76
mkdir -p package/kernel/mt76/patches
curl -s https://$mirror/openwrt/patch/mt76/Makefile > package/kernel/mt76/Makefile
[ "$TESTING_KERNEL" = "y" ] && {
    curl -s https://$mirror/openwrt/patch/mt76/patches/100-fix-build-with-mac80211-6.11-backport.patch > package/kernel/mt76/patches/100-fix-build-with-mac80211-6.11-backport.patch
    curl -s https://$mirror/openwrt/patch/mt76/patches/101-fix-build-with-linux-6.12rc2.patch > package/kernel/mt76/patches/101-fix-build-with-linux-6.12rc2.patch
}
[ "$version" = "snapshots-24.10" ] && curl -s https://$mirror/openwrt/patch/mt76/patches/100-api_update.patch > package/kernel/mt76/patches/100-api_update.patch

# iwinfo: add mt7922 device id
if [ "$version" = "rc2" ]; then
    mkdir -p package/network/utils/iwinfo/patches
    curl -s https://$mirror/openwrt/patch/openwrt-6.x/iwinfo/0001-devices-add-MediaTek-MT7922-device-id.patch > package/network/utils/iwinfo/patches/0001-devices-add-MediaTek-MT7922-device-id.patch
fi

# iwinfo: add rtl8812/14/21au devices
[ "$version" = "rc2" ] && curl -s https://$mirror/openwrt/patch/openwrt-6.x/iwinfo/0004-add-rtl8812au-devices.patch > package/network/utils/iwinfo/patches/0004-add-rtl8812au-devices.patch

# wireless-regdb
if [ "$version" = "rc2" ]; then
    rm -rf package/firmware/wireless-regdb
    cp -a ../master/openwrt/package/firmware/wireless-regdb package/firmware/wireless-regdb
fi
curl -s https://$mirror/openwrt/patch/openwrt-6.x/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch

# mac80211 - fix linux 6.6 & add rtw89
rm -rf package/kernel/mac80211
if [ "$version" = "rc2" ]; then
    git clone https://$github/sbwml/package_kernel_mac80211 package/kernel/mac80211 -b v6.11
    [ "$TESTING_KERNEL" = "y" ] && rm -f package/kernel/mac80211/patches/build/140-trace_backport.patch
else
    git clone https://$github/sbwml/package_kernel_mac80211 package/kernel/mac80211 -b openwrt-24.10
fi

# ath10k-ct
rm -rf package/kernel/ath10k-ct
git clone https://$github/sbwml/package_kernel_ath10k-ct package/kernel/ath10k-ct -b v6.11

# kernel patch
# btf: silence btf module warning messages
curl -s https://$mirror/openwrt/patch/kernel-$kernel_version/btf/990-btf-silence-btf-module-warning-messages.patch > target/linux/generic/hack-$kernel_version/990-btf-silence-btf-module-warning-messages.patch
# cpu model
curl -s https://$mirror/openwrt/patch/kernel-$kernel_version/arm64/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/pending-$kernel_version/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# fullcone
curl -s https://$mirror/openwrt/patch/kernel-$kernel_version/net/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-$kernel_version/952-net-conntrack-events-support-multiple-registrant.patch
# bcm-fullcone
[ "$TESTING_KERNEL" != "y" ] && {
    curl -s https://$mirror/openwrt/patch/kernel-$kernel_version/net/982-add-bcm-fullcone-support.patch > target/linux/generic/hack-$kernel_version/982-add-bcm-fullcone-support.patch
    curl -s https://$mirror/openwrt/patch/kernel-$kernel_version/net/983-add-bcm-fullcone-nft_masq-support.patch > target/linux/generic/hack-$kernel_version/983-add-bcm-fullcone-nft_masq-support.patch
}
# shortcut-fe
curl -s https://$mirror/openwrt/patch/kernel-$kernel_version/net/601-netfilter-export-udp_get_timeouts-function.patch > target/linux/generic/hack-$kernel_version/601-netfilter-export-udp_get_timeouts-function.patch
curl -s https://$mirror/openwrt/patch/kernel-$kernel_version/net/953-net-patch-linux-kernel-to-support-shortcut-fe.patch > target/linux/generic/hack-$kernel_version/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
# backport - 6.8 fast-path-variables
if [ "$version" = "rc2" ] && [ "$platform" != "bcm53xx" ] && [ "$TESTING_KERNEL" != "y" ]; then
    curl -s https://$mirror/openwrt/patch/kernel-6.6/backport/901-v6.8-cache-enforce-cache-groups.patch > target/linux/generic/backport-6.6/901-v6.8-cache-enforce-cache-groups.patch
    curl -s https://$mirror/openwrt/patch/kernel-6.6/backport/902-v6.8-netns-ipv4-reorganize-netns_ipv4-fast-path-variables.patch > target/linux/generic/backport-6.6/902-v6.8-netns-ipv4-reorganize-netns_ipv4-fast-path-variables.patch
    curl -s https://$mirror/openwrt/patch/kernel-6.6/backport/903-v6.8-net-device-reorganize-net_device-fast-path-variables.patch > target/linux/generic/backport-6.6/903-v6.8-net-device-reorganize-net_device-fast-path-variables.patch
    curl -s https://$mirror/openwrt/patch/kernel-6.6/backport/904-v6.8-tcp-reorganize-tcp_sock-fast-path-variables.patch > target/linux/generic/backport-6.6/904-v6.8-tcp-reorganize-tcp_sock-fast-path-variables.patch
    curl -s https://$mirror/openwrt/patch/kernel-6.6/backport/905-v6.8-tcp-move-tp-scaling_ratio-to-tcp_sock_read_txrx-grou.patch > target/linux/generic/backport-6.6/905-v6.8-tcp-move-tp-scaling_ratio-to-tcp_sock_read_txrx-grou.patch
fi

# ubnt-ledbar - fix linux-6.x
if [ "$version" = "rc2" ]; then
    rm -rf package/kernel/ubnt-ledbar
    cp -a ../master/openwrt/package/kernel/ubnt-ledbar package/kernel/ubnt-ledbar
fi

# RTC
if [ "$platform" = "rk3399" ] || [ "$platform" = "rk3568" ]; then
    curl -s https://$mirror/openwrt/patch/rtc/sysfixtime > package/base-files/files/etc/init.d/sysfixtime
    chmod 755 package/base-files/files/etc/init.d/sysfixtime
fi

# emmc-install
if [ "$platform" = "rk3568" ]; then
    mkdir -p files/sbin
    curl -so files/sbin/emmc-install https://$mirror/openwrt/files/sbin/emmc-install
    chmod 755 files/sbin/emmc-install
fi
