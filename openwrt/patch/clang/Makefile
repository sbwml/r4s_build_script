#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clang
PKG_VERSION:=19.1.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-x86_64-redhat-linux.tar.xz
PKG_SOURCE_URL:=https://github.com/sbwml/redhat-llvm-project/releases/download/$(PKG_VERSION)/
PKG_HASH:=21c9d10911eeccd31ab648da1beabe94048ecda441149bbba0a12302f105f337

PKG_MAINTAINER:=sbwml <admin@cooluc.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/host-build.mk

define Host/Prepare
	$(TAR) --strip-components=1 -C $(HOST_BUILD_DIR) -xf $(DL_DIR)/$(PKG_NAME)-$(PKG_VERSION)-x86_64-redhat-linux.tar.xz
endef

define Host/Compile
endef

define Host/Install
	$(CP) $(HOST_BUILD_DIR)/{bin,include,lib,share} $(STAGING_DIR_HOST)/
endef

define Host/Uninstall
	( \
		rm -rf $(STAGING_DIR_HOST)/bin/{FileCheck,clang*,dsymutil,git-clang-format,*lld*,llc,llvm*,merge-fdata,opt,perf2bolt,run-clang-tidy,wasm-ld,yaml2obj} ; \
		rm -rf $(STAGING_DIR_HOST)/include/{c++,clang,clang-c,__libunwind_config.h,libunwind.h,libunwind.modulemap,lld,llvm,llvm-c,mach-o,unwind_arm_ehabi.h,unwind.h,unwind_itanium.h,x86_64-redhat-linux-gnu} ; \
		rm -rf $(STAGING_DIR_HOST)/lib/{bfd-plugins,clang,cmake,x86_64-redhat-linux-gnu,LLVMgold.so,libLLVM*,libLTO*,libPolly.a,libRemarks.so*,libclang*,libedit*,libfindAllSymbols.a,liblld*,liblzma*,libncurses*,libxml2*} ; \
	)
endef

$(eval $(call HostBuild))
