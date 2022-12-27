#!/bin/bash

# golang 19 - openwrt 21/22: Fix build alist
rm -rf feeds/packages/lang/golang
svn export https://github.com/sbwml/packages_lang_golang/trunk feeds/packages/lang/golang

# Default settings
git clone https://github.com/sbwml/default-settings package/new/default-settings
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    sed -i 's,iptables-mod-fullconenat,iptables-nft +kmod-nft-fullcone,g' package/new/default-settings/Makefile
fi

# DDNS
sed -i '/boot()/,+2d' feeds/packages/net/ddns-scripts/files/etc/init.d/ddns
svn co https://github.com/sbwml/openwrt-package/trunk/ddns-scripts-aliyun package/new/ddns-scripts_aliyun
if [ ! "$version" = "rc" ] && [ ! "$version" = "snapshots-22.03" ]; then
    svn co https://github.com/sbwml/openwrt-package/trunk/ddns-scripts-dnspod package/new/ddns-scripts_dnspod
fi

# autoCore
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
	git clone https://github.com/sbwml/autocore-arm -b openwrt-22.03 package/new/autocore
else
	git clone https://github.com/sbwml/autocore-arm -b openwrt-21.02 package/new/autocore
fi

# coremark
rm -rf feeds/packages/utils/coremark
svn co https://github.com/immortalwrt/packages/trunk/utils/coremark feeds/packages/utils/coremark
sed -i "/define Package\/coremark\/config/i define Package/coremark/conffiles\r\n/etc/bench.log\r\nendef\r\n" feeds/packages/utils/coremark/Makefile
sed -i 's#$(TARGET_CFLAGS)) -O3#$(TARGET_CFLAGS)) -Ofast#g' feeds/packages/utils/coremark/Makefile

# Aria2 & ariaNG
rm -rf feeds/packages/net/ariang
rm -rf feeds/luci/applications/luci-app-aria2
git clone https://github.com/sbwml/ariang-nginx package/ariang-nginx
rm -rf feeds/packages/net/aria2
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    svn export https://github.com/immortalwrt/packages/branches/master/net/aria2 feeds/packages/net/aria2
else
    svn export https://github.com/openwrt/packages/branches/openwrt-22.03/net/aria2 feeds/packages/net/aria2
fi

# SSRP & Passwall
rm -rf feeds/packages/net/xray-core
git clone https://github.com/sbwml/openwrt_helloworld package/helloworld -b v5

# alist
git clone https://github.com/sbwml/openwrt-alist package/alist

# Netdata
rm -rf feeds/packages/admin/netdata
svn export https://github.com/openwrt/packages/trunk/admin/netdata feeds/packages/admin/netdata
sed -i 's/syslog/none/g' feeds/packages/admin/netdata/files/netdata.conf

# qBittorrent
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    git clone https://github.com/sbwml/luci-app-qbittorrent package/qbittorrent
else
    git clone https://github.com/sbwml/luci-app-qbittorrent -b 4.4.5 package/qbittorrent
fi

# Theme
git clone --depth 1 https://github.com/sbwml/luci-theme-argon.git package/new/luci-theme-argon

# 易有云
svn export https://github.com/linkease/nas-packages/trunk/network/services/linkease package/network/services/linkease
sed -i "s/option 'enabled' '1'/option 'enabled' '0'/g" package/network/services/linkease/files/linkease.config
sed -i "s/enabled 1/enabled 0/g" package/network/services/linkease/files/linkease.init
sed -i "s/+ffmpeg-remux//g" package/network/services/linkease/Makefile
#svn export https://github.com/linkease/nas-packages/trunk/multimedia/ffmpeg-remux package/new/ffmpeg-remux

# Mosdns
if [ "$version" = "rc" ] || [ "$version" = "snapshots-22.03" ]; then
    rm -rf feeds/packages/net/v2ray-geodata
fi
git clone https://github.com/sbwml/luci-app-mosdns package/mosdns

# OpenAppFilter
git clone https://github.com/sbwml/OpenAppFilter --depth=1 package/new/OpenAppFilter

# 带宽监控
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js

#### 磁盘分区 / 清理内存 / 打印机 / 定时重启 / 数据监控 / KMS / 访问控制（互联网时间）/ ADG luci / IP 限速 / 文件管理器 / CPU / 迅雷快鸟
git clone https://github.com/sbwml/openwrt_pkgs package/openwrt_pkgs --depth=1

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
