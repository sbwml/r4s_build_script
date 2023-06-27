# NanoPi R4S/R5S/R5C & X86_64 OpenWrt 简易构建脚本存档

### 存档来自：https://init2.cooluc.com

---------------

## 安装编译环境（根据 debian 11 / ubuntu 22）
```shell
sudo apt-get update
sudo apt-get install -y build-essential flex bison g++ gawk gcc-multilib g++-multilib gettext git libfuse-dev libncurses5-dev libssl-dev python3 python3-pip python3-ply python3-distutils python3-pyelftools rsync unzip zlib1g-dev file wget subversion patch upx-ucl autoconf automake curl asciidoc binutils bzip2 lib32gcc-s1 libc6-dev-i386 uglifyjs msmtp texinfo libreadline-dev libglib2.0-dev xmlto libelf-dev libtool autopoint antlr3 gperf ccache swig coreutils haveged scons libpython3-dev
```

---------------

### 启用 glibc （测试）
##### 脚本支持使用 glibc 库进行构建，当启用 glibc 进行构建时，构建的固件将会同时兼容 musl/glibc 的所有程序，仅适用于 NanoPI R4S/R5S/R5C
##### 只需在构建固件前执行以下命令即可启用 glibc 构建

```
export USE_GLIBC=y
```

### 快速构建（仅限 Github Actions）
##### 脚本会使用 toolchain 缓存代替源码构建，与常规构建相比能节省大约 60 分钟的编译耗时，仅适用于 Github Actions `ubuntu-22.04` 环境
##### 只需在构建固件前执行以下命令即可启用快速构建

```
export BUILD_FAST=y BUILD_SDK=y
```

---------------

## 构建 OpenWrt 23.05 候选版（RC）

### nanopi-r4s
```shell
# linux-6.1
bash <(curl -sS https://init2.cooluc.com/build.sh) rc2 nanopi-r4s
```

### nanopi-r5s/r5c
```shell
# linux-6.1
bash <(curl -sS https://init2.cooluc.com/build.sh) rc2 nanopi-r5s
```

### x86_64
```shell
# linux-5.15 (follow upstream)
bash <(curl -sS https://init2.cooluc.com/build.sh) rc2 x86_64
```

## 构建 OpenWrt 23.05 开发版

### nanopi-r4s
```shell
# linux-6.1
bash <(curl -sS https://init2.cooluc.com/build.sh) dev nanopi-r4s
```

### nanopi-r5s/r5c
```shell
# linux-6.1
bash <(curl -sS https://init2.cooluc.com/build.sh) dev nanopi-r5s
```

### x86_64
```shell
# linux-5.15 (follow upstream)
bash <(curl -sS https://init2.cooluc.com/build.sh) dev x86_64
```

-----------------

# 基于本仓库进行自定义构建

#### 如果你有自定义的需求，建议不要变更内核版本号，这样构建出来的固件可以直接使用 `opkg install kmod-xxxx`

### 一、Fork 本仓库到自己 GitHub 上（不要更改仓库名称）

### 二、修改构建脚本文件：`openwrt/build.sh`

将 init.cooluc.com 补丁默认连接替换为你的 github raw 连接（不带 https://），像这样 `raw.githubusercontent.com/你的用户名/r4s_build_script/master`

```diff
 # script url
 if [ "$isCN" = "CN" ]; then
-    export mirror=init.cooluc.com
+    export mirror=raw.githubusercontent.com/你的用户名/r4s_build_script/master
 else
-    export mirror=init2.cooluc.com
+    export mirror=raw.githubusercontent.com/你的用户名/r4s_build_script/master
 fi
```

### 三、在服务器上执行基于你自己仓库的构建脚本，即可编译所需固件

#### nanopi-r4s openwrt-23.05
```shell
# linux-6.1
bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) rc2 nanopi-r4s
```

#### nanopi-r5s/r5c openwrt-23.05
```shell
# linux-6.1
bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) rc2 nanopi-r5s
```

