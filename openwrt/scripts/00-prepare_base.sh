#!/bin/bash -e

# Rockchip - rkbin & u-boot 2023.07
rm -rf package/boot/uboot-rockchip package/boot/arm-trusted-firmware-rockchip
git clone https://github.com/sbwml/package_boot_uboot-rockchip package/boot/uboot-rockchip
git clone https://github.com/sbwml/arm-trusted-firmware-rockchip package/boot/arm-trusted-firmware-rockchip

# BTF: fix failed to validate module
# config/Config-kernel.in patch
curl -s https://$mirror/openwrt/patch/generic/0001-kernel-add-MODULE_ALLOW_BTF_MISMATCH-option.patch | patch -p1

# Fix x86 - CONFIG_ALL_KMODS
if [ "$platform" = "x86_64" ]; then
    sed -i 's/hwmon, +PACKAGE_kmod-thermal:kmod-thermal/hwmon/g' package/kernel/linux/modules/hwmon.mk
fi

# x86 - disable intel_pstate
sed -i 's/noinitrd/noinitrd intel_pstate=disable/g' target/linux/x86/image/grub-efi.cfg

# default LAN IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# Use nginx instead of uhttpd
if [ "$ENABLE_UHTTPD" != "y" ]; then
    sed -i 's/+uhttpd /+luci-nginx /g' feeds/luci/collections/luci/Makefile
    sed -i 's/+uhttpd-mod-ubus //' feeds/luci/collections/luci/Makefile
    sed -i 's/+uhttpd /+luci-nginx /g' feeds/luci/collections/luci-light/Makefile
    sed -i "s/+luci /+luci-nginx /g" feeds/luci/collections/luci-ssl-openssl/Makefile
    sed -i "s/+luci /+luci-nginx /g" feeds/luci/collections/luci-ssl/Makefile
    if [ "$version" = "snapshots-23.05" ] || [ "$version" = "rc2" ]; then
        sed -i 's/+uhttpd +uhttpd-mod-ubus /+luci-nginx /g' feeds/packages/net/wg-installer/Makefile
        sed -i '/uhttpd-mod-ubus/d' feeds/luci/collections/luci-light/Makefile
        sed -i 's/+luci-nginx \\$/+luci-nginx/' feeds/luci/collections/luci-light/Makefile
    fi
fi

# NIC driver - R8168 & R8125 & R8152 & R8101
git clone https://github.com/sbwml/package_kernel_r8168 package/kernel/r8168
git clone https://github.com/sbwml/package_kernel_r8152 package/kernel/r8152
git clone https://github.com/sbwml/package_kernel_r8101 package/kernel/r8101
git clone https://$gitea/sbwml/package_kernel_r8125 package/kernel/r8125

# netifd - fix auto-negotiate by upstream
mkdir -p package/network/config/netifd/patches
curl -s https://$mirror/openwrt/patch/netifd/100-system-linux-fix-autoneg-for-2.5G-5G-10G.patch > package/network/config/netifd/patches/100-system-linux-fix-autoneg-for-2.5G-5G-10G.patch

# Optimization level -Ofast
if [ "$platform" = "x86_64" ]; then
    curl -s https://$mirror/openwrt/patch/target-modify_for_x86_64.patch | patch -p1
else
    curl -s https://$mirror/openwrt/patch/target-modify_for_rockchip.patch | patch -p1
fi

# IF USE GLIBC
if [ "$USE_GLIBC" = "y" ]; then
    # musl-libc
    git clone https://$gitea/sbwml/package_libs_musl-libc package/libs/musl-libc
    # bump fstools version
    rm -rf package/system/fstools
    cp -a ../master/openwrt/package/system/fstools package/system/fstools
    # glibc-common
    curl -s https://$mirror/openwrt/patch/glibc/glibc-common.patch | patch -p1
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

# Mbedtls AES & GCM Crypto Extensions
if [ ! "$platform" = "x86_64" ]; then
    curl -s https://$mirror/openwrt/patch/mbedtls-23.05/200-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch > package/libs/mbedtls/patches/200-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch
    curl -s https://$mirror/openwrt/patch/mbedtls-23.05/mbedtls.patch | patch -p1
fi

# NTFS3
mkdir -p package/system/fstools/patches
curl -s https://$mirror/openwrt/patch/fstools/ntfs3.patch > package/system/fstools/patches/ntfs3.patch
curl -s https://$mirror/openwrt/patch/util-linux/util-linux_ntfs3.patch > package/utils/util-linux/patches/util-linux_ntfs3.patch

# fstools - enable any device with non-MTD rootfs_data volume
curl -s https://$mirror/openwrt/patch/fstools/block-mount-add-fstools-depends.patch | patch -p1
if [ "$USE_GLIBC" = "y" ]; then
    curl -s https://$mirror/openwrt/patch/fstools/fstools-set-ntfs3-utf8-new.patch > package/system/fstools/patches/ntfs3-utf8.patch
    curl -s https://$mirror/openwrt/patch/fstools/glibc/0001-libblkid-tiny-add-support-for-XFS-superblock.patch > package/system/fstools/patches/0001-libblkid-tiny-add-support-for-XFS-superblock.patch
    curl -s https://$mirror/openwrt/patch/fstools/glibc/0003-block-add-xfsck-support.patch > package/system/fstools/patches/0003-block-add-xfsck-support.patch
