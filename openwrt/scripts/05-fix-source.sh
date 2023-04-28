#!/bin/bash

# openwrt-22.03.4
# WARNING: Makefile 'package/feeds/luci/luci-app-apinger/Makefile' has a dependency on 'apinger-rrd', which does not exist
rm -rf feeds/packages/net/apinger
cp -a ../master/packages/net/apinger feeds/packages/net/apinger

# Chinese translation
# luci-app-firewall
curl -s https://raw.githubusercontent.com/openwrt/luci/master/applications/luci-app-firewall/po/zh_Hans/firewall.po > feeds/luci/applications/luci-app-firewall/po/zh_Hans/firewall.po

