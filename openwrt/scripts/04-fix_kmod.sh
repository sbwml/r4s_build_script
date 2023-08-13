#!/bin/bash -e

# Fix linux-6.1

# siit
rm -rf feeds/packages/net/siit
cp -a ../master/packages/net/siit feeds/packages/net/siit

# packages
pushd feeds/packages
  # libpfring - 8.2.0
  rm -rf libs/libpfring/patches/*.patch
  curl -s https://$mirror/openwrt/patch/openwrt-6.1/libpfring/Makefile > libs/libpfring/Makefile
  curl -s https://$mirror/openwrt/patch/openwrt-6.1/libpfring/patches/0001-fix-cross-compiling.patch > libs/libpfring/patches/0001-fix-cross-compiling.patch
  curl -s https://$mirror/openwrt/patch/openwrt-6.1/libpfring/patches/0002-fixups-for-kernel-5.18.x.patch > libs/libpfring/patches/0002-fixups-for-kernel-5.18.x.patch
  # xr_usb_serial_common
  curl -s https://github.com/openwrt/packages/commit/23a3ea2d6b3779cd48d318b95a3c72cad9433d50.patch | patch -p1
  # coova-chilli
  curl -s https://github.com/openwrt/packages/commit/9975e855adcfc24939080a5e0279e0a90553347b.patch | patch -p1
  curl -s https://github.com/openwrt/packages/commit/c0683d3f012096fc7b2fbe8b8dc81ea424945e9b.patch | patch -p1
  # xtables-addons
  rm -rf net/xtables-addons
  git clone https://github.com/sbwml/feeds_packages_net_xtables-addons net/xtables-addons
popd

# telephony
pushd feeds/telephony
  # dahdi-linux
  rm -rf libs/dahdi-linux
  git clone https://github.com/sbwml/feeds_telephony_libs_dahdi-linux libs/dahdi-linux
popd

# routing - batman-adv
rm -rf feeds/routing/batman-adv
cp -a ../master/routing/batman-adv feeds/routing/batman-adv
