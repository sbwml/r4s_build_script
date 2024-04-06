rm -rf bin
rm -rf build_dir/target-aarch64_generic_musl/root-rockchip build_dir/target-x86_64_musl/root-x86 build_dir/target-arm_cortex-a9_musl_eabi/root-bcm53xx
rm -rf build_dir/target-aarch64_generic_musl/root.orig-rockchip build_dir/target-x86_64_musl/root.orig-x86 build_dir/target-arm_cortex-a9_musl_eabi/root.orig-bcm53xx
rm -rf staging_dir/target-aarch64_generic_musl/root-rockchip staging_dir/target-x86_64_musl/root-x86
rm -rf staging_dir/packages/rockchip staging_dir/packages/x86 staging_dir/target-arm_cortex-a9_musl_eabi/root-bcm53xx
rm -rf dl/geo*
rm -rf tmp/.config*
CURRENT_DATE=$(date +%s)
sed -i "/BUILD_DATE/d" package/base-files/files/usr/lib/os-release
sed -i "/BUILD_ID/aBUILD_DATE=\"$CURRENT_DATE\"" package/base-files/files/usr/lib/os-release
