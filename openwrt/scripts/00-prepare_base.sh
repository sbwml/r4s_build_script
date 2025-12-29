#!/bin/bash -e

# Rockchip - rkbin & u-boot
rm -rf package/boot/rkbin package/boot/uboot-rockchip package/boot/arm-trusted-firmware-rockchip
if [ "$platform" = "rk3399" ]; then
    git clone https://$github/sbwml/package_boot_uboot-rockchip package/boot/uboot-rockchip -b v2023.04
    git clone https://$github/sbwml/arm-trusted-firmware-rockchip package/boot/arm-trusted-firmware-rockchip -b 0419
else
    git clone https://$github/sbwml/package_boot_uboot-rockchip package/boot/uboot-rockchip
    git clone https://$github/sbwml/arm-trusted-firmware-rockchip package/boot/arm-trusted-firmware-rockchip
fi

# patch source
curl -s $mirror/openwrt/patch/generic-25.12/0001-tools-add-upx-tools.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0002-rootfs-add-upx-compression-support.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0003-rootfs-add-r-w-permissions-for-UCI-configuration-fil.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0004-rootfs-Add-support-for-local-kmod-installation-sourc.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0005-kernel-Add-support-for-llvm-clang-compiler.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0006-build-kernel-add-out-of-tree-kernel-config.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0007-include-kernel-add-miss-config-for-linux-6.11.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0008-meson-add-platform-variable-to-cross-compilation-fil.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0009-tools-squashfs4-enable-lz4-zstd-compression-support.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0010-kernel-add-PREEMPT_RT-support-for-aarch64-x86_64.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0011-config-include-image-add-support-for-squashfs-zstd-c.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0012-include-kernel-Always-collect-module-symvers.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-25.12/0013-include-netfilter-update-kernel-config-options-for-l.patch | patch -p1

# add source mirror
#sed -i '/"@OPENWRT": \[/a\\t\t"https://sources-cdn-openwrt.cooluc.com",' scripts/projectsmirrors.json
sed -i '/"@OPENWRT": \[/a\\t\t"https://source.cooluc.com",' scripts/projectsmirrors.json

# attr no-mold
[ "$ENABLE_MOLD" = "y" ] && sed -i '/PKG_BUILD_PARALLEL/aPKG_BUILD_FLAGS:=no-mold' feeds/packages/utils/attr/Makefile

# x86 - disable mitigations
sed -i 's/noinitrd/noinitrd mitigations=off/g' target/linux/x86/image/grub-efi.cfg

# default LAN IP
sed -i "s/192.168.1.1/$LAN/g" package/base-files/files/bin/config_generate

# default password
if [ -n "$ROOT_PASSWORD" ]; then
    # sha256 encryption
    default_password=$(openssl passwd -5 $ROOT_PASSWORD)
    sed -i "s|^root:[^:]*:|root:${default_password}:|" package/base-files/files/etc/shadow
fi

# Use nginx instead of uhttpd
if [ "$ENABLE_UHTTPD" != "y" ]; then
    sed -i 's/+uhttpd /+luci-nginx /g' feeds/luci/collections/luci/Makefile
    sed -i 's/+uhttpd-mod-ubus //' feeds/luci/collections/luci/Makefile
    sed -i 's/+uhttpd /+luci-nginx /g' feeds/luci/collections/luci-light/Makefile
    sed -i "s/+luci /+luci-nginx /g" feeds/luci/collections/luci-ssl-openssl/Makefile
    sed -i "s/+luci /+luci-nginx /g" feeds/luci/collections/luci-ssl/Makefile
    if [ "$version" = "dev" ] || [ "$version" = "rc2" ]; then
        sed -i 's/+uhttpd +uhttpd-mod-ubus /+luci-nginx /g' feeds/packages/net/wg-installer/Makefile
        sed -i '/uhttpd-mod-ubus/d' feeds/luci/collections/luci-light/Makefile
        sed -i 's/+luci-nginx \\$/+luci-nginx/' feeds/luci/collections/luci-light/Makefile
    fi
fi

# drop attendedsysupgrade
sed -i '/luci-app-attendedsysupgrade/d' \
    feeds/luci/collections/luci-nginx/Makefile \
    feeds/luci/collections/luci-ssl-openssl/Makefile \
    feeds/luci/collections/luci-ssl/Makefile \
    feeds/luci/collections/luci/Makefile

