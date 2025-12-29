#!/bin/bash -e

# golang 1.26
rm -rf feeds/packages/lang/golang
git clone https://$github/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang

# node - prebuilt
rm -rf feeds/packages/lang/node
git clone https://$github/sbwml/feeds_packages_lang_node-prebuilt feeds/packages/lang/node -b packages-24.10

# default settings
git clone https://$github/sbwml/default-settings package/new/default-settings -b openwrt-25.12

# wwan
git clone https://$github/sbwml/wwan-packages package/new/wwan --depth=1

# bandix
git clone https://$github/timsaya/openwrt-bandix package/new/bandix --depth=1
git clone https://$github/timsaya/luci-app-bandix package/new/luci-app-bandix --depth=1

# istore
git clone https://$github/sbwml/package_new_istore package/new/istore --depth=1

# luci-app-filemanager
rm -rf feeds/luci/applications/luci-app-filemanager
git clone https://$github/sbwml/luci-app-filemanager package/new/luci-app-filemanager

# luci-app-quickfile
git clone https://$github/sbwml/luci-app-quickfile package/new/quickfile

# luci-app-airplay2
git clone https://$github/sbwml/luci-app-airplay2 package/new/airplay2

# luci-app-webdav
git clone https://$github/sbwml/luci-app-webdav package/new/luci-app-webdav

# ddns - fix boot
sed -i '/boot()/,+2d' feeds/packages/net/ddns-scripts/files/etc/init.d/ddns

# nlbwmon - disable syslog
sed -i 's/stderr 1/stderr 0/g' feeds/packages/net/nlbwmon/files/nlbwmon.init

# pcre - 8.45
mkdir -p package/libs/pcre
curl -s $mirror/openwrt/patch/pcre/Makefile > package/libs/pcre/Makefile
curl -s $mirror/openwrt/patch/pcre/Config.in > package/libs/pcre/Config.in

# lrzsz - 0.12.20
rm -rf feeds/packages/utils/lrzsz
git clone https://$github/sbwml/packages_utils_lrzsz package/new/lrzsz

# frpc
sed -i 's/procd_set_param stdout $stdout/procd_set_param stdout 0/g' feeds/packages/net/frp/files/frpc.init
sed -i 's/procd_set_param stderr $stderr/procd_set_param stderr 0/g' feeds/packages/net/frp/files/frpc.init
sed -i 's/stdout stderr //g' feeds/packages/net/frp/files/frpc.init
sed -i '/stdout:bool/d;/stderr:bool/d' feeds/packages/net/frp/files/frpc.init
sed -i '/stdout/d;/stderr/d' feeds/packages/net/frp/files/frpc.config
sed -i 's/env conf_inc/env conf_inc enable/g' feeds/packages/net/frp/files/frpc.init
sed -i "s/'conf_inc:list(string)'/& \\\\/" feeds/packages/net/frp/files/frpc.init
sed -i "/conf_inc:list/a\\\t\t\'enable:bool:0\'" feeds/packages/net/frp/files/frpc.init
sed -i '/procd_open_instance/i\\t\[ "$enable" -ne 1 \] \&\& return 1\n' feeds/packages/net/frp/files/frpc.init
curl -s $mirror/openwrt/patch/luci/applications/luci-app-frpc/001-luci-app-frpc-hide-token.patch | patch -p1
curl -s $mirror/openwrt/patch/luci/applications/luci-app-frpc/002-luci-app-frpc-add-enable-flag.patch | patch -p1

# natmap
sed -i 's/log_stdout:bool:1/log_stdout:bool:0/g;s/log_stderr:bool:1/log_stderr:bool:0/g' feeds/packages/net/natmap/files/natmap.init
pushd feeds/luci
    curl -s $mirror/openwrt/patch/luci/applications/luci-app-natmap/0001-luci-app-natmap-add-default-STUN-server-lists.patch | patch -p1
popd

# samba4 - bump version
rm -rf feeds/packages/net/samba4
git clone https://$github/sbwml/feeds_packages_net_samba4 feeds/packages/net/samba4
# enable multi-channel
sed -i '/workgroup/a \\n\t## enable multi-channel' feeds/packages/net/samba4/files/smb.conf.template
sed -i '/enable multi-channel/a \\tserver multi channel support = yes' feeds/packages/net/samba4/files/smb.conf.template
# default config
sed -i 's/#aio read size = 0/aio read size = 0/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#aio write size = 0/aio write size = 0/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/invalid users = root/#invalid users = root/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#create mask/create mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#directory mask/directory mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/0666/0644/g;s/0744/0755/g;s/0777/0755/g' feeds/luci/applications/luci-app-samba4/htdocs/luci-static/resources/view/samba4.js
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/samba.config
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/smb.conf.template
# rk3568 bind cpus
[ "$platform" = "rk3568" ] && sed -i 's#/usr/sbin/smbd -F#/usr/bin/taskset -c 1,0 /usr/sbin/smbd -F#' feeds/packages/net/samba4/files/samba.init

