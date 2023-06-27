#!/bin/bash -e

#################################################################

# Rockchip - target - r4s/r5s
rm -rf target/linux/rockchip
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_rockchip-6.x target/linux/rockchip

# kernel - 6.x
curl -s https://$mirror/tags/kernel-6.1 > include/kernel-6.1
grep HASH include/kernel-6.1 | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic
curl -s https://$mirror/openwrt/patch/KBUILD_BUILD_TIMESTAMP.patch | patch -p1

# kernel generic patches
git clone https://github.com/sbwml/target_linux_generic
rm -rf target/linux/generic/*-6.* target/linux/generic/files
mv target_linux_generic/target/linux/generic/* target/linux/generic/
sed -i '/CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE/d' target/linux/generic/config-6.1
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

# linux-firmware
if [ "$version" = "rc" ]; then
    rm -rf package/firmware/linux-firmware
    git clone https://nanopi:nanopi@$gitea/sbwml/package_firmware_linux-firmware package/firmware/linux-firmware
else
    sed -i '$a\Package/rtw89-firmware = $(call Package/firmware-default,RealTek RTW89 firmware)\
define Package/rtw89-firmware/install\
\t$(INSTALL_DIR) $(1)/lib/firmware/rtw89\
\t$(CP) \\\
\t\t$(PKG_BUILD_DIR)/rtw89/* \\\
\t\t$(1)/lib/firmware/rtw89\
endef\
$(eval $(call BuildPackage,rtw89-firmware))' package/firmware/linux-firmware/realtek.mk
fi

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
git clone https://nanopi:nanopi@$gitea/sbwml/package_kernel_mac80211 package/kernel/mac80211 -b 6.1

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