# Realtek driver - R8168 & R8125 & R8126 & R8152 & R8101 & r8127
rm -rf package/kernel/{r8168,r8101,r8125,r8126,r8127}
git clone https://$github/sbwml/package_kernel_r8168 package/kernel/r8168
git clone https://$github/sbwml/package_kernel_r8152 package/kernel/r8152
git clone https://$github/sbwml/package_kernel_r8101 package/kernel/r8101
git clone https://$github/sbwml/package_kernel_r8125 package/kernel/r8125
git clone https://$github/sbwml/package_kernel_r8126 package/kernel/r8126
git clone https://$github/sbwml/package_kernel_r8127 package/kernel/r8127

# GCC Optimization level -O3
curl -s $mirror/openwrt/patch/target-modify_for_aarch64_x86_64.patch | patch -p1

# libubox
sed -i '/TARGET_CFLAGS/ s/$/ -Os/' package/libs/libubox/Makefile

# DPDK & NUMACTL
mkdir -p package/new/{dpdk/patches,numactl}
curl -s $mirror/openwrt/patch/dpdk/dpdk/Makefile > package/new/dpdk/Makefile
curl -s $mirror/openwrt/patch/dpdk/dpdk/Config.in > package/new/dpdk/Config.in
curl -s $mirror/openwrt/patch/dpdk/dpdk/patches/010-dpdk_arm_build_platform_fix.patch > package/new/dpdk/patches/010-dpdk_arm_build_platform_fix.patch
curl -s $mirror/openwrt/patch/dpdk/dpdk/patches/201-r8125-add-r8125-ethernet-poll-mode-driver.patch > package/new/dpdk/patches/201-r8125-add-r8125-ethernet-poll-mode-driver.patch
curl -s $mirror/openwrt/patch/dpdk/numactl/Makefile > package/new/numactl/Makefile

# IF USE GLIBC
if [ "$ENABLE_GLIBC" = "y" ]; then
    # musl-libc
    git clone https://$gitea/sbwml/package_libs_musl-libc package/libs/musl-libc
    # glibc-common
    curl -s $mirror/openwrt/patch/glibc/glibc-common.patch | patch -p1
    # glibc-common - locale data
    mkdir -p package/libs/toolchain/glibc-locale
    curl -Lso package/libs/toolchain/glibc-locale/locale-archive https://github.com/sbwml/r4s_build_script/releases/download/locale/locale-archive
    [ "$?" -ne 0 ] && echo -e "${RED_COLOR} Locale file download failed... ${RES}"
    # GNU LANG
    mkdir package/base-files/files/etc/profile.d
    echo 'export LANG="en_US.UTF-8" I18NPATH="/usr/share/i18n"' > package/base-files/files/etc/profile.d/sys_locale.sh
    # build - drop `--disable-profile`
    sed -i "/disable-profile/d" toolchain/glibc/common.mk
fi

# fstools
rm -rf package/system/fstools
git clone https://$github/sbwml/package_system_fstools -b openwrt-25.12 package/system/fstools
# util-linux
rm -rf package/utils/util-linux
git clone https://$github/sbwml/package_utils_util-linux -b openwrt-25.12 package/utils/util-linux

# Shortcut Forwarding Engine
git clone https://$gitea/sbwml/shortcut-fe package/new/shortcut-fe

# Patch FireWall 4
if [ "$version" = "dev" ] || [ "$version" = "rc2" ]; then
    # firewall4
    sed -i 's|$(PROJECT_GIT)/project|https://github.com/openwrt|g' package/network/config/firewall4/Makefile
    mkdir -p package/network/config/firewall4/patches
    # fix ct status dnat
    curl -s $mirror/openwrt/patch/firewall4/firewall4_patches/990-unconditionally-allow-ct-status-dnat.patch > package/network/config/firewall4/patches/990-unconditionally-allow-ct-status-dnat.patch
    # fullcone
    curl -s $mirror/openwrt/patch/firewall4/firewall4_patches/999-01-firewall4-add-fullcone-support.patch > package/network/config/firewall4/patches/999-01-firewall4-add-fullcone-support.patch
    # bcm fullcone
    curl -s $mirror/openwrt/patch/firewall4/firewall4_patches/999-02-firewall4-add-bcm-fullconenat-support.patch > package/network/config/firewall4/patches/999-02-firewall4-add-bcm-fullconenat-support.patch
    # fix flow offload
    curl -s $mirror/openwrt/patch/firewall4/firewall4_patches/001-fix-fw4-flow-offload.patch > package/network/config/firewall4/patches/001-fix-fw4-flow-offload.patch
    # add custom nft command support
    curl -s $mirror/openwrt/patch/firewall4/100-openwrt-firewall4-add-custom-nft-command-support.patch | patch -p1
    # libnftnl
    mkdir -p package/libs/libnftnl/patches
    curl -s $mirror/openwrt/patch/firewall4/libnftnl/0001-libnftnl-add-fullcone-expression-support.patch > package/libs/libnftnl/patches/0001-libnftnl-add-fullcone-expression-support.patch
    curl -s $mirror/openwrt/patch/firewall4/libnftnl/0002-libnftnl-add-brcm-fullcone-support.patch > package/libs/libnftnl/patches/0002-libnftnl-add-brcm-fullcone-support.patch
    # fix build on rhel9
    sed -i '/^PKG_BUILD_FLAGS[[:space:]]*:/aPKG_FIXUP:=autoreconf' package/libs/libnftnl/Makefile
    # nftables
    mkdir -p package/network/utils/nftables/patches
    curl -s $mirror/openwrt/patch/firewall4/nftables/0001-nftables-add-fullcone-expression-support.patch > package/network/utils/nftables/patches/0001-nftables-add-fullcone-expression-support.patch
    curl -s $mirror/openwrt/patch/firewall4/nftables/0002-nftables-add-brcm-fullconenat-support.patch > package/network/utils/nftables/patches/0002-nftables-add-brcm-fullconenat-support.patch
