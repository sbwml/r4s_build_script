#!/bin/bash -e

# Fix linux-6.1

# siit
rm -rf feeds/packages/net/siit
cp -a ../master/packages/net/siit feeds/packages/net/siit

# libpfring
rm -rf feeds/packages/libs/libpfring
cp -a ../master/packages/libs/libpfring feeds/packages/libs/libpfring

# packages
pushd feeds/packages
  # xr_usb_serial_common
  curl -s https://github.com/openwrt/packages/commit/23a3ea2d6b3779cd48d318b95a3c72cad9433d50.patch | patch -p1
  # coova-chilli
  curl -s https://github.com/openwrt/packages/commit/9975e855adcfc24939080a5e0279e0a90553347b.patch | patch -p1
  curl -s https://github.com/openwrt/packages/commit/c0683d3f012096fc7b2fbe8b8dc81ea424945e9b.patch | patch -p1
popd
# xtables-addons
rm -rf feeds/packages/net/xtables-addons
cp -a ../master/packages/net/xtables-addons feeds/packages/net/xtables-addons

# telephony
pushd feeds/telephony
  # dahdi-linux
  rm -rf libs/dahdi-linux
  git clone https://github.com/sbwml/feeds_telephony_libs_dahdi-linux libs/dahdi-linux
popd

# routing - batman-adv
rm -rf feeds/routing/batman-adv
cp -a ../master/routing/batman-adv feeds/routing/batman-adv
