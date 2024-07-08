#!/bin/bash -e

#################################################################

# Rockchip - target - r4s/r5s only
rm -rf target/linux/rockchip
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_rockchip-6.x target/linux/rockchip -b linux-6.6

# x86_64 - target
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/64/config-6.6 > target/linux/x86/64/config-6.6
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/config-6.6 > target/linux/x86/config-6.6
mkdir -p target/linux/x86/patches-6.6
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/patches-6.6/100-fix_cs5535_clockevt.patch > target/linux/x86/patches-6.6/100-fix_cs5535_clockevt.patch
curl -s https://$mirror/openwrt/patch/openwrt-6.x/x86/patches-6.6/103-pcengines_apu6_platform.patch > target/linux/x86/patches-6.6/103-pcengines_apu6_platform.patch
sed -i '/KERNEL_PATCHVER/a\KERNEL_TESTING_PATCHVER:=6.6' target/linux/x86/Makefile
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

# kenrel Vermagic
sed -ie 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
grep HASH include/kernel-6.6 | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# kernel generic patches
rm -rf target/linux/generic
kernel_version=$(sed -n 's/^LINUX_KERNEL_HASH-\([0-9.]\+\) = .*/\1/p' include/kernel-6.6)
release_kernel_version=$(curl -sL https://raw.githubusercontent.com/sbwml/r4s_build_script/master/tags/kernel-6.6 | sed -n 's/^LINUX_KERNEL_HASH-\([0-9.]\+\) = .*/\1/p')
if [ "$kernel_version" = "$release_kernel_version" ]; then
    git clone https://$github/sbwml/target_linux_generic -b main target/linux/generic --depth=1
else
    if [ "$(whoami)" = "runner" ]; then
        git_name=private
        git_password="$git_password"
        git clone https://"$git_name":"$git_password"@$gitea/sbwml/target_linux_generic -b main target/linux/generic --depth=1
    elif [ "$(whoami)" = "sbwml" ]; then
        git clone https://$gitea/sbwml/target_linux_generic -b main target/linux/generic --depth=1
    fi
fi

# bcm53xx - fix build kernel with clang
[ "$platform" = "bcm53xx" ] && [ "$KERNEL_CLANG_LTO" = "y" ] && rm -f target/linux/generic/hack-6.6/220-arm-gc_sections.patch

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
    [ "$platform" = "bcm53xx" ] && sed -i 's/tcp-bbr3/tcp-bbr/g' netsupport.mk
    [ "$platform" = "bcm53xx" ] && sed -i 's/BBRv3/BBR/g' netsupport.mk
popd

# BBRv3 - linux-6.6
if [ "$platform" != "bcm53xx" ]; then
    pushd target/linux/generic/backport-6.6
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0007-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0009-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0010-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0011-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0012-net-tcp_bbr-v2-record-app-limited-status-of-TLP-repa.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0013-net-tcp_bbr-v2-inform-CC-module-of-losses-repaired-b.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0014-net-tcp_bbr-v2-introduce-is_acking_tlp_retrans_seq-i.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0015-tcp-introduce-per-route-feature-RTAX_FEATURE_ECN_LOW.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0016-net-tcp_bbr-v3-update-TCP-bbr-congestion-control-mod.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0017-net-tcp_bbr-v3-ensure-ECN-enabled-BBR-flows-set-ECT-.patch
        curl -Os https://$mirror/openwrt/patch/kernel-6.6/bbr3_6.6/010-bbr3-0018-tcp-export-TCPI_OPT_ECN_LOW-in-tcp_info-tcpi_options.patch
    popd
fi

# LRNG v54 - linux-6.6
pushd target/linux/generic/hack-6.6
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0003-LRNG-proc-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0005-LRNG-add-common-generic-hash-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0016-LRNG-CPU-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0017-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0018-LRNG-add-option-to-enable-runtime-entropy-rate-confi.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0019-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0020-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0021-LRNG-sysctls-and-proc-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0022-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0023-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0024-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.6/lrng/011-LRNG-0025-LRNG-add-hwrand-framework-interface.patch
popd

# linux-firmware: rtw89 / rtl8723d / rtl8821c /i915 firmware
rm -rf package/firmware/linux-firmware
git clone https://$github/sbwml/package_firmware_linux-firmware package/firmware/linux-firmware

# rtl8812au-ct - fix linux-6.1
rm -rf package/kernel/rtl8812au-ct
cp -a ../master/openwrt/package/kernel/rtl8812au-ct package/kernel/rtl8812au-ct

# add rtl8812au-ac
git clone https://$github/sbwml/package_kernel_rtl8812au-ac package/kernel/rtl8812au-ac

# mt76 - main
rm -rf package/kernel/mt76
cp -a ../master/openwrt/package/kernel/mt76 package/kernel/mt76

# iwinfo: add mt7922 device id
mkdir -p package/network/utils/iwinfo/patches
curl -s https://$mirror/openwrt/patch/openwrt-6.x/iwinfo/0001-devices-add-MediaTek-MT7922-device-id.patch > package/network/utils/iwinfo/patches/0001-devices-add-MediaTek-MT7922-device-id.patch

# iwinfo: add rtl8812/14/21au devices
curl -s https://$mirror/openwrt/patch/openwrt-6.x/iwinfo/0004-add-rtl8812au-devices.patch > package/network/utils/iwinfo/patches/0004-add-rtl8812au-devices.patch

# wireless-regdb
rm -rf package/firmware/wireless-regdb
cp -a ../master/openwrt/package/firmware/wireless-regdb package/firmware/wireless-regdb
curl -s https://$mirror/openwrt/patch/openwrt-6.x/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch

# mac80211 - fix linux 6.6 & add rtw89
rm -rf package/kernel/mac80211
git clone https://$github/sbwml/package_kernel_mac80211 package/kernel/mac80211

# mac80211/patches/rtl - rtw88
mkdir -p package/kernel/mac80211/patches/rtl
pushd package/kernel/mac80211/patches/rtl
    curl -Os https://$mirror/openwrt/patch/mac80211/900-hack-rtw88-phy.patch
    curl -Os https://$mirror/openwrt/patch/mac80211/901-wifi-rtw88-8822b-disable-call-trace-when-write-RF-mo.patch
    curl -Os https://$mirror/openwrt/patch/mac80211/905-wifi-rtw88-add-missing-call-to-cancel_work_sync.patch
    curl -Os https://$mirror/openwrt/patch/mac80211/906-wifi-rtw88-8821c-Fix-beacon-loss-and-disconnect.patch
    curl -Os https://$mirror/openwrt/patch/mac80211/907-wifi-rtw88-usb-Add-magic-missing-from-register-acces.patch
popd

# kernel patch
# btf: silence btf module warning messages
curl -s https://$mirror/openwrt/patch/kernel-6.6/btf/990-btf-silence-btf-module-warning-messages.patch > target/linux/generic/hack-6.6/990-btf-silence-btf-module-warning-messages.patch
# cpu model
curl -s https://$mirror/openwrt/patch/kernel-6.6/arm64/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/pending-6.6/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# fullcone
curl -s https://$mirror/openwrt/patch/kernel-6.6/net/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-6.6/952-net-conntrack-events-support-multiple-registrant.patch
# bcm-fullcone
curl -s https://$mirror/openwrt/patch/kernel-6.6/net/982-add-bcm-fullcone-support.patch > target/linux/generic/hack-6.6/982-add-bcm-fullcone-support.patch
curl -s https://$mirror/openwrt/patch/kernel-6.6/net/983-add-bcm-fullcone-nft_masq-support.patch > target/linux/generic/hack-6.6/983-add-bcm-fullcone-nft_masq-support.patch
# shortcut-fe
curl -s https://$mirror/openwrt/patch/kernel-6.6/net/601-netfilter-export-udp_get_timeouts-function.patch > target/linux/generic/hack-6.6/601-netfilter-export-udp_get_timeouts-function.patch
curl -s https://$mirror/openwrt/patch/kernel-6.6/net/953-net-patch-linux-kernel-to-support-shortcut-fe.patch > target/linux/generic/hack-6.6/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
# backport - 6.8 fast-path-variables
if [ "$platform" != "bcm53xx" ]; then
    curl -s https://$mirror/openwrt/patch/kernel-6.6/backport/901-v6.8-cache-enforce-cache-groups.patch > target/linux/generic/backport-6.6/901-v6.8-cache-enforce-cache-groups.patch
    curl -s https://$mirror/openwrt/patch/kernel-6.6/backport/902-v6.8-netns-ipv4-reorganize-netns_ipv4-fast-path-variables.patch > target/linux/generic/backport-6.6/902-v6.8-netns-ipv4-reorganize-netns_ipv4-fast-path-variables.patch
    curl -s https://$mirror/openwrt/patch/kernel-6.6/backport/903-v6.8-net-device-reorganize-net_device-fast-path-variables.patch > target/linux/generic/backport-6.6/903-v6.8-net-device-reorganize-net_device-fast-path-variables.patch
    curl -s https://$mirror/openwrt/patch/kernel-6.6/backport/904-v6.8-tcp-reorganize-tcp_sock-fast-path-variables.patch > target/linux/generic/backport-6.6/904-v6.8-tcp-reorganize-tcp_sock-fast-path-variables.patch
    curl -s https://$mirror/openwrt/patch/kernel-6.6/backport/905-v6.8-tcp-move-tp-scaling_ratio-to-tcp_sock_read_txrx-grou.patch > target/linux/generic/backport-6.6/905-v6.8-tcp-move-tp-scaling_ratio-to-tcp_sock_read_txrx-grou.patch
fi

# ubnt-ledbar - fix linux-6.x
rm -rf package/kernel/ubnt-ledbar
cp -a ../master/openwrt/package/kernel/ubnt-ledbar package/kernel/ubnt-ledbar

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
