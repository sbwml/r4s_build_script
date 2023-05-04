# NanoPi R4S/R5S/R5C & X86_64 OpenWrt 简易构建脚本存档
### 存档来自：https://init2.cooluc.com

---------------

## 编译环境（debian 11 / ubuntu 22）
```shell
sudo apt-get update
sudo apt-get install -y build-essential flex bison g++ gawk gcc-multilib g++-multilib gettext git libfuse-dev libncurses5-dev libssl-dev python3 python3-pip python3-ply python3-distutils python3-pyelftools rsync unzip zlib1g-dev file wget subversion patch upx-ucl autoconf automake curl proxychains-ng asciidoc binutils bzip2 lib32gcc-s1 libc6-dev-i386 uglifyjs msmtp texinfo libreadline-dev libglib2.0-dev xmlto libelf-dev libtool autopoint antlr3 gperf ccache swig coreutils haveged scons libpython3-dev
```

## nanopi-r4s openwrt-22.03
```shell
# linux-6.1
bash <(curl -sS https://init2.cooluc.com/build.sh) rc

# linux-6.3 - testing
KERNEL_TESTING=1 bash <(curl -sS https://init2.cooluc.com/build.sh) rc
```

## nanopi-r5s/r5c openwrt-22.03
```shell
# linux-6.1
bash <(curl -sS https://init2.cooluc.com/build.sh) rc r5s

# linux-6.3 - testing
KERNEL_TESTING=1 bash <(curl -sS https://init2.cooluc.com/build.sh) rc r5s
```

## x86_64 openwrt-22.03
```shell
bash <(curl -sS https://init2.cooluc.com/build.sh) rc x86
```

-----------------

# 基于本仓库进行自定义构建

## 如果你有自定义的需求，建议不要变更内核版本号，这样构建出来的固件可以直接使用 `opkg install kmod-xxxx`

### 一、Fork 本仓库到自己 GitHub 上（不要更改仓库名称）

### 二、修改构建脚本文件：`openwrt/build.sh`

将 init.cooluc.com 补丁默认连接替换为你的 github raw 连接（不带 https://），像这样 `raw.githubusercontent.com/你的用户名/r4s_build_script/master`

```diff
--- a/openwrt/build.sh
+++ b/openwrt/build.sh
@@ -17,9 +17,9 @@ export isCN=`echo $ip_info | grep -Po 'country_code\":"\K[^"]+'`;
 
 # init url
 if [ "$isCN" = "CN" ]; then
-    export mirror=init.cooluc.com
+    export mirror=raw.githubusercontent.com/你的用户名/r4s_build_script/master
 else
-    export mirror=init2.cooluc.com
+    export mirror=raw.githubusercontent.com/你的用户名/r4s_build_script/master
 fi
 export gitea=git.cooluc.com
 

```

### 三、在服务器上执行基于你自己仓库的构建脚本，即可编译所需固件

#### nanopi-r4s openwrt-22.03
```shell
# linux-6.1
bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) rc

# linux-6.3 - testing
KERNEL_TESTING=1 bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) rc
```

#### nanopi-r5s/r5c openwrt-22.03
```shell
# linux-6.1
bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) rc r5s

# linux-6.3 - testing
KERNEL_TESTING=1 bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) rc r5s
```

-----------------


### 四、使用 Github Actions 构建，任务流样本

#### 新建一个空白仓库（必须，不能直接在本仓库进行构建），并在新仓库上创建 Github Actions 任务流，配置文件如下（把下面 `你的用户名` 替换成 `你的 GitHub 用户名`）

#### 创建：`.github/workflows/build-release.yml` 文件后，点击仓库的 ⭐Star 既可触发编译任务。

