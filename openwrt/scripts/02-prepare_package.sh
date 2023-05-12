#!/bin/bash -e

# golang 1.20
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 20.x feeds/packages/lang/golang

# Default settings
git clone https://github.com/sbwml/default-settings package/new/default-settings

# DDNS
sed -i '/boot()/,+2d' feeds/packages/net/ddns-scripts/files/etc/init.d/ddns

# FRP
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    rm -rf feeds/packages/net/frp
    git clone https://github.com/sbwml/feeds_packages_net_frp feeds/packages/net/frp
fi

# autoCore
git clone https://github.com/sbwml/autocore-arm -b openwrt-22.03 package/new/autocore

# Aria2 & ariaNG
rm -rf feeds/packages/net/ariang
rm -rf feeds/luci/applications/luci-app-aria2
git clone https://github.com/sbwml/ariang-nginx package/ariang-nginx
rm -rf feeds/packages/net/aria2
git clone https://github.com/sbwml/feeds_packages_net_aria2 -b 22.03 feeds/packages/net/aria2

# SSRP & Passwall
rm -rf feeds/packages/net/{xray-core,v2ray-core}
git clone https://github.com/sbwml/openwrt_helloworld package/helloworld -b v5

# alist
git clone https://github.com/sbwml/openwrt-alist package/alist

# Netdata
rm -rf feeds/packages/admin/netdata
cp -a ../master/packages/admin/netdata feeds/packages/admin/netdata
sed -i 's/syslog/none/g' feeds/packages/admin/netdata/files/netdata.conf

# qBittorrent
git clone https://github.com/sbwml/luci-app-qbittorrent package/qbittorrent

# Zerotier
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    git clone https://$gitea/sbwml/luci-app-zerotier package/new/luci-app-zerotier
fi

# xunlei
git clone https://github.com/sbwml/luci-app-xunlei package/xunlei

# Theme
git clone --depth 1 https://github.com/sbwml/luci-theme-argon.git package/new/luci-theme-argon

# Mosdns
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    rm -rf feeds/packages/net/v2ray-geodata
fi
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

# OpenAppFilter
git clone https://github.com/sbwml/OpenAppFilter --depth=1 package/new/OpenAppFilter

# iperf3 - 3.13
sed -ri "s/(PKG_VERSION:=)[^\"]*/\13.13/;s/(PKG_HASH:=)[^\"]*/\1bee427aeb13d6a2ee22073f23261f63712d82befaa83ac8cb4db5da4c2bdc865/" feeds/packages/net/iperf3/Makefile

# 带宽监控
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js

#### 磁盘分区 / 清理内存 / 打印机 / 定时重启 / 数据监控 / KMS / 访问控制（互联网时间）/ ADG luci / IP 限速 / 文件管理器 / CPU / 迅雷快鸟
rm -rf feeds/packages/utils/coremark
git clone https://github.com/sbwml/openwrt_pkgs package/openwrt_pkgs --depth=1
[ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ] && rm -rf package/openwrt_pkgs/ddns-scripts-dnspod

# 翻译
sed -i 's,发送,Transmission,g' feeds/luci/applications/luci-app-transmission/po/zh_Hans/transmission.po
sed -i 's,frp 服务器,FRP 服务器,g' feeds/luci/applications/luci-app-frps/po/zh_Hans/frps.po
sed -i 's,frp 客户端,FRP 客户端,g' feeds/luci/applications/luci-app-frpc/po/zh_Hans/frpc.po

# mjpg-streamer init
sed -i "s,option port '8080',option port '1024',g" feeds/packages/multimedia/mjpg-streamer/files/mjpg-streamer.config
sed -i "s,option fps '5',option fps '25',g" feeds/packages/multimedia/mjpg-streamer/files/mjpg-streamer.config

# luci-app-mjpg-streamer
rm -rf feeds/luci/applications/luci-app-mjpg-streamer
git clone https://github.com/sbwml/luci-app-mjpg-streamer feeds/luci/applications/luci-app-mjpg-streamer