# zerotier
rm -rf feeds/packages/net/zerotier
git clone https://$github/sbwml/feeds_packages_net_zerotier feeds/packages/net/zerotier

# aria2 & ariaNG
rm -rf feeds/packages/net/ariang
rm -rf feeds/luci/applications/luci-app-aria2
git clone https://$github/sbwml/ariang-nginx package/new/ariang-nginx
rm -rf feeds/packages/net/aria2
git clone https://$github/sbwml/feeds_packages_net_aria2 -b 22.03 feeds/packages/net/aria2

# airconnect
git clone https://$github/sbwml/luci-app-airconnect package/new/airconnect --depth=1

# netkit-ftp
git clone https://$github/sbwml/package_new_ftp package/new/ftp

# nethogs
git clone https://$github/sbwml/package_new_nethogs package/new/nethogs

# SSRP & Passwall
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
git clone https://$github/sbwml/openwrt_helloworld package/new/helloworld -b v5

# openlist
git clone https://$github/sbwml/luci-app-openlist2 package/new/openlist --depth=1

# netdata
sed -i 's/syslog/none/g' feeds/packages/admin/netdata/files/netdata.conf

# qBittorrent
git clone https://$github/sbwml/luci-app-qbittorrent package/new/qbittorrent --depth=1

# unblockneteasemusic
git clone https://$github/UnblockNeteaseMusic/luci-app-unblockneteasemusic package/new/luci-app-unblockneteasemusic --depth=1
sed -i 's/解除网易云音乐播放限制/网易云音乐解锁/g' package/new/luci-app-unblockneteasemusic/root/usr/share/luci/menu.d/luci-app-unblockneteasemusic.json

# Theme
git clone https://$github/sbwml/luci-theme-argon -b openwrt-25.12 package/new/luci-theme-argon --depth=1

# Mosdns
git clone https://$github/sbwml/luci-app-mosdns -b v5 package/new/mosdns --depth=1

# OpenAppFilter
git clone https://$github/sbwml/OpenAppFilter --depth=1 package/new/OpenAppFilter -b v6

# iperf3
sed -i "s/D_GNU_SOURCE/D_GNU_SOURCE -funroll-loops/g" feeds/packages/net/iperf3/Makefile

# nlbwmon
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js

# mentohust
git clone https://$github/sbwml/luci-app-mentohust package/new/mentohust

# custom packages
rm -rf feeds/packages/utils/coremark
git clone https://$github/sbwml/openwrt_pkgs package/new/custom --depth=1
rm -rf package/new/custom/ddns-scripts-aliyun
# coremark - prebuilt with gcc15
if [ "$platform" = "rk3568" ]; then
    curl -s $mirror/openwrt/patch/coremark/coremark.aarch64-4-threads > package/new/custom/coremark/src/musl/coremark.aarch64
elif [ "$platform" = "rk3576" ]; then
    curl -s $mirror/openwrt/patch/coremark/coremark.aarch64-16-threads > package/new/custom/coremark/src/musl/coremark.aarch64
elif [ "$platform" = "rk3399" ]; then
    curl -s $mirror/openwrt/patch/coremark/coremark.aarch64-6-threads > package/new/custom/coremark/src/musl/coremark.aarch64
elif [ "$platform" = "armv8" ]; then
    curl -s $mirror/openwrt/patch/coremark/coremark.aarch64-16-threads > package/new/custom/coremark/src/musl/coremark.aarch64
fi

# luci-compat - fix translation
sed -i 's/<%:Up%>/<%:Move up%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm

# frpc translation
sed -i 's,发送,Transmission,g' feeds/luci/applications/luci-app-transmission/po/zh_Hans/transmission.po
sed -i 's,frp 服务器,Frp 服务器,g' feeds/luci/applications/luci-app-frps/po/zh_Hans/frps.po
sed -i 's,frp 客户端,Frp 客户端,g' feeds/luci/applications/luci-app-frpc/po/zh_Hans/frpc.po

# luci-app-sqm
rm -rf feeds/luci/applications/luci-app-sqm
git clone https://$gitea/sbwml/luci-app-sqm feeds/luci/applications/luci-app-sqm

# unzip
rm -rf feeds/packages/utils/unzip
git clone https://$github/sbwml/feeds_packages_utils_unzip feeds/packages/utils/unzip

# tcp-brutal
git clone https://$github/sbwml/package_kernel_tcp-brutal package/kernel/tcp-brutal

# watchcat - clean config
true > feeds/packages/utils/watchcat/files/watchcat.config

# libpcap
rm -rf package/libs/libpcap
git clone https://$github/sbwml/package_libs_libpcap package/libs/libpcap

# sqm-scripts
curl -s $mirror/openwrt/patch/sqm-scripts/Makefile > feeds/packages/net/sqm-scripts/Makefile
