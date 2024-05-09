#!/bin/bash -e
export RED_COLOR='\e[1;31m'
export GREEN_COLOR='\e[1;32m'
export YELLOW_COLOR='\e[1;33m'
export BLUE_COLOR='\e[1;34m'
export PINK_COLOR='\e[1;35m'
export SHAN='\e[1;33;5m'
export RES='\e[0m'

GROUP=
group() {
    endgroup
    echo "::group::  $1"
    GROUP=1
}
endgroup() {
    if [ -n "$GROUP" ]; then
        echo "::endgroup::"
    fi
    GROUP=
}

#####################################
#  NanoPi R4S OpenWrt Build Script  #
#####################################

# IP Location
ip_info=`curl -s https://ip.cooluc.com`;
export isCN=`echo $ip_info | grep -Po 'country_code\":"\K[^"]+'`;

# script url
if [ "$isCN" = "CN" ]; then
    export mirror=init.cooluc.com
else
    export mirror=init2.cooluc.com
fi

# github actions - automatically retrieve `github raw` links
if [ "$(whoami)" = "runner" ] && [ -n "$GITHUB_REPO" ]; then
    export mirror=raw.githubusercontent.com/$GITHUB_REPO/master
fi

# private gitea
export gitea=git.cooluc.com

# github mirror
if [ "$isCN" = "CN" ]; then
    export github="github.com"
else
    export github="github.com"
fi

# Check root
if [ "$(id -u)" = "0" ]; then
    echo -e "${RED_COLOR}Building with root user is not supported.${RES}"
    exit 1
fi

# Start time
starttime=`date +'%Y-%m-%d %H:%M:%S'`
CURRENT_DATE=$(date +%s)

# Cpus
cores=`expr $(nproc --all) + 1`

# $CURL_BAR
if curl --help | grep progress-bar >/dev/null 2>&1; then
    CURL_BAR="--progress-bar";
fi

if [ -z "$1" ] || [ "$2" != "nanopi-r4s" -a "$2" != "nanopi-r5s" -a "$2" != "x86_64"  -a "$2" != "netgear_r8500" ]; then
    echo -e "\n${RED_COLOR}Building type not specified.${RES}\n"
    echo -e "Usage:\n"
    echo -e "nanopi-r4s releases: ${GREEN_COLOR}bash build.sh rc2 nanopi-r4s${RES}"
    echo -e "nanopi-r4s snapshots: ${GREEN_COLOR}bash build.sh dev nanopi-r4s${RES}"
    echo -e "nanopi-r5s releases: ${GREEN_COLOR}bash build.sh rc2 nanopi-r5s${RES}"
    echo -e "nanopi-r5s snapshots: ${GREEN_COLOR}bash build.sh dev nanopi-r5s${RES}"
    echo -e "x86_64 releases: ${GREEN_COLOR}bash build.sh rc2 x86_64${RES}"
    echo -e "x86_64 snapshots: ${GREEN_COLOR}bash build.sh dev x86_64${RES}"
    echo -e "netgear r8500 releases: ${GREEN_COLOR}bash build.sh rc2 netgear_r8500${RES}"
    echo -e "netgear r8500 snapshots: ${GREEN_COLOR}bash build.sh dev netgear_r8500${RES}\n"
    exit 1
fi

# Source branch
if [ "$1" = "dev" ]; then
    export branch=openwrt-23.05
    export version=snapshots-23.05
    export toolchain_version=openwrt-23.05
elif [ "$1" = "rc2" ]; then
    latest_release="v$(curl -s https://$mirror/tags/v23)"
    export branch=$latest_release
    export version=rc2
    export toolchain_version=openwrt-23.05
fi

# lan
[ -n "$LAN" ] && export LAN=$LAN

# platform
[ "$2" = "nanopi-r4s" ] && export platform="rk3399" toolchain_arch="nanopi-r4s"
[ "$2" = "nanopi-r5s" ] && export platform="rk3568" toolchain_arch="nanopi-r5s"
[ "$2" = "x86_64" ] && export platform="x86_64" toolchain_arch="x86_64"
[ "$2" = "netgear_r8500" ] && export platform="bcm53xx" toolchain_arch="bcm53xx"

