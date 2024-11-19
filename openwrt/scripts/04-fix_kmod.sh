#!/bin/bash -e

# Fix build for 6.12

# cryptodev-linux
mkdir -p package/kernel/cryptodev-linux/patches
curl -s $mirror/openwrt/patch/packages-patches/cryptodev-linux/6.12/0005-Fix-cryptodev_verbosity-sysctl-for-Linux-6.11-rc1.patch > package/kernel/cryptodev-linux/patches/0005-Fix-cryptodev_verbosity-sysctl-for-Linux-6.11-rc1.patch
curl -s $mirror/openwrt/patch/packages-patches/cryptodev-linux/6.12/0006-Exclude-unused-struct-since-Linux-6.5.patch > package/kernel/cryptodev-linux/patches/0006-Exclude-unused-struct-since-Linux-6.5.patch

# gpio-button-hotplug
curl -s $mirror/openwrt/patch/packages-patches/gpio-button-hotplug/fix-linux-6.12.patch | patch -p1

# jool
curl -s $mirror/openwrt/patch/packages-patches/jool/Makefile > feeds/packages/net/jool/Makefile

# ovpn-dco
mkdir -p feeds/packages/kernel/ovpn-dco/patches
curl -s $mirror/openwrt/patch/packages-patches/ovpn-dco/901-fix-linux-6.11.patch > feeds/packages/kernel/ovpn-dco/patches/901-fix-linux-6.11.patch
curl -s $mirror/openwrt/patch/packages-patches/ovpn-dco/902-fix-linux-6.12.patch > feeds/packages/kernel/ovpn-dco/patches/902-fix-linux-6.12.patch

# libpfring
rm -rf feeds/packages/libs/libpfring
mkdir -p feeds/packages/libs/libpfring/patches
curl -s $mirror/openwrt/patch/packages-patches/libpfring/Makefile > feeds/packages/libs/libpfring/Makefile
pushd feeds/packages/libs/libpfring/patches
  curl -Os $mirror/openwrt/patch/packages-patches/libpfring/patches/0001-fix-cross-compiling.patch
  curl -Os $mirror/openwrt/patch/packages-patches/libpfring/patches/100-fix-compilation-warning.patch
  curl -Os $mirror/openwrt/patch/packages-patches/libpfring/patches/900-fix-linux-6.6.patch
popd

# nat46
mkdir -p package/kernel/nat46/patches
curl -s $mirror/openwrt/patch/packages-patches/nat46/100-fix-build-with-kernel-6.9.patch > package/kernel/nat46/patches/100-fix-build-with-kernel-6.9.patch
curl -s $mirror/openwrt/patch/packages-patches/nat46/101-fix-build-with-kernel-6.12.patch > package/kernel/nat46/patches/101-fix-build-with-kernel-6.12.patch

# openvswitch
sed -i '/ovs_kmod_openvswitch_depends/a\\t\ \ +kmod-sched-act-sample \\' feeds/packages/net/openvswitch/Makefile

# rtpengine
curl -s $mirror/openwrt/patch/packages-patches/rtpengine/900-fix-linux-6.12-11.5.1.18.patch > feeds/telephony/net/rtpengine/patches/900-fix-linux-6.12-11.5.1.18.patch

# ubootenv-nvram - 6.12
mkdir -p package/kernel/ubootenv-nvram/patches
curl -s $mirror/openwrt/patch/packages-patches/ubootenv-nvram/010-make-ubootenv_remove-return-void-for-linux-6.12.patch > package/kernel/ubootenv-nvram/patches/010-make-ubootenv_remove-return-void-for-linux-6.12.patch

# packages
pushd feeds/packages
  # xr_usb_serial_common linux-6.12
  curl -s $mirror/openwrt/patch/packages-patches/xr_usb_serial_common/0002-fix-kernel-6.12-builds.patch > libs/xr_usb_serial_common/patches/0002-fix-kernel-6.12-builds.patch
popd

# xtables-addons
curl -s $mirror/openwrt/patch/packages-patches/xtables-addons/301-fix-build-with-linux-6.12.patch > feeds/packages/net/xtables-addons/patches/301-fix-build-with-linux-6.12.patch
curl -s $mirror/openwrt/patch/packages-patches/xtables-addons/302-fix-build-for-linux-6.12rc2.patch > feeds/packages/net/xtables-addons/patches/302-fix-build-for-linux-6.12rc2.patch

# telephony
pushd feeds/telephony
  # dahdi-linux
  rm -rf libs/dahdi-linux
  git clone https://$github/sbwml/feeds_telephony_libs_dahdi-linux libs/dahdi-linux
popd

# routing - batman-adv fix build with linux-6.12
curl -s $mirror/openwrt/patch/packages-patches/batman-adv/901-fix-linux-6.12rc2-builds.patch > feeds/routing/batman-adv/patches/901-fix-linux-6.12rc2-builds.patch

# bcm53xx
if [ "$platform" = "bcm53xx" ]; then
    # libpfring
    sed -i '/CONFIGURE_VARS +=/iEXTRA_CFLAGS += -Wno-int-conversion\n' feeds/packages/libs/libpfring/Makefile
fi

# clang
if [ "$KERNEL_CLANG_LTO" = "y" ]; then
    # xtables-addons module
    rm -rf feeds/packages/net/xtables-addons
    git clone https://$github/sbwml/kmod_packages_net_xtables-addons feeds/packages/net/xtables-addons
    # netatop
    sed -i 's/$(MAKE)/$(KERNEL_MAKE)/g' feeds/packages/admin/netatop/Makefile
    curl -s $mirror/openwrt/patch/packages-patches/clang/netatop/900-fix-build-with-clang.patch > feeds/packages/admin/netatop/patches/900-fix-build-with-clang.patch
    # dmx_usb_module
    rm -rf feeds/packages/libs/dmx_usb_module
    git clone https://$gitea/sbwml/feeds_packages_libs_dmx_usb_module feeds/packages/libs/dmx_usb_module
    # macremapper
    curl -s $mirror/openwrt/patch/packages-patches/clang/macremapper/100-macremapper-fix-clang-build.patch | patch -p1
    # coova-chilli module
    rm -rf feeds/packages/net/coova-chilli
    git clone https://$github/sbwml/kmod_packages_net_coova-chilli feeds/packages/net/coova-chilli
fi
