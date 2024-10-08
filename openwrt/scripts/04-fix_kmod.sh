#!/bin/bash -e

# Fix build for linux-6.6/6.12

# cryptodev-linux
if [ "$version" = "rc2" ]; then
    mkdir -p package/kernel/cryptodev-linux/patches
    curl -s https://$mirror/openwrt/patch/packages-patches/cryptodev-linux/001-Fix-build-for-Linux-6.3-rc1.patch > package/kernel/cryptodev-linux/patches/001-Fix-build-for-Linux-6.3-rc1.patch
    curl -s https://$mirror/openwrt/patch/packages-patches/cryptodev-linux/002-fix-build-for-linux-6.7-rc1.patch > package/kernel/cryptodev-linux/patches/002-fix-build-for-linux-6.7-rc1.patch
fi

# gpio-button-hotplug
[ "$version" = "rc2" ] && curl -s https://$mirror/openwrt/patch/packages-patches/gpio-button-hotplug/fix-linux-6.6.patch | patch -p1
curl -s https://$mirror/openwrt/patch/packages-patches/gpio-button-hotplug/fix-linux-6.12.patch | patch -p1

# gpio-nct5104d
curl -s https://$mirror/openwrt/patch/packages-patches/gpio-nct5104d/fix-build-for-linux-6.6.patch | patch -p1
curl -s https://$mirror/openwrt/patch/packages-patches/gpio-nct5104d/fix-build-for-linux-6.12.patch | patch -p1

# dmx_usb_module
if [ "$version" = "rc2" ]; then
    mkdir -p feeds/packages/libs/dmx_usb_module/patches
    curl -s https://$mirror/openwrt/patch/packages-patches/dmx_usb_module/900-fix-linux-6.6.patch > feeds/packages/libs/dmx_usb_module/patches/900-fix-linux-6.6.patch
fi

# jool
[ "$version" = "rc2" ] && \
    curl -s https://$mirror/openwrt/patch/packages-patches/jool/Makefile > feeds/packages/net/jool/Makefile || \
    curl -s https://$mirror/openwrt/patch/packages-patches/jool/Makefile.24 > feeds/packages/net/jool/Makefile

# mdio-netlink
if [ "$version" = "rc2" ]; then
    mkdir -p feeds/packages/kernel/mdio-netlink/patches
    curl -s https://$mirror/openwrt/patch/packages-patches/mdio-netlink/001-mdio-netlink-rework-C45-to-work-with-net-next.patch > feeds/packages/kernel/mdio-netlink/patches/001-mdio-netlink-rework-C45-to-work-with-net-next.patch
fi

# ovpn-dco
mkdir -p feeds/packages/kernel/ovpn-dco/patches
if [ "$version" = "rc2" ]; then
    curl -s https://$mirror/openwrt/patch/packages-patches/ovpn-dco/100-ovpn-dco-adapt-pre-post_doit-CBs-to-new-signature.patch > feeds/packages/kernel/ovpn-dco/patches/100-ovpn-dco-adapt-pre-post_doit-CBs-to-new-signature.patch
    curl -s https://$mirror/openwrt/patch/packages-patches/ovpn-dco/900-fix-linux-6.6.patch > feeds/packages/kernel/ovpn-dco/patches/900-fix-linux-6.6.patch
fi
curl -s https://$mirror/openwrt/patch/packages-patches/ovpn-dco/901-fix-linux-6.11.patch > feeds/packages/kernel/ovpn-dco/patches/901-fix-linux-6.11.patch
curl -s https://$mirror/openwrt/patch/packages-patches/ovpn-dco/902-fix-linux-6.12.patch > feeds/packages/kernel/ovpn-dco/patches/902-fix-linux-6.12.patch

# siit
if [ "$version" = "rc2" ]; then
    rm -rf feeds/packages/net/siit
    cp -a ../master/packages/net/siit feeds/packages/net/siit
fi

# libpfring
rm -rf feeds/packages/libs/libpfring
mkdir -p feeds/packages/libs/libpfring/patches
curl -s https://$mirror/openwrt/patch/packages-patches/libpfring/Makefile > feeds/packages/libs/libpfring/Makefile
pushd feeds/packages/libs/libpfring/patches
  curl -Os https://$mirror/openwrt/patch/packages-patches/libpfring/patches/0001-fix-cross-compiling.patch
  curl -Os https://$mirror/openwrt/patch/packages-patches/libpfring/patches/100-fix-compilation-warning.patch
  curl -Os https://$mirror/openwrt/patch/packages-patches/libpfring/patches/900-fix-linux-6.6.patch
popd

# nat46
mkdir -p package/kernel/nat46/patches
curl -s https://$mirror/openwrt/patch/packages-patches/nat46/100-fix-build-with-kernel-6.9.patch > package/kernel/nat46/patches/100-fix-build-with-kernel-6.9.patch
curl -s https://$mirror/openwrt/patch/packages-patches/nat46/101-fix-build-with-kernel-6.12.patch > package/kernel/nat46/patches/101-fix-build-with-kernel-6.12.patch

