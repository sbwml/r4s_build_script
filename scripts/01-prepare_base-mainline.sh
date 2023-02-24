#!/bin/bash -e

#################################################################

# Rockchip - target - r4s/r5s
rm -rf target/linux/rockchip
git clone https://nanopi:nanopi@$gitea/sbwml/target_linux_rockchip-6.x target/linux/rockchip

# kernel - 6.x
curl -s https://$mirror/tags/kernel-6.1 > include/kernel-6.1
curl -s https://$mirror/tags/kernel-6.2 > include/kernel-6.2
grep HASH include/kernel-$KERNEL_VER | awk -F- '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# kernel modules
git checkout package/kernel/linux
curl -s https://$mirror/openwrt/patch/openwrt-6.1/include_netfilter.patch | patch -p1
pushd package/kernel/linux/modules
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/block.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/crypto.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/fs.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/hwmon.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/i2c.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/input.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/lib.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/netdevices.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/netfilter.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/netsupport.mk
    curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/video.mk
    [ "$KERNEL_TESTING" = 1 ] && curl -Os https://$mirror/openwrt/patch/openwrt-6.1/modules/other.mk
    [ "$KERNEL_TESTING" = 1 ] && sed -i 's/+kmod-iio-core +kmod-iio-kfifo-buf +kmod-regmap-core/+kmod-iio-core +kmod-iio-kfifo-buf +kmod-regmap-core +kmod-industrialio-triggered-buffer/g' iio.mk
popd

# linux-firmware
rm -rf package/firmware/linux-firmware
git clone https://nanopi:nanopi@$gitea/sbwml/package_firmware_linux-firmware package/firmware/linux-firmware

# ath10k-ct - fix mac80211 6.1-rc
rm -rf package/kernel/ath10k-ct
cp -a ../master/openwrt/package/kernel/ath10k-ct package/kernel/ath10k-ct
curl -s https://$mirror/openwrt/patch/openwrt-6.1/kmod-patches/ath10k-ct.patch | patch -p1

# mt76 - fix build
rm -rf package/kernel/mt76/patches
curl -s https://$mirror/openwrt/patch/openwrt-6.1/mt76/Makefile > package/kernel/mt76/Makefile

# iwinfo: add mt7922
rm -rf package/network/utils/iwinfo
cp -a ../master/openwrt/package/network/utils/iwinfo package/network/utils/iwinfo
mkdir -p package/network/utils/iwinfo/patches
curl -s https://$mirror/openwrt/patch/openwrt-6.1/iwinfo/0001-devices-add-MediaTek-MT7922-device-id.patch > package/network/utils/iwinfo/patches/0001-devices-add-MediaTek-MT7922-device-id.patch

# iwinfo: add rtl8812/14/21au devices
curl -s https://$mirror/openwrt/patch/openwrt-6.1/iwinfo/0004-add-rtl8812au-devices.patch > package/network/utils/iwinfo/patches/0004-add-rtl8812au-devices.patch

# iw
rm -rf package/network/utils/iw
cp -a ../master/openwrt/package/network/utils/iw package/network/utils/iw

# wireless-regdb
curl -s https://$mirror/openwrt/patch/openwrt-6.1/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch

# mac80211 - fix linux 6.1
rm -rf package/kernel/mac80211
if [ "$KERNEL_TESTING" = 1 ]; then
    git clone https://nanopi:nanopi@$gitea/sbwml/package_kernel_mac80211 package/kernel/mac80211 -b 6.2
else
    git clone https://nanopi:nanopi@$gitea/sbwml/package_kernel_mac80211 package/kernel/mac80211
fi

# kernel generic patches
git clone https://github.com/sbwml/target_linux_generic
mv target_linux_generic/target/linux/generic/* target/linux/generic/
sed -i '/CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE/d' target/linux/generic/config-6.1 target/linux/generic/config-6.2
rm -rf target_linux_generic

# kernel patch
# 6.1
curl -s https://$mirror/openwrt/patch/kernel-6.1/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/pending-6.1/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
curl -s https://$mirror/openwrt/patch/kernel-6.1/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-6.1/952-net-conntrack-events-support-multiple-registrant.patch
curl -s https://$mirror/openwrt/patch/kernel-6.1/998-hide-panfrost-logs.patch > target/linux/generic/hack-6.1/998-hide-panfrost-logs.patch
curl -s https://$mirror/openwrt/patch/kernel-6.1/999-hide-irq-logs.patch > target/linux/generic/hack-6.1/999-hide-irq-logs.patch
# 6.2
cp target/linux/generic/pending-6.1/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch target/linux/generic/pending-6.2/
cp target/linux/generic/hack-6.1/952-net-conntrack-events-support-multiple-registrant.patch target/linux/generic/hack-6.2/
cp target/linux/generic/hack-6.1/998-hide-panfrost-logs.patch target/linux/generic/hack-6.2/
cp target/linux/generic/hack-6.1/999-hide-irq-logs.patch target/linux/generic/hack-6.2/

# feeds/packages/net/gensio - fix linux 6.1
pushd feeds/packages
    curl -s https://github.com/openwrt/packages/commit/ea3ad6b0909b2f5d8a8dcbc4e866c9ed22f3fb10.patch  | patch -p1
popd

# ksmbd luci
rm -rf feeds/luci/applications/luci-app-ksmbd
cp -a ../master/luci/applications/luci-app-ksmbd feeds/luci/applications/luci-app-ksmbd
curl -s https://$mirror/openwrt/patch/openwrt-6.1/ksmbd/version.patch | patch -p1
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/luci/applications/luci-app-ksmbd/htdocs/luci-static/resources/view/ksmbd.js

# ksmbd tools
rm -rf feeds/packages/net/ksmbd-tools
cp -a ../master/packages/net/ksmbd-tools feeds/packages/net/ksmbd-tools
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/ksmbd-tools/files/ksmbd.config.example
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/ksmbd-tools/files/ksmbd.conf.template

# drop ksmbd - use kernel ksmdb
rm -rf package/kernel/ksmbd
