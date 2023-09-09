#!/bin/bash -e

# golang 1.20
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 20.x feeds/packages/lang/golang

# Default settings
git clone https://github.com/sbwml/default-settings package/new/default-settings

# DDNS
sed -i '/boot()/,+2d' feeds/packages/net/ddns-scripts/files/etc/init.d/ddns

# FRPC
sed -i 's/procd_set_param stdout $stdout/procd_set_param stdout 0/g' feeds/packages/net/frp/files/frpc.init
sed -i 's/procd_set_param stderr $stderr/procd_set_param stderr 0/g' feeds/packages/net/frp/files/frpc.init
sed -i 's/stdout stderr //g' feeds/packages/net/frp/files/frpc.init
sed -i '/stdout:bool/d;/stderr:bool/d' feeds/packages/net/frp/files/frpc.init
sed -i '/stdout/d;/stderr/d' feeds/packages/net/frp/files/frpc.config
sed -i '/Log stdout/d;/Log stderr/d' feeds/luci/applications/luci-app-frpc/htdocs/luci-static/resources/view/frpc.js

# haproxy - bump version
rm -rf feeds/packages/net/haproxy
cp -a ../master/packages/net/haproxy feeds/packages/net/haproxy

# samba4 - bump version
rm -rf feeds/packages/net/samba4
git clone https://github.com/sbwml/feeds_packages_net_samba4 feeds/packages/net/samba4
# enable multi-channel
sed -i '/workgroup/a \\n\t## enable multi-channel' feeds/packages/net/samba4/files/smb.conf.template
sed -i '/enable multi-channel/a \\tserver multi channel support = yes' feeds/packages/net/samba4/files/smb.conf.template
# default config
sed -i 's/invalid users = root/#invalid users = root/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#create mask/create mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#directory mask/directory mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/0666/0644/g;s/0744/0755/g;s/0777/0755/g' feeds/luci/applications/luci-app-samba4/htdocs/luci-static/resources/view/samba4.js
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/samba.config
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/smb.conf.template

# autoCore
git clone https://github.com/sbwml/autocore-arm -b openwrt-23.05 package/new/autocore

# Aria2 & ariaNG
rm -rf feeds/packages/net/ariang
rm -rf feeds/luci/applications/luci-app-aria2
git clone https://github.com/sbwml/ariang-nginx package/ariang-nginx
rm -rf feeds/packages/net/aria2
git clone https://github.com/sbwml/feeds_packages_net_aria2 -b 22.03 feeds/packages/net/aria2

# AirConnect
git clone https://github.com/sbwml/luci-app-airconnect package/airconnect

# SSRP & Passwall
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
git clone https://github.com/sbwml/openwrt_helloworld package/helloworld -b v5

# DAED
git clone https://github.com/sbwml/luci-app-daed package/daed

# immortalwrt packages
# homeproxy
git clone https://github.com/immortalwrt/homeproxy package/homeproxy/homeproxy
sed -i "s/ImmortalWrt/OpenWrt/g" package/homeproxy/homeproxy/po/zh_Hans/homeproxy.po
sed -i "s/ImmortalWrt proxy/OpenWrt proxy/g" package/homeproxy/homeproxy/htdocs/luci-static/resources/view/homeproxy/{client.js,server.js}
# sing-box
#cp -a ../master/immortalwrt_packages/net/sing-box package/homeproxy/sing-box
#sed -i 's#../../lang/golang/golang-package.mk#$(TOPDIR)/feeds/packages/lang/golang/golang-package.mk#g' package/homeproxy/sing-box/Makefile

# alist
git clone https://github.com/sbwml/openwrt-alist package/alist

# Netdata
rm -rf feeds/packages/admin/netdata
cp -a ../master/packages/admin/netdata feeds/packages/admin/netdata
sed -i 's/syslog/none/g' feeds/packages/admin/netdata/files/netdata.conf

# OpenAI
git clone https://github.com/sbwml/luci-app-openai package/openai

# qBittorrent
git clone https://github.com/sbwml/luci-app-qbittorrent package/qbittorrent

# Zerotier
git clone https://$gitea/sbwml/luci-app-zerotier package/new/luci-app-zerotier

# 解除网易云音乐播放限制
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic package/new/luci-app-unblockneteasemusic
sed -i 's/解除网易云音乐播放限制/解锁网易云音乐/g' package/new/luci-app-unblockneteasemusic/root/usr/share/luci/menu.d/luci-app-unblockneteasemusic.json

# xunlei
git clone https://github.com/sbwml/luci-app-xunlei package/xunlei

# Theme
git clone --depth 1 https://github.com/sbwml/luci-theme-argon.git package/new/luci-theme-argon

# Mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

# OpenAppFilter
git clone https://github.com/sbwml/OpenAppFilter --depth=1 package/new/OpenAppFilter

# iperf3
rm -rf feeds/packages/net/iperf3
cp -a ../master/packages/net/iperf3 feeds/packages/net/iperf3
sed -i "s/D_GNU_SOURCE/D_GNU_SOURCE -funroll-loops/g" feeds/packages/net/iperf3/Makefile

# 带宽监控
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js

#### 磁盘分区 / 清理内存 / 打印机 / 定时重启 / 数据监控 / KMS / 访问控制（互联网时间）/ ADG luci / IP 限速 / 文件管理器 / CPU / 迅雷快鸟
rm -rf feeds/packages/utils/coremark
git clone https://github.com/sbwml/openwrt_pkgs package/openwrt_pkgs --depth=1
rm -rf package/openwrt_pkgs/ddns-scripts-dnspod

# 翻译
sed -i 's,发送,Transmission,g' feeds/luci/applications/luci-app-transmission/po/zh_Hans/transmission.po
sed -i 's,frp 服务器,FRP 服务器,g' feeds/luci/applications/luci-app-frps/po/zh_Hans/frps.po
sed -i 's,frp 客户端,FRP 客户端,g' feeds/luci/applications/luci-app-frpc/po/zh_Hans/frpc.po

# SQM Translation
mkdir -p feeds/packages/net/sqm-scripts/patches
curl -s https://$mirror/openwrt/patch/sqm/001-help-translation.patch > feeds/packages/net/sqm-scripts/patches/001-help-translation.patch

# SQM - luci menu order
# sed -i "s/59/150/g" feeds/luci/applications/luci-app-sqm/root/usr/share/luci/menu.d/luci-app-sqm.json

# mjpg-streamer init
sed -i "s,option port '8080',option port '1024',g" feeds/packages/multimedia/mjpg-streamer/files/mjpg-streamer.config
sed -i "s,option fps '5',option fps '25',g" feeds/packages/multimedia/mjpg-streamer/files/mjpg-streamer.config

# luci-app-mjpg-streamer
rm -rf feeds/luci/applications/luci-app-mjpg-streamer
git clone https://github.com/sbwml/luci-app-mjpg-streamer feeds/luci/applications/luci-app-mjpg-streamer

# unzip
rm -rf feeds/packages/utils/unzip
git clone https://$gitea/sbwml/unzip feeds/packages/utils/unzip
