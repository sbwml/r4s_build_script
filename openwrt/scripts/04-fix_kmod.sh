#!/bin/bash -e

# Fix linux-6.1

# siit
rm -rf feeds/packages/net/siit
cp -a ../master/packages/net/siit feeds/packages/net/siit

# packages
pushd feeds/packages
  # libpfring
  curl -s https://github.com/openwrt/packages/commit/bb680495b431a84f866e9d7caaa90e33058b1c50.patch | patch -p1
  curl -s https://github.com/openwrt/packages/commit/cf8709e848c7f35d17114449ad4be350d11f1981.patch | patch -p1
  # xr_usb_serial_common
  curl -s https://github.com/openwrt/packages/commit/23a3ea2d6b3779cd48d318b95a3c72cad9433d50.patch | patch -p1
  # ovpn-dco
  curl -s https://github.com/openwrt/packages/commit/64ca586a774872f1c659b103a172610ef9684b9a.patch | patch -p1
  # coova-chilli
  curl -s https://github.com/openwrt/packages/commit/9975e855adcfc24939080a5e0279e0a90553347b.patch | patch -p1
  curl -s https://github.com/openwrt/packages/commit/c0683d3f012096fc7b2fbe8b8dc81ea424945e9b.patch | patch -p1
  # xtables-addons
  curl -s https://github.com/openwrt/packages/commit/c4b55eea7f242e4c6dd06efca66280b856841299.patch | patch -p1
  [ "$KERNEL_TESTING" = 1 ] && curl -s https://$mirror/openwrt/patch/openwrt-6.1/feeds/xtables-addons/999-fix-linux-6.2.patch > net/xtables-addons/patches/999-fix-linux-6.2.patch
  # jool - fix linux-6.2
  [ "$KERNEL_TESTING" = 1 ] && curl -s https://$mirror/openwrt/patch/openwrt-6.1/feeds/jool/002-fix-linux-6.2.patch > net/jool/patches/002-fix-linux-6.2.patch
  # ovpn-dco - fix linux-6.2
  [ "$KERNEL_TESTING" = 1 ] && curl -s https://$mirror/openwrt/patch/openwrt-6.1/feeds/ovpn-dco/Makefile > kernel/ovpn-dco/Makefile
popd

# telephony
pushd feeds/telephony
  # dahdi-linux
  curl -s https://github.com/openwrt/telephony/commit/8de8e59c9a47f9605b325cc6ac517369f766797f.patch | patch -p1
  # rtpengine
  curl -s https://github.com/openwrt/telephony/commit/432432458a480e1231ae804c0aecfdb5f27f0db8.patch | patch -p1
popd

# routing - batman-adv
rm -rf feeds/routing/batman-adv
cp -a ../master/routing/batman-adv feeds/routing/batman-adv

# mdio-netlink - fix 6.3
if [ "$KERNEL_TESTING" = 1 ]; then
  mkdir feeds/packages/kernel/mdio-netlink/patches
  curl -s https://$mirror/openwrt/patch/openwrt-6.1/fix-linux-6.3/mdio-netlink/001-fix-linux-6.3.patch > feeds/packages/kernel/mdio-netlink/patches/001-fix-linux-6.3.patch
fi