fi

# FullCone module
git clone https://$gitea/sbwml/nft-fullcone package/new/nft-fullcone

# IPv6 NAT
git clone https://$github/sbwml/packages_new_nat6 package/new/nat6 -b openwrt-25.12

# natflow
git clone https://$github/sbwml/package_new_natflow package/new/natflow

# Patch Luci add nft_fullcone/bcm_fullcone & shortcut-fe & natflow & ipv6-nat & custom nft command option
pushd feeds/luci
    curl -s $mirror/openwrt/patch/firewall4/luci-25.12/0001-luci-app-firewall-add-nft-fullcone-and-bcm-fullcone-.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-25.12/0002-luci-app-firewall-add-shortcut-fe-option.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-25.12/0003-luci-app-firewall-add-ipv6-nat-option.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-25.12/0004-luci-add-firewall-add-custom-nft-rule-support.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-25.12/0005-luci-app-firewall-add-natflow-offload-support.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-25.12/0006-luci-app-firewall-enable-hardware-offload-only-on-de.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-25.12/0007-luci-app-firewall-add-fullcone6-option-for-nftables-.patch | patch -p1
popd

# openssl urandom
sed -i "/-openwrt/iOPENSSL_OPTIONS += enable-ktls '-DDEVRANDOM=\"\\\\\"/dev/urandom\\\\\"\"\'\n" package/libs/openssl/Makefile

# openssl - lto
if [ "$ENABLE_LTO" = "y" ]; then
    sed -i "s/ no-lto//g" package/libs/openssl/Makefile
    sed -i "/TARGET_CFLAGS +=/ s/\$/ -ffat-lto-objects/" package/libs/openssl/Makefile
fi

# nghttp3
rm -rf feeds/packages/libs/nghttp3
git clone https://$github/sbwml/package_libs_nghttp3 package/libs/nghttp3

# ngtcp2
rm -rf feeds/packages/libs/ngtcp2
git clone https://$github/sbwml/package_libs_ngtcp2 package/libs/ngtcp2

# curl - fix passwall `time_pretransfer` check
rm -rf feeds/packages/net/curl
git clone https://$github/sbwml/feeds_packages_net_curl feeds/packages/net/curl

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://$gitea/sbwml/luci-app-dockerman -b nft feeds/luci/applications/luci-app-dockerman
if [ "$version" = "dev" ] || [ "$version" = "rc2" ]; then
    rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
    git clone https://$gitea/sbwml/packages_utils_docker feeds/packages/utils/docker
    git clone https://$gitea/sbwml/packages_utils_dockerd feeds/packages/utils/dockerd
    git clone https://$gitea/sbwml/packages_utils_containerd feeds/packages/utils/containerd
    git clone https://$gitea/sbwml/packages_utils_runc feeds/packages/utils/runc
fi

# procps-ng - top
sed -i 's/enable-skill/enable-skill --disable-modern-top/g' feeds/packages/utils/procps-ng/Makefile

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# UPnP
rm -rf feeds/{packages/net/miniupnpd,luci/applications/luci-app-upnp}
git clone https://$gitea/sbwml/miniupnpd feeds/packages/net/miniupnpd -b v2.3.9
git clone https://$gitea/sbwml/luci-app-upnp feeds/luci/applications/luci-app-upnp -b openwrt-24.10

# nginx - latest version
rm -rf feeds/packages/net/nginx
git clone https://$github/sbwml/feeds_packages_net_nginx feeds/packages/net/nginx -b openwrt-24.10
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g;s/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/net/nginx/files/nginx.init