# gcc13 & 14 & 15
if [ "$USE_GCC13" = y ]; then
    export USE_GCC13=y
    # use mold
    [ "$USE_MOLD" = y ] && USE_MOLD=y
elif [ "$USE_GCC14" = y ]; then
    export USE_GCC14=y
    # use mold
    [ "$USE_MOLD" = y ] && USE_MOLD=y
elif [ "$USE_GCC15" = y ]; then
    export USE_GCC15=y
    # use mold
    [ "$USE_MOLD" = y ] && USE_MOLD=y
fi

# use glibc
export USE_GLIBC=$USE_GLIBC

# lrng
export ENABLE_LRNG=$ENABLE_LRNG

# kernel build with clang lto
[ "$platform" != "bcm53xx" ] && export KERNEL_CLANG_LTO=$KERNEL_CLANG_LTO || export KERNEL_CLANG_LTO=n

# print version
echo -e "\r\n${GREEN_COLOR}Building $branch${RES}\r\n"
if [ "$platform" = "x86_64" ]; then
    echo -e "${GREEN_COLOR}Model: x86_64${RES}"
elif [ "$platform" = "bcm53xx" ]; then
    echo -e "${GREEN_COLOR}Model: netgear_r8500${RES}"
    [ -z "$LAN" ] && export LAN="192.168.1.1"
elif [ "$platform" = "rk3568" ]; then
    echo -e "${GREEN_COLOR}Model: nanopi-r5s${RES}"
    [ "$1" = "rc2" ] && model="nanopi-r5s"
else
    echo -e "${GREEN_COLOR}Model: nanopi-r4s${RES}"
    [ "$1" = "rc2" ] && model="nanopi-r4s"
fi
curl -s https://$mirror/tags/kernel-6.6 > kernel.txt
kmod_hash=$(grep HASH kernel.txt | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}')
kmodpkg_name=$(echo $(grep HASH kernel.txt | awk -F'HASH-' '{print $2}' | awk '{print $1}')-1-$(echo $kmod_hash))
echo -e "${GREEN_COLOR}Kernel: $kmodpkg_name ${RES}"
rm -f kernel.txt

echo -e "${GREEN_COLOR}Date: $CURRENT_DATE${RES}\r\n"

if [ "$USE_GCC13" = "y" ]; then
    echo -e "${GREEN_COLOR}GCC VERSION: 13${RES}"
elif [ "$USE_GCC14" = "y" ]; then
    echo -e "${GREEN_COLOR}GCC VERSION: 14${RES}"
elif [ "$USE_GCC15" = "y" ]; then
    echo -e "${GREEN_COLOR}GCC VERSION: 15${RES}"
else
    echo -e "${GREEN_COLOR}GCC VERSION: 11${RES}"