```yaml
name: Build releases

on:
  watch:
    types: started

jobs:
  build:
    if: github.event.repository.owner.id == github.event.sender.id
    name: Build ${{ matrix.model }}-${{ matrix.tag.version }}
    runs-on: ubuntu-22.04
    strategy:
      fail-fast: false
      matrix:
        model:
          - nanopi-r4s
          - nanopi-r5s
          - x86_64
        tag:
          - type: rc
            version: openwrt-22.03

    steps:
    - name: Checkout
      uses: actions/checkout@main

    - name: Set time zone
      run: sudo timedatectl set-timezone 'Asia/Shanghai'

    - name: Show system
      run: |
        lscpu
        free -h
        uname -a

    - name: Free disk space
      run: |
        sudo sed -i 's/azure.archive.ubuntu.com/mirror.enzu.com/g' /etc/apt/sources.list
        sudo rm -rf /etc/apt/sources.list.d
        sudo swapoff -a
        sudo rm -f /swapfile
        sudo docker image prune -a -f
        sudo systemctl stop docker
        sudo snap set system refresh.retain=2
        sudo apt-get -y purge dotnet* firefox clang* ghc* google* llvm* mono* mongo* mysql* php*
        sudo apt-get -y autoremove --purge
        sudo apt-get clean
        sudo rm -rf /etc/mysql /etc/php /usr/lib/jvm /usr/libexec/docker /usr/local /usr/src/* /var/lib/docker /var/lib/gems /var/lib/mysql /var/lib/snapd /etc/skel /opt/{microsoft,az,hostedtoolcache,cni,mssql-tools,pipx} /usr/share/{az*,dotnet,swift,miniconda,gradle*,java,kotlinc,ri,sbt} /root/{.sbt,.local,.npm}
        sudo sed -i '/NVM_DIR/d;/skel/d' /root/{.bashrc,.profile}
        rm -rf ~/{.cargo,.dotnet,.rustup}
        df -h

    - name: Init build dependencies
      env:
        DEBIAN_FRONTEND: noninteractive
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential flex bison g++ gawk gcc-multilib g++-multilib gettext git libfuse-dev libncurses5-dev libssl-dev python3 python3-pip python3-ply python3-distutils python3-pyelftools rsync unzip zlib1g-dev file wget subversion patch upx-ucl autoconf automake curl proxychains-ng asciidoc binutils bzip2 lib32gcc-s1 libc6-dev-i386 uglifyjs msmtp texinfo libreadline-dev libglib2.0-dev xmlto libelf-dev libtool autopoint antlr3 gperf ccache swig coreutils haveged scons libpython3-dev
        sudo apt-get clean
        git config --global user.name 'GitHub Actions' && git config --global user.email 'noreply@github.com'
        df -h

    - name: Compile Openwrt
      id: compileopenwrt
      run: |
        if [ "${{ matrix.model }}" = "nanopi-r5s" ]; then
          bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) ${{ matrix.tag.type }} r5s
        elif [ "${{ matrix.model }}" = "x86_64" ]; then
          bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) ${{ matrix.tag.type }} x86
        else
          bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) ${{ matrix.tag.type }}
        fi
        cd openwrt
        tags=$(git describe --abbrev=0 --tags)
        echo "latest_release=$tags" >>$GITHUB_ENV

    - name: Assemble Artifact
      id: assemble_artifact
      run: |
        mkdir -p rom info
        if [ "${{ matrix.model }}" = "nanopi-r4s" ]; then
          cp -a openwrt/bin/targets/rockchip/*/*.img.gz rom/
          cp -a openwrt/bin/targets/rockchip/*/*-r4s.manifest info/manifest.txt
          cp -a openwrt/bin/targets/rockchip/*/config.buildinfo info/config.buildinfo
          cd rom && sha256sum *gz > ../info/sha256sums.txt
        elif [ "${{ matrix.model }}" = "nanopi-r5s" ]; then
          cp -a openwrt/bin/targets/rockchip/*/*.img.gz rom/
          cp -a openwrt/bin/targets/rockchip/*/*.manifest info/manifest.txt
          cp -a openwrt/bin/targets/rockchip/*/config.buildinfo info/config.buildinfo
          cd rom && sha256sum *gz > ../info/sha256sums.txt
        elif [ "${{ matrix.model }}" = "x86_64" ]; then
          cp -a openwrt/bin/targets/x86/*/*-ext4-combined-efi.img.gz rom/
          cp -a openwrt/bin/targets/x86/*/*-squashfs-combined-efi.img.gz rom/
          cp -a openwrt/bin/targets/x86/*/*-generic-rootfs.tar.gz rom/
          cp -a openwrt/bin/targets/x86/*/*-x86-64-generic.manifest info/manifest.txt
          cp -a openwrt/bin/targets/x86/*/config.buildinfo info/config.buildinfo
          cd rom && sha256sum *gz > ../info/sha256sums.txt
        fi

    - name: Create release
      if: env.release != 'false'
      id: create_release
      uses: ncipollo/release-action@v1.11.1
      with:
        name: OpenWRT-${{ env.latest_release }}
        allowUpdates: true
        tag: ${{ env.latest_release }}
        commit: master
        replacesArtifacts: true
        token: ${{ secrets.workflow_token }}
        artifacts: rom/*

```
