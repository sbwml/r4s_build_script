#
# Copyright (C) 2024 Zbynek Kocur
# 
# This is free software, licensed under the 3-Clause BSD License.
# See /LICENSE for more information.
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=dpdk
PKG_VERSION:=24.03
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/DPDK/dpdk/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=1dcbddec31ea0abd1bb8fe9bed2187272fb8d719443332b5d6c36162c42120f8

PKG_MAINTAINER:=Zbynek Kocur <zbynek.kocur@fel.cvut.cz>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

NULL:=
SPACE:=$(NULL) $(NULL)
COMMA:=,

# Required by MUSL for building
ifneq ($(CONFIG_USE_MUSL),)
  TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Package/libdpdk/config
  source "$(SOURCE)/Config.in"
endef

PLATFORM:=$(strip \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_generic),generic) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_generic_aarch32),generic_aarch32) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_altra),altra) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_ampereone),ampereone) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_aarmada),armada) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_bluefield),bluefield) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_bluefield3),bluefield3) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_capri),capri) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_cdx),cdx) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_centriq2400),centriq2400) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_cn9k),cn9k) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_cn10k),cn10k) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_dpaa),dpaa) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_elba),elba) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_emag),emag) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_ft2000plus),ft2000plus) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_tys2500),tys2500) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_grce),grace) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_graviton2),graviton2) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_graviton3),graviton3) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_graviton4),graviton4) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_hip10),hip10) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_kunpeng920),kunpeng920) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_kunpeng930),kunpeng930) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_n1sdp),n1sdp) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_n2),n2) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_odyssey),odyssey) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_stingray),stingray) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_thunderx2),thunderx2) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_thunderxt88),thunderxt88) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_thunderxt83),thunderxt83) \
	$(if $(CONFIG_LIBDPDK_ARM_ARCH_v2),v2) \
	)

CPU_INST:=$(strip \
	$(if $(CONFIG_LIBDPDK_ARCH_nocona),nocona) \
	$(if $(CONFIG_LIBDPDK_ARCH_core2),core2) \
	$(if $(CONFIG_LIBDPDK_ARCH_corei7),corei7) \
	$(if $(CONFIG_LIBDPDK_ARCH_westmere),westmere) \
	$(if $(CONFIG_LIBDPDK_ARCH_sandybridge),sandybridge) \
	$(if $(CONFIG_LIBDPDK_ARCH_corei7-avx),corei7-avx) \
	$(if $(CONFIG_LIBDPDK_ARCH_ivybridge),ivybridge) \
	$(if $(CONFIG_LIBDPDK_ARCH_core-avx-i),core-avx-i) \
	$(if $(CONFIG_LIBDPDK_ARCH_haswell),haswell) \
	$(if $(CONFIG_LIBDPDK_ARCH_core-avx2),core-avx2) \
	$(if $(CONFIG_LIBDPDK_ARCH_broadwell),broadwell) \
	$(if $(CONFIG_LIBDPDK_ARCH_skylake),skylake) \
	$(if $(CONFIG_LIBDPDK_ARCH_skylake-avx512),skylake-avx512) \
	$(if $(CONFIG_LIBDPDK_ARCH_cannonlake),cannonlake) \
	$(if $(CONFIG_LIBDPDK_ARCH_icelake-client),icelake-client) \
	$(if $(CONFIG_LIBDPDK_ARCH_icelake-server),icelake-server) \
	$(if $(CONFIG_LIBDPDK_ARCH_bonnell),bonnell) \
	$(if $(CONFIG_LIBDPDK_ARCH_atom),atom) \
	$(if $(CONFIG_LIBDPDK_ARCH_silvermont),silvermont) \
	$(if $(CONFIG_LIBDPDK_ARCH_slm),slm) \
	$(if $(CONFIG_LIBDPDK_ARCH_knl),knl) \
	$(if $(CONFIG_LIBDPDK_ARCH_knm),knm) \
	$(if $(CONFIG_LIBDPDK_ARCH_x86-64),x86-64) \
	$(if $(CONFIG_LIBDPDK_ARCH_eden-x2),eden-x2) \
	$(if $(CONFIG_LIBDPDK_ARCH_nano),nano) \
	$(if $(CONFIG_LIBDPDK_ARCH_nano-1000),nano-1000) \
	$(if $(CONFIG_LIBDPDK_ARCH_nano-2000),nano-2000) \
	$(if $(CONFIG_LIBDPDK_ARCH_nano-3000),nano-3000) \
	$(if $(CONFIG_LIBDPDK_ARCH_nano-x2),nano-x2) \
	$(if $(CONFIG_LIBDPDK_ARCH_eden-x4),eden-x4) \
	$(if $(CONFIG_LIBDPDK_ARCH_nano-x4),nano-x4) \
	$(if $(CONFIG_LIBDPDK_ARCH_k8),x86-64) \
	$(if $(CONFIG_LIBDPDK_ARCH_k8-sse3),k8-sse3) \
	$(if $(CONFIG_LIBDPDK_ARCH_opteron),opteron) \
	$(if $(CONFIG_LIBDPDK_ARCH_opteron-sse3),opteron-sse3) \
	$(if $(CONFIG_LIBDPDK_ARCH_athlon64),athlon64) \
	$(if $(CONFIG_LIBDPDK_ARCH_athlon64-sse3),athlon64-sse3) \
	$(if $(CONFIG_LIBDPDK_ARCH_athlon-fx),athlon-fx) \
	$(if $(CONFIG_LIBDPDK_ARCH_amdfam10),amdfam10) \
	$(if $(CONFIG_LIBDPDK_ARCH_barcelona),barcelona) \
	$(if $(CONFIG_LIBDPDK_ARCH_bdver1),bdver1) \
	$(if $(CONFIG_LIBDPDK_ARCH_bdver2),bdver2) \
	$(if $(CONFIG_LIBDPDK_ARCH_bdver3),bdver3) \
	$(if $(CONFIG_LIBDPDK_ARCH_bdver4),bdver4) \
	$(if $(CONFIG_LIBDPDK_ARCH_znver1),znver1) \
	$(if $(CONFIG_LIBDPDK_ARCH_btver1),btver1) \
	$(if $(CONFIG_LIBDPDK_ARCH_btver2),btver2) \
	$(if $(CONFIG_LIBDPDK_ARCH_native),native) \
	)