# nginx - ubus
sed -i 's/ubus_parallel_req 2/ubus_parallel_req 6/g' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 300;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support

# nginx - config
curl -s $mirror/openwrt/nginx/luci.locations > feeds/packages/net/nginx/files-luci-support/luci.locations
curl -s $mirror/openwrt/nginx/uci.conf.template > feeds/packages/net/nginx-util/files/uci.conf.template

# netifd
curl -s $mirror/openwrt/patch/netifd/001-hack-packet_steering-for-nanopi-r76s.patch | patch -p1

# opkg
mkdir -p package/system/opkg/patches
curl -s $mirror/openwrt/patch/opkg/900-opkg-download-disable-hsts.patch > package/system/opkg/patches/900-opkg-download-disable-hsts.patch
curl -s $mirror/openwrt/patch/opkg/901-libopkg-opkg_install-copy-conffiles-to-the-system-co.patch > package/system/opkg/patches/901-libopkg-opkg_install-copy-conffiles-to-the-system-co.patch

# uwsgi - fix timeout
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i '/limit-as/c\limit-as = 5000' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# disable error log
sed -i "s/procd_set_param stderr 1/procd_set_param stderr 0/g" feeds/packages/net/uwsgi/files/uwsgi.init

# uwsgi - performance
sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# rpcd - fix timeout
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

# luci-mod extra
pushd feeds/luci
    curl -s $mirror/openwrt/patch/luci/0001-luci-mod-system-add-modal-overlay-dialog-to-reboot.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0002-luci-mod-status-displays-actual-process-memory-usage.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0003-luci-mod-status-storage-index-applicable-only-to-val.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0004-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0005-luci-mod-system-add-refresh-interval-setting.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0006-luci-mod-system-mounts-add-docker-directory-mount-po.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0007-luci-mod-system-add-ucitrack-luci-mod-system-zram.js.patch | patch -p1
popd

# Luci diagnostics.js
sed -i "s/openwrt.org/www.qq.com/g" feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/diagnostics.js

# luci - disable wireless WPA3
[ "$platform" = "bcm53xx" ] && sed -i -e '/if (has_ap_sae || has_sta_sae) {/{N;N;N;N;d;}' feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/wireless.js

# luci-compat - remove extra line breaks from description
sed -i '/<br \/>/d' feeds/luci/modules/luci-compat/luasrc/view/cbi/full_valuefooter.htm

# urngd - 2020-01-21
rm -rf package/system/urngd
git clone https://$github/sbwml/package_system_urngd package/system/urngd

# zlib - 1.3
ZLIB_VERSION=1.3.1
ZLIB_HASH=38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32
sed -ri "s/(PKG_VERSION:=)[^\"]*/\1$ZLIB_VERSION/;s/(PKG_HASH:=)[^\"]*/\1$ZLIB_HASH/" package/libs/zlib/Makefile

# profile
sed -i 's#\\u@\\h:\\w\\\$#\\[\\e[32;1m\\][\\u@\\h\\[\\e[0m\\] \\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\[\\e[32;1m\\]]\\[\\e[0m\\]\\\$#g' package/base-files/files/etc/profile
sed -ri 's/(export PATH=")[^"]*/\1%PATH%:\/opt\/bin:\/opt\/sbin:\/opt\/usr\/bin:\/opt\/usr\/sbin/' package/base-files/files/etc/profile
sed -i '/ENV/i\export TERM=xterm-color' package/base-files/files/etc/profile

# bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
curl -so files/root/.bash_profile $mirror/openwrt/files/root/.bash_profile
curl -so files/root/.bashrc $mirror/openwrt/files/root/.bashrc

# rootfs files
mkdir -p files/etc/sysctl.d
curl -so files/etc/sysctl.d/10-default.conf $mirror/openwrt/files/etc/sysctl.d/10-default.conf
curl -so files/etc/sysctl.d/15-vm-swappiness.conf $mirror/openwrt/files/etc/sysctl.d/15-vm-swappiness.conf
curl -so files/etc/sysctl.d/16-udp-buffer-size.conf $mirror/openwrt/files/etc/sysctl.d/16-udp-buffer-size.conf
if [ "$platform" = "bcm53xx" ]; then
    mkdir -p files/etc/hotplug.d/block
    curl -so files/etc/hotplug.d/block/20-usbreset $mirror/openwrt/files/etc/hotplug.d/block/20-usbreset
fi

# NTP
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate

# luci-theme-bootstrap
sed -i 's/font-size: 13px/font-size: 14px/g' feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/cascade.css
sed -i 's/9.75px/10.75px/g' feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/cascade.css