else
    curl -s https://$mirror/openwrt/patch/fstools/fstools-set-ntfs3-utf8-new.patch > package/system/fstools/patches/ntfs3-utf8.patch
fi
if [ "$USE_GLIBC" = "y" ]; then
    curl -s https://$mirror/openwrt/patch/fstools/22-fstools-support-extroot-for-non-MTD-rootfs_data-new-version.patch > package/system/fstools/patches/22-fstools-support-extroot-for-non-MTD-rootfs_data.patch
else
    curl -s https://$mirror/openwrt/patch/fstools/22-fstools-support-extroot-for-non-MTD-rootfs_data.patch > package/system/fstools/patches/22-fstools-support-extroot-for-non-MTD-rootfs_data.patch
fi

# QEMU for aarch64
pushd feeds/packages
    curl -s https://$mirror/openwrt/patch/qemu/qemu-aarch64_23.05.patch | patch -p1
popd

# Shortcut Forwarding Engine
git clone https://$gitea/sbwml/shortcut-fe package/shortcut-fe

# Patch FireWall 4
if [ "$version" = "snapshots-23.05" ] || [ "$version" = "rc2" ]; then
    # firewall4
    rm -rf package/network/config/firewall4
    cp -a ../master/openwrt/package/network/config/firewall4 package/network/config/firewall4
    mkdir -p package/network/config/firewall4/patches
    curl -s https://$mirror/openwrt/patch/firewall4/999-01-firewall4-add-fullcone-support.patch > package/network/config/firewall4/patches/999-01-firewall4-add-fullcone-support.patch
    # kernel version
    curl -s https://$mirror/openwrt/patch/firewall4/002-fix-fw4.uc-adept-kernel-version-type-of-x.x.patch > package/network/config/firewall4/patches/002-fix-fw4.uc-adept-kernel-version-type-of-x.x.patch
    # fix flow offload
    curl -s https://$mirror/openwrt/patch/firewall4/001-fix-fw4-flow-offload.patch > package/network/config/firewall4/patches/001-fix-fw4-flow-offload.patch
    # libnftnl
    rm -rf package/libs/libnftnl
    cp -a ../master/openwrt/package/libs/libnftnl package/libs/libnftnl
    mkdir -p package/libs/libnftnl/patches
    curl -s https://$mirror/openwrt/patch/firewall4/libnftnl/001-libnftnl-add-fullcone-expression-support.patch > package/libs/libnftnl/patches/001-libnftnl-add-fullcone-expression-support.patch
    sed -i '/PKG_INSTALL:=1/iPKG_FIXUP:=autoreconf' package/libs/libnftnl/Makefile
    # nftables
    rm -rf package/network/utils/nftables
    cp -a ../master/openwrt/package/network/utils/nftables package/network/utils/nftables
    mkdir -p package/network/utils/nftables/patches
    curl -s https://$mirror/openwrt/patch/firewall4/nftables/002-nftables-add-fullcone-expression-support.patch > package/network/utils/nftables/patches/002-nftables-add-fullcone-expression-support.patch
    # hide nftables warning message
    pushd feeds/luci
        curl -s https://$mirror/openwrt/patch/luci/luci-nftables.patch | patch -p1
    popd
fi

# FullCone module
git clone https://$gitea/sbwml/nft-fullcone package/new/nft-fullcone

# Patch Luci add fullcone & shortcut-fe option
pushd feeds/luci
    curl -s https://$mirror/openwrt/patch/firewall4/luci-app-firewall_add_fullcone.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/firewall4/luci-app-firewall_add_shortcut-fe.patch | patch -p1
popd

# openssl -> quictls
rm -rf package/libs/openssl
git clone https://github.com/sbwml/package_libs_openssl package/libs/openssl
# openssl hwrng
if [ "$platform" = "rk3399" ] || [ "$platform" = "rk3568" ]; then
    sed -i "/-openwrt/iOPENSSL_OPTIONS += enable-ktls '-DDEVRANDOM=\"\\\\\"/dev/hwrng\\\\\"\"\'\n" package/libs/openssl/Makefile
else
    sed -i "/-openwrt/iOPENSSL_OPTIONS += enable-ktls '-DDEVRANDOM=\"\\\\\"/dev/urandom\\\\\"\"\'\n" package/libs/openssl/Makefile
fi
# openssl -Ofast
sed -i "s/-O3/-Ofast/g" package/libs/openssl/Makefile

# nghttp3
git clone https://github.com/sbwml/package_libs_nghttp3 package/libs/nghttp3

# ngtcp2
git clone https://github.com/sbwml/package_libs_ngtcp2 package/libs/ngtcp2

# curl - http3/quic
rm -rf feeds/packages/net/curl
git clone https://github.com/sbwml/feeds_packages_net_curl feeds/packages/net/curl

# curl - SmartDrive user-agent
curl -s https://$mirror/openwrt/patch/user-agent/999-curl-default-useragent.patch > feeds/packages/net/curl/patches/999-curl-default-useragent.patch