DRIVERS:= \
	mempool/* bus/* common/* dma/* raw/* crypto/* event/*  \
	$(if $(CONFIG_LIBDPDK_DRIVER_AXGBE),net/axgbe) \
	$(if $(CONFIG_LIBDPDK_DRIVER_BNX2X),net/bnx2x) \
	$(if $(CONFIG_LIBDPDK_DRIVER_BNXT),net/bnxt) \
	$(if $(CONFIG_LIBDPDK_DRIVER_CNXK),net/cnxk) \
	$(if $(CONFIG_LIBDPDK_DRIVER_CXGBE),net/cxgbe) \
	$(if $(CONFIG_LIBDPDK_DRIVER_DPAA),net/dpaa) \
	$(if $(CONFIG_LIBDPDK_DRIVER_DPAA2),net/dpaa2) \
	$(if $(CONFIG_LIBDPDK_DRIVER_E1000),net/e1000) \
	$(if $(CONFIG_LIBDPDK_DRIVER_ENETC),net/enetc) \
	$(if $(CONFIG_LIBDPDK_DRIVER_ENETFEC),net/enetfec) \
	$(if $(CONFIG_LIBDPDK_DRIVER_I40E),net/i40e) \
	$(if $(CONFIG_LIBDPDK_DRIVER_ICE),net/ice) \
	$(if $(CONFIG_LIBDPDK_DRIVER_COMMON_IAVF),common/iavf) \
	$(if $(CONFIG_LIBDPDK_DRIVER_IXGBE),net/ixgbe) \
	$(if $(CONFIG_LIBDPDK_DRIVER_MVNETA),net/mvneta) \
	$(if $(CONFIG_LIBDPDK_DRIVER_NGBE),net/ngbe) \
	$(if $(CONFIG_LIBDPDK_DRIVER_OCTEON_EP),net/octeon_ep) \
	$(if $(CONFIG_LIBDPDK_DRIVER_OCTEONTX),net/octeontx) \
	$(if $(CONFIG_LIBDPDK_DRIVER_PFE),net/pfe) \
	$(if $(CONFIG_LIBDPDK_DRIVER_R8125),net/r8125) \
	$(if $(CONFIG_LIBDPDK_DRIVER_THUNDERX),net/thunderx) \
	$(if $(CONFIG_LIBDPDK_DRIVER_TXGBE),net/txgbe) \
	$(if $(CONFIG_LIBDPDK_DRIVER_VIRTIO),net/virtio) \

MESON_ARGS+= \
	-Denable_docs=false \
	$(if $(CONFIG_aarch64), -Dplatform=$(PLATFORM)) \
	$(if $(CONFIG_x86_64),-Dplatform=generic -Dcpu_instruction_set=$(CPU_INST)) \
	-Denable_drivers=$(subst $(SPACE),$(COMMA),$(strip $(DRIVERS))) \

define Package/libdpdk
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=@(x86_64||aarch64) +@KERNEL_HUGETLB_PAGE +librt +libpthread +libbpf +libpcap +libopenssl +zlib +jansson +libelf +libarchive +libbsd +libkmod +libnuma +libfdt
  TITLE:=Set of libraries and drivers for fast packet processing
  URL:=https://www.dpdk.org
endef

define Package/libdpdk/description
  DPDK is a set of libraries and drivers for fast packet processing.
  It supports many processor architectures and both FreeBSD and Linux.
endef

define Package/dpdk-tools
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=@(x86_64||aarch64) +libdpdk +python3-light
  TITLE:=Set of tools for fast packet processing based on DPDK
  URL:=https://www.dpdk.org
endef

define Package/dpdk-tools/description
  DPDK is a set of libraries and drivers for fast packet processing.
  It supports many processor architectures and both FreeBSD and Linux.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/rte_*.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/include/generic/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/generic/rte_*.h $(1)/usr/include/generic/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/{librte_*.a,librte_*.so*,dpdk} $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libdpdk*.pc $(1)/usr/lib/pkgconfig/
endef


define Package/libdpdk/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/librte_*.so.* $(1)/usr/lib/
endef
		
define Package/dpdk-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dpdk-devbind.py $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dpdk-pdump $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dpdk-proc-info $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dpdk-testpmd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dpdk-test-flow-perf $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libdpdk))
$(eval $(call BuildPackage,dpdk-tools))