fi
[ "$KERNEL_CLANG_LTO" = "y" ] && echo -e "${GREEN_COLOR}KERNEL_CLANG_LTO: true${RES}" || echo -e "${GREEN_COLOR}KERNEL_CLANG_LTO: false${RES}"
[ "$USE_MOLD" = "y" ] && echo -e "${GREEN_COLOR}USE_MOLD: true${RES}" || echo -e "${GREEN_COLOR}USE_MOLD: false${RES}"
[ "$ENABLE_OTA" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_OTA: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_OTA: false${RES}"
[ "$ENABLE_BPF" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_BPF: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_BPF: false${RES}"
[ "$ENABLE_LTO" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_LTO: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_LTO: false${RES}"
[ "$ENABLE_LRNG" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_LRNG: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_LRNG: false${RES}"
[ "$BUILD_FAST" = "y" ] && echo -e "${GREEN_COLOR}BUILD_FAST: true${RES}" || echo -e "${GREEN_COLOR}BUILD_FAST: false${RES}"
[ "$MINIMAL_BUILD" = "y" ] && echo -e "${GREEN_COLOR}MINIMAL_BUILD: true${RES}" || echo -e "${GREEN_COLOR}MINIMAL_BUILD: false${RES}"
[ -n "$LAN" ] && echo -e "${GREEN_COLOR}LAN IP: $LAN${RES}\r\n" || echo -e "${GREEN_COLOR}LAN IP: 10.0.0.1${RES}\r\n"

# clean old files
rm -rf openwrt master && mkdir master

# openwrt - releases
[ "$(whoami)" = "runner" ] && group "source code"
git clone --depth=1 https://$github/openwrt/openwrt -b $branch

# openwrt master
git clone https://$github/openwrt/openwrt master/openwrt --depth=1
git clone https://$github/openwrt/packages master/packages --depth=1
git clone https://$github/openwrt/luci master/luci --depth=1
git clone https://$github/openwrt/routing master/routing --depth=1

# openwrt-23.05
[ "$1" = "rc2" ] && git clone https://$github/openwrt/openwrt -b openwrt-23.05 master/openwrt-23.05 --depth=1

# immortalwrt master
git clone https://$github/immortalwrt/packages master/immortalwrt_packages --depth=1
[ "$(whoami)" = "runner" ] && endgroup

if [ -d openwrt ]; then
    cd openwrt
    [ "$1" = "rc2" ] && echo "$CURRENT_DATE" > version.date
    curl -Os https://$mirror/openwrt/patch/key.tar.gz && tar zxf key.tar.gz && rm -f key.tar.gz
else
    echo -e "${RED_COLOR}Failed to download source code${RES}"
    exit 1
fi

# tags
if [ "$1" = "rc2" ]; then
    git describe --abbrev=0 --tags > version.txt
else
    git branch | awk '{print $2}' > version.txt
fi

# feeds mirror
if [ "$1" = "rc2" ]; then
    packages="^$(grep packages feeds.conf.default | awk -F^ '{print $2}')"
    luci="^$(grep luci feeds.conf.default | awk -F^ '{print $2}')"
    routing="^$(grep routing feeds.conf.default | awk -F^ '{print $2}')"
    telephony="^$(grep telephony feeds.conf.default | awk -F^ '{print $2}')"
else
    packages=";$branch"
    luci=";$branch"
    routing=";$branch"
    telephony=";$branch"
fi
cat > feeds.conf <<EOF
src-git packages https://$github/openwrt/packages.git$packages
src-git luci https://$github/openwrt/luci.git$luci
src-git routing https://$github/openwrt/routing.git$routing
src-git telephony https://$github/openwrt/telephony.git$telephony
EOF

# Init feeds
[ "$(whoami)" = "runner" ] && group "feeds update -a"
./scripts/feeds update -a
[ "$(whoami)" = "runner" ] && endgroup

[ "$(whoami)" = "runner" ] && group "feeds install -a"
./scripts/feeds install -a
[ "$(whoami)" = "runner" ] && endgroup

# loader dl
if [ -f ../dl.gz ]; then
    tar xf ../dl.gz -C .
fi

###############################################
echo -e "\n${GREEN_COLOR}Patching ...${RES}\n"

# scripts
curl -sO https://$mirror/openwrt/scripts/00-prepare_base.sh
curl -sO https://$mirror/openwrt/scripts/01-prepare_base-mainline.sh
curl -sO https://$mirror/openwrt/scripts/02-prepare_package.sh
curl -sO https://$mirror/openwrt/scripts/03-convert_translation.sh
curl -sO https://$mirror/openwrt/scripts/04-fix_kmod.sh
curl -sO https://$mirror/openwrt/scripts/05-fix-source.sh
curl -sO https://$mirror/openwrt/scripts/10-customize-config.sh
curl -sO https://$mirror/openwrt/scripts/99_clean_build_cache.sh
chmod 0755 *sh
[ "$(whoami)" = "runner" ] && group "patching openwrt"
bash 00-prepare_base.sh
bash 02-prepare_package.sh
bash 03-convert_translation.sh
bash 05-fix-source.sh
bash 10-customize-config.sh
if [ "$platform" = "rk3568" ] || [ "$platform" = "rk3399" ] || [ "$platform" = "x86_64" ] || [ "$platform" = "bcm53xx" ]; then
    bash 01-prepare_base-mainline.sh
    bash 04-fix_kmod.sh
fi
[ "$(whoami)" = "runner" ] && endgroup

if [ "$USE_GCC14" = "y" ] || [ "$USE_GCC15" = "y" ]; then
    rm -rf toolchain/binutils
    cp -a ../master/openwrt/toolchain/binutils toolchain/binutils
fi

rm -f 0*-*.sh
rm -rf ../master

# Load devices Config
if [ "$platform" = "x86_64" ]; then
    curl -s https://$mirror/openwrt/23-config-musl-x86 > .config
    ALL_KMODS=y
elif [ "$platform" = "bcm53xx" ]; then
    if [ "$MINIMAL_BUILD" = "y" ]; then
        curl -s https://$mirror/openwrt/23-config-musl-r8500-minimal > .config
    else
        curl -s https://$mirror/openwrt/23-config-musl-r8500 > .config
    fi
    ALL_KMODS=y
elif [ "$platform" = "rk3568" ]; then
    curl -s https://$mirror/openwrt/23-config-musl-r5s > .config
    ALL_KMODS=y
else
    curl -s https://$mirror/openwrt/23-config-musl-r4s > .config
fi

# config-common
if [ "$MINIMAL_BUILD" = "y" ]; then
    [ "$platform" != "bcm53xx" ] && curl -s https://$mirror/openwrt/23-config-minimal-common >> .config
    echo 'VERSION_TYPE="minimal"' >> package/base-files/files/usr/lib/os-release
else
    [ "$platform" != "bcm53xx" ] && curl -s https://$mirror/openwrt/23-config-common >> .config
fi

# ota
[ "$ENABLE_OTA" = "y" ] && [ "$version" = "rc2" ] && echo 'CONFIG_PACKAGE_luci-app-ota=y' >> .config

# bpf
export ENABLE_BPF=$ENABLE_BPF
[ "$ENABLE_BPF" = "y" ] && curl -s https://$mirror/openwrt/generic/config-bpf >> .config

# LTO
export ENABLE_LTO=$ENABLE_LTO
[ "$ENABLE_LTO" = "y" ] && curl -s https://$mirror/openwrt/generic/config-lto >> .config

# glibc
[ "$USE_GLIBC" = "y" ] && {
    curl -s https://$mirror/openwrt/generic/config-glibc >> .config
    sed -i '/NaiveProxy/d' .config
}

# mold
[ "$USE_MOLD" = "y" ] && echo 'CONFIG_USE_MOLD=y' >> .config

# clang
if [ "$KERNEL_CLANG_LTO" = "y" ]; then
    curl -s https://$mirror/openwrt/generic/config-clang >> .config
fi

# openwrt-23.05 gcc11/13/14/15
[ "$(whoami)" = "runner" ] && group "patching toolchain"
if [ "$USE_GCC13" = "y" ] || [ "$USE_GCC14" = "y" ] || [ "$USE_GCC15" = "y" ]; then
    [ "$USE_GCC13" = "y" ] && curl -s https://$mirror/openwrt/generic/config-gcc13 >> .config
    [ "$USE_GCC14" = "y" ] && curl -s https://$mirror/openwrt/generic/config-gcc14 >> .config
    [ "$USE_GCC15" = "y" ] && curl -s https://$mirror/openwrt/generic/config-gcc15 >> .config
    curl -s https://$mirror/openwrt/patch/generic/200-toolchain-gcc-update-to-13.2.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/generic/201-toolchain-gcc-add-support-for-GCC-14.patch | patch -p1
    curl -s https://$mirror/openwrt/patch/generic/202-toolchain-gcc-add-support-for-GCC-15.patch | patch -p1
    # gcc14/15 init
    cp -a toolchain/gcc/patches-13.x toolchain/gcc/patches-14.x
    curl -s https://$mirror/openwrt/patch/generic/gcc-14/910-mbsd_multi.patch > toolchain/gcc/patches-14.x/910-mbsd_multi.patch
    cp -a toolchain/gcc/patches-14.x toolchain/gcc/patches-15.x
    curl -s https://$mirror/openwrt/patch/generic/gcc-15/970-macos_arm64-building-fix.patch > toolchain/gcc/patches-15.x/970-macos_arm64-building-fix.patch
elif [ ! "$USE_GLIBC" = "y" ]; then
    curl -s https://$mirror/openwrt/generic/config-gcc11 >> .config
fi
[ "$(whoami)" = "runner" ] && endgroup

# clean directory - github actions
[ "$(whoami)" = "runner" ] && echo 'CONFIG_AUTOREMOVE=y' >> .config

# uhttpd
[ "$ENABLE_UHTTPD" = "y" ] && sed -i '/nginx/d' .config && echo 'CONFIG_PACKAGE_ariang=y' >> .config

# bcm53xx: upx_list.txt
# [ "$platform" = "bcm53xx" ] && curl -s https://$mirror/openwrt/generic/upx_list.txt > upx_list.txt

# Toolchain Cache
if [ "$BUILD_FAST" = "y" ]; then
    [ "$USE_GLIBC" = "y" ] && LIBC=glibc || LIBC=musl
    [ "$isCN" = "CN" ] && github_proxy="http://gh.cooluc.com/" || github_proxy=""
    echo -e "\n${GREEN_COLOR}Download Toolchain ...${RES}"
    PLATFORM_ID=""
    [ -f /etc/os-release ] && source /etc/os-release
    if [ "$PLATFORM_ID" = "platform:el9" ]; then
        TOOLCHAIN_URL="http://127.0.0.1:8080"
    else
        TOOLCHAIN_URL="$github_proxy"https://github.com/sbwml/toolchain-cache/releases/latest/download
    fi
    if [ "$USE_GCC13" = "y" ]; then
        curl -L "$TOOLCHAIN_URL"/toolchain_"$LIBC"_"$toolchain_arch"_13.tar.gz -o toolchain.tar.gz $CURL_BAR
    elif [ "$USE_GCC14" = "y" ]; then
        curl -L "$TOOLCHAIN_URL"/toolchain_"$LIBC"_"$toolchain_arch"_14.tar.gz -o toolchain.tar.gz $CURL_BAR
    elif [ "$USE_GCC15" = "y" ]; then
        curl -L "$TOOLCHAIN_URL"/toolchain_"$LIBC"_"$toolchain_arch"_15.tar.gz -o toolchain.tar.gz $CURL_BAR
    else
        curl -L "$TOOLCHAIN_URL"/toolchain_"$LIBC"_"$toolchain_arch".tar.gz -o toolchain.tar.gz $CURL_BAR
    fi
    echo -e "\n${GREEN_COLOR}Process Toolchain ...${RES}"
    tar -zxf toolchain.tar.gz && rm -f toolchain.tar.gz
    mkdir bin
    find ./staging_dir/ -name '*' -exec touch {} \; >/dev/null 2>&1
    find ./tmp/ -name '*' -exec touch {} \; >/dev/null 2>&1
fi

# init openwrt config
rm -rf tmp/*
if [ "$BUILD" = "n" ]; then
    exit 0
else
    make defconfig
fi

# Compile
if [ "$BUILD_TOOLCHAIN" = "y" ]; then
    echo -e "\r\n${GREEN_COLOR}Building Toolchain ...${RES}\r\n"
    make -j$cores toolchain/compile || make -j$cores toolchain/compile V=s || exit 1
    mkdir -p toolchain-cache
    [ "$USE_GLIBC" = "y" ] && LIBC=glibc || LIBC=musl
    if [ "$USE_GCC13" = "y" ]; then
        tar -zcf toolchain-cache/toolchain_"$LIBC"_"$toolchain_arch"_13.tar.gz ./{build_dir,dl,staging_dir,tmp} && echo -e "${GREEN_COLOR} Build success! ${RES}"
    elif [ "$USE_GCC14" = "y" ]; then
        tar -zcf toolchain-cache/toolchain_"$LIBC"_"$toolchain_arch"_14.tar.gz ./{build_dir,dl,staging_dir,tmp} && echo -e "${GREEN_COLOR} Build success! ${RES}"
    elif [ "$USE_GCC15" = "y" ]; then
        tar -zcf toolchain-cache/toolchain_"$LIBC"_"$toolchain_arch"_15.tar.gz ./{build_dir,dl,staging_dir,tmp} && echo -e "${GREEN_COLOR} Build success! ${RES}"
    else
        tar -zcf toolchain-cache/toolchain_"$LIBC"_"$toolchain_arch".tar.gz ./{build_dir,dl,staging_dir,tmp} && echo -e "${GREEN_COLOR} Build success! ${RES}"
    fi
    exit 0
else
    echo -e "\r\n${GREEN_COLOR}Building OpenWrt ...${RES}\r\n"
    sed -i "/BUILD_DATE/d" package/base-files/files/usr/lib/os-release
    sed -i "/BUILD_ID/aBUILD_DATE=\"$CURRENT_DATE\"" package/base-files/files/usr/lib/os-release
    make -j$cores IGNORE_ERRORS="n m"
fi

# Compile time
endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
SEC=$((end_seconds-start_seconds));

if [ "$platform" = "x86_64" ]; then
    if [ -f bin/targets/x86/64*/*-ext4-combined-efi.img.gz ]; then
        echo -e "${GREEN_COLOR} Build success! ${RES}"
        echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
        if [ "$ALL_KMODS" = y ]; then
            cp -a bin/targets/x86/*/packages $kmodpkg_name
            rm -f $kmodpkg_name/Packages*
            # driver firmware
            cp -a bin/packages/x86_64/base/*firmware*.ipk $kmodpkg_name/
            bash kmod-sign $kmodpkg_name
            tar zcf x86_64-$kmodpkg_name.tar.gz $kmodpkg_name
            rm -rf $kmodpkg_name
        fi
        # OTA json
        if [ "$1" = "rc2" ]; then
            mkdir -p ota
            if [ "$MINIMAL_BUILD" = "y" ]; then
                BUILD_TYPE=minimal
            else
                BUILD_TYPE=releases
            fi
            VERSION=$(sed 's/v//g' version.txt)
            SHA256=$(sha256sum bin/targets/x86/64/*-generic-squashfs-combined-efi.img.gz | awk '{print $1}')
            cat > ota/fw.json <<EOF
{
  "x86_64": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256",
      "url": "https://x86.cooluc.com/$BUILD_TYPE/openwrt-23.05/v$VERSION/openwrt-$VERSION-x86-64-generic-squashfs-combined-efi.img.gz"
    }
  ]
}
EOF
        fi
        # Backup download cache
        if [ "$isCN" = "CN" ] && [ "$1" = "rc2" ]; then
            rm -rf dl/geo* dl/go-mod-cache
            tar cf ../dl.gz dl
        fi
        exit 0
    else
        echo -e "\n${RED_COLOR} Build error... ${RES}"
        echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
        echo
        exit 1
    fi
elif [ "$platform" = "bcm53xx" ]; then
    if [ -f bin/targets/bcm53xx/generic/*netgear_r8500-squashfs.chk ]; then
        echo -e "${GREEN_COLOR} Build success! ${RES}"
        echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
        if [ "$ALL_KMODS" = y ]; then
            cp -a bin/targets/bcm53xx/generic/packages $kmodpkg_name
            rm -f $kmodpkg_name/Packages*
            # driver firmware
            cp -a bin/packages/arm_cortex-a9/base/*firmware*.ipk $kmodpkg_name/
            bash kmod-sign $kmodpkg_name
            tar zcf bcm53xx-$kmodpkg_name.tar.gz $kmodpkg_name
            rm -rf $kmodpkg_name
        fi
        # OTA json
        if [ "$1" = "rc2" ]; then
            mkdir -p ota
            if [ "$MINIMAL_BUILD" = "y" ]; then
                BUILD_TYPE=minimal
            else
                BUILD_TYPE=releases
            fi
            VERSION=$(sed 's/v//g' version.txt)
            SHA256=$(sha256sum bin/targets/bcm53xx/generic/*-bcm53xx-generic-netgear_r8500-squashfs.chk | awk '{print $1}')
            cat > ota/fw.json <<EOF
{
  "netgear,r8500": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256",
      "url": "https://r8500.cooluc.com/$BUILD_TYPE/openwrt-23.05/v$VERSION/openwrt-$VERSION-bcm53xx-generic-netgear_r8500-squashfs.chk"
    }
  ]
}
EOF
        fi
        exit 0
    else
        echo -e "\n${RED_COLOR} Build error... ${RES}"
        echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
        echo
        exit 1
    fi
else
    if [ -f bin/targets/rockchip/armv8*/*-r5s-ext4-sysupgrade.img.gz ] || [ -f bin/targets/rockchip/armv8*/*-r4s-ext4-sysupgrade.img.gz ]; then
        if [ "$ALL_KMODS" = y ]; then
            cp -a bin/targets/rockchip/armv8*/packages $kmodpkg_name
            rm -f $kmodpkg_name/Packages*
            # driver firmware
            cp -a bin/packages/aarch64_generic/base/*firmware*.ipk $kmodpkg_name/
            bash kmod-sign $kmodpkg_name
            tar zcf aarch64-$kmodpkg_name.tar.gz $kmodpkg_name
            rm -rf $kmodpkg_name
        fi
        echo -e "${GREEN_COLOR} Build success! ${RES}"
        echo -e " Build time: ${GREEN_COLOR}$(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s${RES}"
        # OTA json
        if [ "$1" = "rc2" ]; then
            mkdir -p ota
            if [ "$MINIMAL_BUILD" = "y" ]; then
                BUILD_TYPE=minimal
            else
                BUILD_TYPE=releases
            fi
            VERSION=$(sed 's/v//g' version.txt)
            if [ "$model" = "nanopi-r4s" ]; then
                SHA256=$(sha256sum bin/targets/rockchip/armv8*/*-squashfs-sysupgrade.img.gz | awk '{print $1}')
                cat > ota/fw.json <<EOF
{
  "friendlyarm,nanopi-r4s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256",
      "url": "https://r4s.cooluc.com/$BUILD_TYPE/openwrt-23.05/v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r4s-squashfs-sysupgrade.img.gz"
    }
  ]
}
EOF
            elif [ "$model" = "nanopi-r5s" ]; then
                SHA256_R5S=$(sha256sum bin/targets/rockchip/armv8*/*-r5s-squashfs-sysupgrade.img.gz | awk '{print $1}')
                cat > ota/fw.json <<EOF
{
  "friendlyarm,nanopi-r5s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_R5S",
      "url": "https://r5s.cooluc.com/$BUILD_TYPE/openwrt-23.05/v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r5s-squashfs-sysupgrade.img.gz"
    }
  ]
}
EOF
            fi
        fi
        # Backup download cache
        if [ "$isCN" = "CN" ] && [ "$version" = "rc2" ]; then
            rm -rf dl/geo* dl/go-mod-cache
            tar -cf ../dl.gz dl
        fi
        exit 0
    else
        echo -e "\n${RED_COLOR} Build error... ${RES}"
        echo -e " Build time: ${RED_COLOR}$(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s${RES}"
        echo
        exit 1
    fi
fi

# 很少有人会告诉你为什么要这样做，而是会要求你必须要这样做。
