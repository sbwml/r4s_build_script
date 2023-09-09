# NanoPi R4S/R5S/R5C & X86_64 OpenWrt 简易构建脚本存档

### 存档来自：https://init2.cooluc.com

---------------

## 本地编译环境安装（根据 debian 11 / ubuntu 22）
```shell
sudo apt-get update
sudo apt-get install -y build-essential flex bison g++ gawk gcc-multilib g++-multilib gettext git libfuse-dev libncurses5-dev libssl-dev python3 python3-pip python3-ply python3-distutils python3-pyelftools rsync unzip zlib1g-dev file wget subversion patch upx-ucl autoconf automake curl asciidoc binutils bzip2 lib32gcc-s1 libc6-dev-i386 uglifyjs msmtp texinfo libreadline-dev libglib2.0-dev xmlto libelf-dev libtool autopoint antlr3 gperf ccache swig coreutils haveged scons libpython3-dev jq
```

##### 安装 clang-15 - 启用 BPF 支持时需要
##### 一些过旧的发行版没有提供 clang-15，可以通过 llvm 官方提供源安装：https://apt.llvm.org
```shell
# debian 11
sudo sh -c 'echo "deb http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye-15 main" >> /etc/apt/sources.list'
sudo sh -c 'echo "deb-src http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye-15 main" >> /etc/apt/sources.list'
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y clang-15

# ubuntu 20.04
sudo sh -c 'echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-15 main" >> /etc/apt/sources.list'
sudo sh -c 'echo "deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-15 main" >> /etc/apt/sources.list'
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y clang-15

# debian 12 or latest & ubuntu 22 or latest
sudo apt-get update
sudo apt-get install -y clang-15
```

---------------

### 启用 glibc （测试）
##### 脚本支持使用 glibc 库进行构建，当启用 glibc 进行构建时，构建的固件将会同时兼容 musl/glibc 的预构建二进制程序
##### 只需在构建固件前执行以下命令即可启用 glibc 构建

```
export USE_GLIBC=y
```

### 启用 BPF 支持
##### 只需在构建固件前执行以下命令即可启用 BPF 支持

```
export ENABLE_BPF=y
```

### 快速构建（仅限 Github Actions）
##### 脚本会使用 toolchain 缓存代替源码构建，与常规构建相比能节省大约 60 分钟的编译耗时，仅适用于 Github Actions `ubuntu-22.04` 环境
##### 只需在构建固件前执行以下命令即可启用快速构建

```
export BUILD_FAST=y
```

---------------

## 构建 OpenWrt 23.05 最新 Releases

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
# linux-6.1
bash <(curl -sS https://init2.cooluc.com/build.sh) rc2 x86_64
```

## 构建 OpenWrt 23.05 开发版（23.05-SNAPSHOT）

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
# linux-6.1
bash <(curl -sS https://init2.cooluc.com/build.sh) dev x86_64
```

-----------------

# 基于本仓库进行自定义构建 - 本地编译

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

### 三、在本地 Linux 执行基于你自己仓库的构建脚本，即可编译所需固件

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
# linux-6.1
bash <(curl -sS https://raw.githubusercontent.com/你的用户名/r4s_build_script/master/openwrt/build.sh) rc2 x86_64
```

-----------------

# 使用 Github Actions 构建

### 一、Fork 本仓库到自己 GitHub 上（不要更改仓库名称）

### 二、通过仓库设置 添加 Actions 令牌

 - Name: `workflow_token`
 - Secret：`你的 GitHub Token`  [创建 New personal access token (classic)](https://github.com/settings/tokens/new) （所需权限：`repo` 和 `workflow`）

  <img src="https://github.com/sbwml/builder/assets/16485166/70e92cdb-80dd-46d6-8593-a76e3dbb176b" height = "350" alt="token" />

### 三、点击仓库右上角的 ⭐Star 既可触发构建
