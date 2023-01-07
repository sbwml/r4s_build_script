#!/bin/bash

# Fix linux-6.1

# siit
rm -rf feeds/packages/net/siit
svn export https://github.com/openwrt/packages/branches/master/net/siit feeds/packages/net/siit

# packages
pushd feeds/packages
  # libpfring
  curl -s https://github.com/openwrt/packages/commit/bb680495b431a84f866e9d7caaa90e33058b1c50.patch | patch -p1
  curl -s https://github.com/openwrt/packages/commit/cf8709e848c7f35d17114449ad4be350d11f1981.patch | patch -p1
  # xr_usb_serial_common
  curl -s https://github.com/openwrt/packages/commit/23a3ea2d6b3779cd48d318b95a3c72cad9433d50.patch | patch -p1
  # coova-chilli
  curl -s https://github.com/openwrt/packages/commit/9975e855adcfc24939080a5e0279e0a90553347b.patch | patch -p1
  curl -s https://github.com/openwrt/packages/commit/c0683d3f012096fc7b2fbe8b8dc81ea424945e9b.patch | patch -p1
  # xtables-addons
  curl -s https://github.com/openwrt/packages/commit/c4b55eea7f242e4c6dd06efca66280b856841299.patch | patch -p1
  curl -s https://$mirror/openwrt/patch/openwrt-6.2/feeds/xtables-addons/999-fix-linux-6.2.patch > net/xtables-addons/patches/999-fix-linux-6.2.patch
  # jool - fix linux-6.2
  curl -s https://$mirror/openwrt/patch/openwrt-6.2/feeds/jool/002-fix-linux-6.2.patch > net/jool/patches/002-fix-linux-6.2.patch
  # ovpn-dco - fix linux-6.2 - temp
  curl -s https://$mirror/openwrt/patch/openwrt-6.2/feeds/ovpn-dco/Makefile > kernel/ovpn-dco/Makefile
popd

# telephony
pushd feeds/telephony
  # dahdi-linux
  curl -s https://github.com/openwrt/telephony/commit/8de8e59c9a47f9605b325cc6ac517369f766797f.patch | patch -p1
  # rtpengine
  curl -s https://github.com/openwrt/telephony/commit/432432458a480e1231ae804c0aecfdb5f27f0db8.patch | patch -p1
popd

# routing - batman-adv - linux 6.2
rm -rf feeds/routing/batman-adv
svn export -r 1947 https://github.com/immortalwrt/routing/branches/master/batman-adv feeds/routing/batman-adv
curl -s https://$mirror/openwrt/patch/openwrt-6.2/feeds/batman-adv/001-batman-adv-fix-linux-6.2.patch > feeds/routing/batman-adv/patches/0005-fix-linux-6.2.patch
curl -s https://$mirror/openwrt/patch/openwrt-6.2/feeds/batman-adv/002-batman-adv-fix-linux-6.2.patch > feeds/routing/batman-adv/patches/0006-fix-linux-6.2.patch
