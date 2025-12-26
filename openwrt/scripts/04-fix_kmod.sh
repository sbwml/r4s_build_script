#!/bin/bash -e

# Fix build for 6.18

### BROKEN
sed -i 's/^\([[:space:]]*DEPENDS:=.*\)$/\1 @BROKEN/' package/kernel/rtl8812au-ct/Makefile

# cryptodev-linux
curl -s $mirror/openwrt/patch/packages-patches/cryptodev-linux/6.18/900-fix-linux-6.18.patch > package/kernel/cryptodev-linux/patches/900-fix-linux-6.18.patch

# gpio-button-hotplug
curl -s $mirror/openwrt/patch/packages-patches/gpio-button-hotplug/fix-linux-6.18.patch | patch -p1

# gpio-nct5104d
curl -s $mirror/openwrt/patch/packages-patches/gpio-nct5104d/fix-linux-6.18.patch | patch -p1

# jool
rm -rf feeds/packages/net/jool
mkdir -p feeds/packages/net/jool/patches
curl -s $mirror/openwrt/patch/packages-patches/jool/Makefile > feeds/packages/net/jool/Makefile
curl -s $mirror/openwrt/patch/packages-patches/jool/patches/100-fix-compilation-warning-simple-fix.patch > feeds/packages/net/jool/patches/100-fix-compilation-warning-simple-fix.patch
curl -s $mirror/openwrt/patch/packages-patches/jool/patches/900-fix-build-with-linux-6.18.patch > feeds/packages/net/jool/patches/900-fix-build-with-linux-6.18.patch

# ovpn-dco
rm -rf feeds/packages/kernel/ovpn-dco/patches
curl -s $mirror/openwrt/patch/packages-patches/ovpn-dco/Makefile > feeds/packages/kernel/ovpn-dco/Makefile

# libpfring
rm -rf feeds/packages/libs/libpfring
mkdir -p feeds/packages/libs/libpfring/patches
curl -s $mirror/openwrt/patch/packages-patches/libpfring/Makefile > feeds/packages/libs/libpfring/Makefile
pushd feeds/packages/libs/libpfring/patches
  curl -Os $mirror/openwrt/patch/packages-patches/libpfring/patches/0001-fix-cross-compiling.patch
  curl -Os $mirror/openwrt/patch/packages-patches/libpfring/patches/100-fix-compilation-warning.patch
  curl -Os $mirror/openwrt/patch/packages-patches/libpfring/patches/900-fix-linux-6.6.patch
  curl -Os $mirror/openwrt/patch/packages-patches/libpfring/patches/901-fix-build-for-linux-6.17.patch
popd

# nat46
mkdir -p package/kernel/nat46/patches
curl -s $mirror/openwrt/patch/packages-patches/nat46/102-fix-build-with-kernel-6.18.patch > package/kernel/nat46/patches/102-fix-build-with-kernel-6.18.patch

# openvswitch
sed -i '/ovs_kmod_openvswitch_depends/a\\t\ \ +kmod-sched-act-sample \\' feeds/packages/net/openvswitch/Makefile

# rtpengine
curl -s $mirror/openwrt/patch/packages-patches/rtpengine/901-fix-build-for-linux-6.18.patch > feeds/telephony/net/rtpengine/patches/901-fix-build-for-linux-6.18.patch

# ubootenv-nvram - 6.18
curl -s $mirror/openwrt/patch/packages-patches/ubootenv-nvram/010-fix-build-for-linux-6.18.patch | patch -p1

# usb-serial-xr_usb_serial_common: remove package
# Now that we have packaged the upstream driver[1] and only board[2] that
# includes it by default has been switched to it, remove this out-of-tree
# driver that is broken on 6.12 anyway.
rm -rf feeds/packages/libs/xr_usb_serial_common

# v4l2loopback
rm -rf feeds/packages/kernel/v4l2loopback
mkdir -p feeds/packages/kernel/v4l2loopback
curl -s $mirror/openwrt/patch/packages-patches/v4l2loopback/Makefile > feeds/packages/kernel/v4l2loopback/Makefile

# telephony
pushd feeds/telephony
  # dahdi-linux
  rm -rf libs/dahdi-linux
  git clone https://$github/sbwml/feeds_telephony_libs_dahdi-linux libs/dahdi-linux -b v6.18
popd

# clang
if [ "$KERNEL_CLANG_LTO" = "y" ]; then
    # xtables-addons module
    rm -rf feeds/packages/net/xtables-addons
    git clone https://$github/sbwml/kmod_packages_net_xtables-addons feeds/packages/net/xtables-addons -b openwrt-25.12
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
else
    # coova-chilli - fix gcc 15 c23
    [ "$USE_GCC15" = y ] && sed -i '/TARGET_CFLAGS/s/$/ -std=gnu17/' feeds/packages/net/coova-chilli/Makefile
fi
