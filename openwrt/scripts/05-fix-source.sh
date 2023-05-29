#!/bin/bash

# Chinese translation
# luci-app-firewall
curl -s https://raw.githubusercontent.com/openwrt/luci/master/applications/luci-app-firewall/po/zh_Hans/firewall.po > feeds/luci/applications/luci-app-firewall/po/zh_Hans/firewall.po


# openwrt-23.05
[ "$version" = "snapshots-23.05" ] && echo "# CONFIG_X86_PLATFORM_DRIVERS_HP is not set" >> target/linux/generic/config-5.15
