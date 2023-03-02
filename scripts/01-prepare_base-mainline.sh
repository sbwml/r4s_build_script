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
curl -s https://$mirror/openwrt/patch/openwrt-6.1/files/sysctl-tcp-bbr2.conf > package/kernel/linux/files/sysctl-tcp-bbr2.conf
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

# BBRv2 - linux-6.2
pushd target/linux/generic/backport-6.2
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0007-net-tcp_bbr-v2-factor-out-tx.in_flight-setting-into-.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0009-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0010-net-tcp_bbr-v2-set-tx.in_flight-for-skbs-in-repair-w.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0011-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0012-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0013-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0014-net-tcp_bbr-v2-BBRv2-bbr2-congestion-control-for-Lin.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0015-net-test-add-.config-for-kernel-circa-v5.10-with-man.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0016-net-test-adds-a-gce-install.sh-script-to-build-and-i.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0017-net-test-scripts-for-testing-bbr2-with-upstream-Linu.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0018-net-tcp_bbr-v2-add-a-README.md-for-TCP-BBR-v2-alpha-.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0019-net-tcp_bbr-v2-remove-unnecessary-rs.delivered_ce-lo.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0020-net-gbuild-add-Gconfig.bbr2-to-gbuild-kernel-with-CO.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0021-net-tcp_bbr-v2-remove-field-bw_rtts-that-is-unused-i.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0022-net-tcp_bbr-v2-remove-cycle_rand-parameter-that-is-u.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0023-net-test-use-crt-namespace-when-nsperf-disables-crt..patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0024-net-tcp_bbr-v2-don-t-assume-prior_cwnd-was-set-enter.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/bbr2_6.2/0025-net-tcp_bbr-v2-Fix-missing-ECT-markings-on-retransmi.patch
popd

# LRNG
pushd target/linux/generic/backport-6.2
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0003-LRNG-proc-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0005-LRNG-add-common-generic-hash-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0016-LRNG-CPU-entropy-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0017-crypto-move-Jitter-RNG-header-include-dir.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0018-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0019-LRNG-add-option-to-enable-runtime-entropy-rate-c.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0020-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0021-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0022-LRNG-sysctls-and-proc-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0023-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0024-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0025-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os https://$mirror/openwrt/patch/kernel-6.1/lrng-49/v49-0026-LRNG-add-hwrand-framework-interface.patch
popd
cp -a target/linux/generic/backport-6.2/v49-*.patch target/linux/generic/backport-6.1/
curl -o target/linux/generic/backport-6.1/v49-01-add_arch_get_random_longs_early.patch https://$mirror/openwrt/patch/kernel-6.1/lrng-49/backports-6.1/v49-01-add_arch_get_random_longs_early.patch
curl -o target/linux/generic/backport-6.1/v49-02-revert_add_hwgenerator_randomness_update.patch https://$mirror/openwrt/patch/kernel-6.1/lrng-49/backports-6.1/v49-02-revert_add_hwgenerator_randomness_update.patch
curl -s https://$mirror/openwrt/patch/kernel-6.1/config-lrng | tee -a target/linux/generic/config-6.1 target/linux/generic/config-6.2

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