#### x86_64 openwrt-23.05
```shell
# linux-5.10 (follow upstream)
bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) rc2 x86_64
```

-----------------

# 使用 Github Actions 构建

新建一个空白仓库，并在新仓库上创建 Github Actions 任务流，Actions 模板参考最下方（把下面 `你的用户名` 替换成 `你的 GitHub 用户名`）

创建：`.github/workflows/build-release.yml` 文件后，点击仓库的 ⭐Star 既可触发构建

添加 Actions 令牌：
 - Name: `workflow_token`
 - Secret：`你的 GitHub Token`

  <img src="https://github.com/sbwml/builder/assets/16485166/70e92cdb-80dd-46d6-8593-a76e3dbb176b" height = "350" alt="token" />

-----------------

```yaml
name: Build releases

on:
  watch:
    types: started

jobs:
  build:
    if: github.event.repository.owner.id == github.event.sender.id
    name: Build ${{ matrix.model }}-${{ matrix.tag.version }}
    runs-on: ubuntu-20.04
    defaults:
      run:
        shell: bash
        working-directory: /home/runner
    strategy:
      fail-fast: false
      matrix:
        model:
          - nanopi-r4s
          - nanopi-r5s
          - x86_64
        tag:
          - type: rc2
            version: openwrt-23.05

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
        sudo rm -rf /etc/apt/sources.list.d
        sudo swapoff -a
        sudo rm -f /swapfile
        sudo docker image prune -a -f
        sudo systemctl stop docker
        sudo snap set system refresh.retain=2
        sudo apt-get -y purge firefox clang* ghc* google* llvm* mono* mongo* mysql* php*
        sudo apt-get -y autoremove --purge
        sudo apt-get clean
        sudo rm -rf /etc/mysql /etc/php /usr/lib/jvm /usr/libexec/docker /usr/local /usr/src/* /var/lib/docker /var/lib/gems /var/lib/mysql /var/lib/snapd /etc/skel /opt/{microsoft,az,hostedtoolcache,cni,mssql-tools,pipx} /usr/share/{az*,dotnet,swift,miniconda,gradle*,java,kotlinc,ri,sbt} /root/{.sbt,.local,.npm}
        sudo sed -i '/NVM_DIR/d;/skel/d' /root/{.bashrc,.profile}
        rm -rf ~/{.cargo,.dotnet,.rustup}
        df -h

    - name: Build System Setup
      env:
        DEBIAN_FRONTEND: noninteractive
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential flex bison g++ gawk gcc-multilib g++-multilib gettext git libfuse-dev libncurses5-dev libssl-dev python3 python3-pip python3-ply python3-distutils python3-pyelftools rsync unzip zlib1g-dev file wget subversion patch upx-ucl autoconf automake curl proxychains-ng asciidoc binutils bzip2 lib32gcc-s1 libc6-dev-i386 uglifyjs msmtp texinfo libreadline-dev libglib2.0-dev xmlto libelf-dev libtool autopoint antlr3 gperf ccache swig coreutils haveged scons libpython3-dev
        sudo apt-get clean
        git config --global user.name 'GitHub Actions' && git config --global user.email 'noreply@github.com'
        df -h

    - name: Compile Openwrt
      run: |
        bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) ${{ matrix.tag.type }} ${{ matrix.model }}
        cd openwrt
        tags=$(git describe --abbrev=0 --tags)
        echo "latest_release=$tags" >>$GITHUB_ENV

    - name: Assemble Artifact
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

    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: ${{ matrix.model }}-${{ matrix.tag.version }}
        path: rom/*.gz

    - name: Create release
      uses: ncipollo/release-action@v1.11.1
      with:
        name: OpenWRT-${{ env.latest_release }}
        allowUpdates: true
        tag: ${{ env.latest_release }}
        commit: main  # 这里必须更改为你仓库的实际分支名称否则固件编译后无法发布到 releases，如：main、master
        replacesArtifacts: true
        token: ${{ secrets.workflow_token }}
        artifacts: rom/*

```
