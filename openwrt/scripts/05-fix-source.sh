#!/bin/bash

# Chinese translation
# luci-app-firewall
curl -s https://raw.githubusercontent.com/openwrt/luci/openwrt-23.05/applications/luci-app-firewall/po/zh_Hans/firewall.po > feeds/luci/applications/luci-app-firewall/po/zh_Hans/firewall.po

# drop antfs
rm -rf feeds/packages/kernel/antfs feeds/packages/utils/antfs-mount

# uqmi - fix gcc11
sed -i '/dangling-pointer/d' package/network/utils/uqmi/Makefile

# xdp-tools
[ "$platform" != "x86_64" ] && sed -i '/TARGET_LDFLAGS +=/iTARGET_CFLAGS += -Wno-error=maybe-uninitialized\n' package/network/utils/xdp-tools/Makefile

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

#### bpf #####

# add clang-15/17 support
sed -i 's/command -v clang/command -v clang clang-17 clang-15/g' include/bpf.mk

#### glibc #####

# uqmi
if [ "$USE_GLIBC" = "y" ]; then
    sed -i 's/-Wno-error=maybe-uninitialized/-Wno-error=maybe-uninitialized \\\n\t-Wno-error=dangling-pointer/g' package/network/utils/uqmi/Makefile
fi
