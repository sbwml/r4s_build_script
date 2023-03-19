# NanoPi R4S/R5S/R5C & X86_64 OpenWrt 简易构建脚本存档
### 存档来自：https://init2.cooluc.com

## nanopi-r4s openwrt-21.02
```shell
bash <(curl -sS https://init2.cooluc.com/build.sh) stable
```

## nanopi-r4s openwrt-22.03
```shell
# linux-6.1
bash <(curl -sS https://init2.cooluc.com/build.sh) rc

# linux-6.2 - testing
KERNEL_TESTING=1 bash <(curl -sS https://init2.cooluc.com/build.sh) rc

# linux-6.3 - testing
KERNEL_TESTING=1 KERNEL_VER=6.3 bash <(curl -sS https://init2.cooluc.com/build.sh) rc
```

## nanopi-r5s/r5c openwrt-22.03
```shell
# linux-6.1
bash <(curl -sS https://init2.cooluc.com/build.sh) rc r5s

# linux-6.2 - testing
KERNEL_TESTING=1 bash <(curl -sS https://init2.cooluc.com/build.sh) rc r5s

# linux-6.3 - testing
KERNEL_TESTING=1 KERNEL_VER=6.3 bash <(curl -sS https://init2.cooluc.com/build.sh) rc r5s
```

## x86_64 openwrt-21.02
```shell
bash <(curl -sS https://init2.cooluc.com/build.sh) stable x86
```

## x86_64 openwrt-22.03
```shell
bash <(curl -sS https://init2.cooluc.com/build.sh) rc x86
```