# wget - SmartDrive user-agent
curl -s https://$mirror/openwrt/patch/user-agent/999-wget-default-useragent.patch > feeds/packages/net/wget/patches/999-wget-default-useragent.patch

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://$gitea/sbwml/luci-app-dockerman -b openwrt-23.05 feeds/luci/applications/luci-app-dockerman
if [ "$version" = "snapshots-23.05" ] || [ "$version" = "rc2" ]; then
    rm -rf feeds/packages/utils/docker feeds/packages/utils/dockerd feeds/packages/utils/containerd feeds/packages/utils/runc
    cp -a ../master/packages/utils/docker feeds/packages/utils/docker
    cp -a ../master/packages/utils/dockerd feeds/packages/utils/dockerd
    cp -a ../master/packages/utils/containerd feeds/packages/utils/containerd
    cp -a ../master/packages/utils/runc feeds/packages/utils/runc
fi
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
pushd feeds/packages
    curl -s https://$mirror/openwrt/patch/docker/dockerd-fix-bridge-network.patch | patch -p1
popd

# cgroupfs-mount
# fix unmount hierarchical mount
pushd feeds/packages
    curl -s https://$mirror/openwrt/patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch | patch -p1
popd
# mount cgroup v2 hierarchy to /sys/fs/cgroup/cgroup2
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
curl -s https://$mirror/openwrt/patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch > feeds/packages/utils/cgroupfs-mount/patches/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch
curl -s https://$mirror/openwrt/patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch > feeds/packages/utils/cgroupfs-mount/patches/901-fix-cgroupfs-umount.patch
# docker systemd support
curl -s https://$mirror/openwrt/patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch > feeds/packages/utils/cgroupfs-mount/patches/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch

# procps-ng - top
sed -i 's/enable-skill/enable-skill --disable-modern-top/g' feeds/packages/utils/procps-ng/Makefile

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# UPnP
rm -rf feeds/packages/net/miniupnpd
git clone https://$gitea/sbwml/miniupnpd feeds/packages/net/miniupnpd
rm -rf feeds/luci/applications/luci-app-upnp
git clone https://$gitea/sbwml/luci-app-upnp feeds/luci/applications/luci-app-upnp
pushd feeds/packages
    curl -s https://$mirror/openwrt/patch/miniupnpd/01-set-presentation_url.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/miniupnpd/02-force_forwarding.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/miniupnpd/03-Update-301-options-force_forwarding-support.patch.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/miniupnpd/04-enable-force_forwarding-by-default.patch | patch -p1
popd

# UPnP - Move to network
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json

# nginx - latest version
rm -rf feeds/packages/net/nginx
git clone https://github.com/sbwml/feeds_packages_net_nginx feeds/packages/net/nginx -b quic
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g;s/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/net/nginx/files/nginx.init

# nginx - ubus
sed -i 's/ubus_parallel_req 2/ubus_parallel_req 6/g' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 600;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support

# nginx - uwsgi timeout & enable brotli
curl -s https://$mirror/openwrt/nginx/luci.locations > feeds/packages/net/nginx/files-luci-support/luci.locations
curl -s https://$mirror/openwrt/nginx/uci.conf.template > feeds/packages/net/nginx-util/files/uci.conf.template

# uwsgi - bump version
if [ "$version" = "snapshots-23.05" ] || [ "$version" = "rc2" ]; then
    rm -rf feeds/packages/net/uwsgi
    cp -a ../master/packages/net/uwsgi feeds/packages/net/uwsgi
fi

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

# luci - 20_memory & refresh interval
pushd feeds/luci
    curl -s https://$mirror/openwrt/patch/luci/20_memory.js.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/luci/luci-refresh-interval.patch | patch -p1
popd

# Luci diagnostics.js
sed -i "s/openwrt.org/www.qq.com/g" feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/diagnostics.js

# luci - drop ethernet port status
rm -f feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/29_ports.js

# urngd - 2020-01-21
rm -rf package/system/urngd
git clone https://github.com/sbwml/package_system_urngd package/system/urngd

# profile
sed -i 's#\\u@\\h:\\w\\\$#\\[\\e[32;1m\\][\\u@\\h\\[\\e[0m\\] \\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\[\\e[32;1m\\]]\\[\\e[0m\\]\\\$#g' package/base-files/files/etc/profile
sed -ri 's/(export PATH=")[^"]*/\1%PATH%:\/opt\/bin:\/opt\/sbin:\/opt\/usr\/bin:\/opt\/usr\/sbin/' package/base-files/files/etc/profile

# bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
curl -so files/root/.bash_profile https://$mirror/openwrt/files/root/.bash_profile
curl -so files/root/.bashrc https://$mirror/openwrt/files/root/.bashrc

# rootfs files
mkdir -p files/etc/sysctl.d
curl -so files/etc/sysctl.d/15-vm-swappiness.conf https://$mirror/openwrt/files/etc/sysctl.d/15-vm-swappiness.conf
# fix E1187: Failed to source defaults.vim
touch files/root/.vimrc

# NTP
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate
