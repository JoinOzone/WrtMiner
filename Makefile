##############################################
# OpenWrt Makefile for wrtminer
##############################################

include $(TOPDIR)/rules.mk

# Name and release number of this package
PKG_NAME:=wrtminer
PKG_VERSION:=1.0.0
PKG_RELEASE:=1


# This specifies the directory where we're going to build the program.  
# The root build directory, $(BUILD_DIR), is by default the build_mipsel 
# directory in your OpenWrt SDK directory
PKG_SOURCE:=wrtminer-$(PKG_VERSION).tar.xz
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)


include $(INCLUDE_DIR)/package.mk


# Specify package information for this program. 
# The variables defined here should be self explanatory.
define Package/wrtminer
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=WrtMiner - mines cryptocurrency on your router
	DEPENDS:=+libcurl +libopenssl +zlib +libstdcpp
	MAINTAINER:=Alex Atallah <alex.atallah@joinozone.com>
	URL:=https://joinozone.com
endef


define Package/wrtminer/description
	Mine cryptocurrency when your router is idle. See joinozone.com
endef

define Build/Configure
	$(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef


CONFIGURE_ARGS += \
	CFLAGS="-mfpu=neon" \
	--with-curl \
	--with-crypto

# CONFIGURE_VARS += \
# 	CC="$(TOOLCHAIN_DIR)/bin/$(TARGET_CC)"

# Specify what needs to be done to prepare for building the package.
# In our case, we need to copy the source files to the build directory.
# This is NOT the default.  The default uses the PKG_SOURCE_URL and the
# PKG_SOURCE which is not defined here to download the source from the web.
# In order to just build a simple program that we have just written, it is
# much easier to do it this way.
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./cpuminer-multi-tpruvot/* $(PKG_BUILD_DIR)/
	( cd $(PKG_BUILD_DIR); ./autogen.sh )
	# $(call Build/Configure/Default)
endef


#########################################################################################
# The Build/Compile directive needs to be specified in order to customize compilation
# and linking of our program.  We need to link to uClibc++ and to specify that we 
# do NOT want to link to the standard template library.
#
# To do this we define the LIBS variable.  To prevent linking to the standard libraries we 
# add "-nodefaultlibs" to the $(LIBS) variable and then specify "-lgcc -lc" to ensure that 
# there are no unresolved references to internal GCC library subroutines. Finally 
# "-luClibc++" to link to the  uClibc++ library.  Note the capital C in that flag, as
# this flag is case sensitive.  Also, we need to specify "-nostdinc++" 
# in the compiler flags to tell the compiler that c++ standard template library functions
# and data structures will be linked to in specified external libraries and not the 
# standard libraries.
#########################################################################################
# define Build/Compile
# 	$(MAKE) -C $(PKG_BUILD_DIR) \
# 		LIBS="-nodefaultlibs -lgcc -lc -luClibc++" \
# 		LDFLAGS="$(EXTRA_LDFLAGS)" \
# 		CXXFLAGS="$(TARGET_CFLAGS) $(EXTRA_CPPFLAGS) -nostdinc++" \
# 		$(TARGET_CONFIGURE_OPTS) \
# 		CROSS="$(TARGET_CROSS)" \
# 		ARCH="$(ARCH)" \
# 		$(1);
# endef


# Specify where and how to install the program. Since we only have one file, 
# the wrtminer executable, install it by copying it to the /bin directory on
# the router. The $(1) variable represents the root directory on the router running 
# OpenWrt. The $(INSTALL_DIR) variable contains a command to prepare the install 
# directory if it does not already exist.  Likewise $(INSTALL_BIN) contains the 
# command to copy the binary file from its current location (in our case the build
# directory) to the install directory.
define Package/wrtminer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cpuminer $(1)/usr/bin

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/wrtminer.init $(1)/etc/init.d/wrtminer
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/wrtminer.config $(1)/etc/config/wrtminer
endef


# This line executes the necessary commands to compile our program.
# The above define directives specify all the information needed, but this
# line calls BuildPackage which in turn actually uses this information to
# build a package.
$(eval $(call BuildPackage,wrtminer))