# v4l2loopback - 6.12
if [ "$version" = "rc2" ]; then
    mkdir -p feeds/packages/kernel/v4l2loopback/patches
    curl -s https://$mirror/openwrt/patch/packages-patches/v4l2loopback/100-fix-build-with-linux-6.12.patch > feeds/packages/kernel/v4l2loopback/patches/100-fix-build-with-linux-6.12.patch
fi

# openvswitch
if [ "$TESTING_KERNEL" = "y" ]; then
    sed -i '/ovs_kmod_openvswitch_depends/a\\t\ \ +kmod-sched-act-sample \\' feeds/packages/net/openvswitch/Makefile
fi

# rtpengine
if [ "$TESTING_KERNEL" = "y" ] && [ "$version" = "snapshots-24.10" ]; then
    curl -s https://$mirror/openwrt/patch/packages-patches/rtpengine/900-fix-linux-6.12-11.5.1.18.patch > feeds/telephony/net/rtpengine/patches/900-fix-linux-6.12-11.5.1.18.patch
fi

# ubootenv-nvram - 6.12 (openwrt-23.05.5)
mkdir -p package/kernel/ubootenv-nvram/patches
curl -s https://$mirror/openwrt/patch/packages-patches/ubootenv-nvram/010-make-ubootenv_remove-return-void-for-linux-6.12.patch > package/kernel/ubootenv-nvram/patches/010-make-ubootenv_remove-return-void-for-linux-6.12.patch

# packages
pushd feeds/packages
  # xr_usb_serial_common
  [ "$version" = "rc2" ] && curl -s https://github.com/openwrt/packages/commit/23a3ea2d6b3779cd48d318b95a3c72cad9433d50.patch | patch -p1
  # fix linux-6.6
  [ "$version" = "rc2" ] && curl -s https://$mirror/openwrt/patch/packages-patches/xr_usb_serial_common/900-fix-linux-6.6.patch > libs/xr_usb_serial_common/patches/900-fix-linux-6.6.patch
  # fix linux-6.12
  [ "$TESTING_KERNEL" = "y" ] && curl -s https://$mirror/openwrt/patch/packages-patches/xr_usb_serial_common/0002-fix-kernel-6.12-builds.patch > libs/xr_usb_serial_common/patches/0002-fix-kernel-6.12-builds.patch
  # coova-chilli
  [ "$version" = "rc2" ] && curl -s https://github.com/openwrt/packages/commit/9975e855adcfc24939080a5e0279e0a90553347b.patch | patch -p1
  [ "$version" = "rc2" ] && curl -s https://github.com/openwrt/packages/commit/c0683d3f012096fc7b2fbe8b8dc81ea424945e9b.patch | patch -p1
popd

# xtables-addons
if [ "$version" = "rc2" ]; then
    rm -rf feeds/packages/net/xtables-addons
    cp -a ../master/packages/net/xtables-addons feeds/packages/net/xtables-addons
fi
curl -s https://$mirror/openwrt/patch/packages-patches/xtables-addons/301-fix-build-with-linux-6.12.patch > feeds/packages/net/xtables-addons/patches/301-fix-build-with-linux-6.12.patch
curl -s https://$mirror/openwrt/patch/packages-patches/xtables-addons/302-fix-build-for-linux-6.12rc2.patch > feeds/packages/net/xtables-addons/patches/302-fix-build-for-linux-6.12rc2.patch

# telephony
pushd feeds/telephony
  # dahdi-linux
  rm -rf libs/dahdi-linux
  git clone https://$github/sbwml/feeds_telephony_libs_dahdi-linux libs/dahdi-linux
popd

# routing - batman-adv
if [ "$version" = "rc2" ]; then
    rm -rf feeds/routing/batman-adv
    cp -a ../master/routing/batman-adv feeds/routing/batman-adv
fi
# fix build with linux-6.12
curl -s https://$mirror/openwrt/patch/packages-patches/batman-adv/900-netdev_features-convert-NETIF_F_NETNS_LOCAL-to-dev-netns_local.patch > feeds/routing/batman-adv/patches/900-netdev_features-convert-NETIF_F_NETNS_LOCAL-to-dev-netns_local.patch
curl -s https://$mirror/openwrt/patch/packages-patches/batman-adv/901-fix-linux-6.12rc2-builds.patch > feeds/routing/batman-adv/patches/901-fix-linux-6.12rc2-builds.patch

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
    curl -s https://$mirror/openwrt/patch/packages-patches/clang/netatop/900-fix-build-with-clang.patch > feeds/packages/admin/netatop/patches/900-fix-build-with-clang.patch
    # dmx_usb_module
    rm -rf feeds/packages/libs/dmx_usb_module
    git clone https://$gitea/sbwml/feeds_packages_libs_dmx_usb_module feeds/packages/libs/dmx_usb_module
    # macremapper
    curl -s https://$mirror/openwrt/patch/packages-patches/clang/macremapper/100-macremapper-fix-clang-build.patch | patch -p1
    # coova-chilli module
    rm -rf feeds/packages/net/coova-chilli
    git clone https://$github/sbwml/kmod_packages_net_coova-chilli feeds/packages/net/coova-chilli
fi
