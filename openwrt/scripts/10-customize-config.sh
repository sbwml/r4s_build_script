rm -rf package/new/helloworld/luci-app-ssr-plus
rm -rf package/new/helloworld/patch-luci-app-ssr-plus.patch

# from pmkol/openwrt-plus
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' package/new/luci-theme-argon/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' package/new/luci-theme-argon/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' feeds/luci/themes/luci-theme-bootstrap/ucode/template/themes/bootstrap/footer.ut
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' feeds/luci/themes/luci-theme-material/ucode/template/themes/material/footer.ut
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' feeds/luci/themes/luci-theme-openwrt-2020/ucode/template/themes/openwrt2020/footer.ut
sed -i '/# timezone/i sed -i "s/\\(DISTRIB_DESCRIPTION=\\).*/\\1'\''OpenWrt-Plus $(sed -n "s/DISTRIB_DESCRIPTION='\''OpenWrt \\([^ ]*\\) .*/\\1/p" /etc/openwrt_release)'\'',/" /etc/openwrt_release\nsource /etc/openwrt_release \&\& sed -i -e "s/distversion\\s=\\s\\".*\\"/distversion = \\"$DISTRIB_ID $DISTRIB_RELEASE ($DISTRIB_REVISION)\\"/g" -e '\''s/distname    = .*$/distname    = ""/g'\'' /usr/lib/lua/luci/version.lua\nsed -i "s/luciname    = \\".*\\"/luciname    = \\"Linux Kernel-Enhanced\\"/g" /usr/lib/lua/luci/version.lua\nsed -i "s/luciversion = \\".*\\"/luciversion = \\"v$(date +%Y%m%d)\\"/g" /usr/lib/lua/luci/version.lua\necho "export const revision = '\''v$(date +%Y%m%d)'\'', branch = '\''Linux Kernel-Enhanced'\'';" > /usr/share/ucode/luci/version.uc\ngrep -q '\''/tmp/sysinfo/model'\'' /etc/rc.local || sudo sed -i '\''/exit 0/i [ "$(cat /sys\\/class\\/dmi\\/id\\/sys_vendor 2>\\/dev\\/null)" = "Default string" ] \&\& echo "Industrial Router" > \\/tmp\\/sysinfo\\/model'\'' /etc/rc.local\n' package/new/default-settings/default/zzz-default-settings
sed -i '/# opkg mirror/a echo -e '\''src/gz immortalwrt_luci https://mirrors.pku.edu.cn/immortalwrt/releases/packages-23.05/x86_64/luci\\nsrc/gz immortalwrt_packages https://mirrors.pku.edu.cn/immortalwrt/releases/packages-23.05/x86_64/packages'\'' >> /etc/opkg/distfeeds.conf' package/new/default-settings/default/zzz-default-settings
sed -i '/# opkg mirror/a echo -e '\''untrusted comment: Public usign key for 23.05 release builds\\nRWRoKXAGS4epF5gGGh7tVQxiJIuZWQ0geStqgCkwRyviQCWXpufBggaP'\'' > /etc/opkg/keys/682970064b87a917' package/new/default-settings/default/zzz-default-settings
sed -i 's#raw.cooluc.com/sbwml/kmod-x86_64/main#raw.gitmirror.com/sbwml/kmod-x86_64/main#g' package/new/default-settings/default/zzz-default-settings

# make openclash more prepared
wget -q -O- https://raw.githubusercontent.com/NobyDa/geoip/release/Private-GeoIP-CN.mmdb > package/feeds/luci/luci-app-openclash/root/etc/openclash/Country.mmdb
wget -q -O- https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/release/geosite.dat > package/feeds/luci/luci-app-openclash/root/etc/openclash/GeoSite.dat
wget -q -P package/feeds/luci/luci-app-openclash/root/etc/openclash/core https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-amd64.tar.gz 
tar -xvf package/feeds/luci/luci-app-openclash/root/etc/openclash/core/clash-linux-amd64.tar.gz -C package/feeds/luci/luci-app-openclash/root/etc/openclash/core
rm -f package/feeds/luci/luci-app-openclash/root/etc/openclash/core/clash-linux-amd64.tar.gz
mv package/feeds/luci/luci-app-openclash/root/etc/openclash/core/clash package/feeds/luci/luci-app-openclash/root/etc/openclash/core/clash_meta
chmod +x package/feeds/luci/luci-app-openclash/root/etc/openclash/core/clash_meta
