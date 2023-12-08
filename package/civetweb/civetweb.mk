################################################################################
#
# civetweb
#
################################################################################

CIVETWEB_VERSION = v1.11
CIVETWEB_SITE = $(call github,civetweb,civetweb,$(CIVETWEB_VERSION))
CIVETWEB_LICENSE = MIT
CIVETWEB_LICENSE_FILES = LICENSE.md

CIVETWEB_CONF_OPTS = TARGET_OS=LINUX WITH_IPV6=1 \
	$(if $(BR2_INSTALL_LIBSTDCPP),WITH_CPP=1)
CIVETWEB_COPT = -DHAVE_POSIX_FALLOCATE=0
CIVETWEB_LIBS = -lpthread -lm
CIVETWEB_SYSCONFDIR = /etc
CIVETWEB_HTMLDIR = /var/www
CIVETWEB_INSTALL_OPTS = \
	DOCUMENT_ROOT="$(CIVETWEB_HTMLDIR)" \
	CONFIG_FILE2="$(CIVETWEB_SYSCONFDIR)/civetweb.conf" \
	HTMLDIR="$(TARGET_DIR)$(CIVETWEB_HTMLDIR)" \
	SYSCONFDIR="$(TARGET_DIR)$(CIVETWEB_SYSCONFDIR)"

ifeq ($(BR2_TOOLCHAIN_HAS_SYNC_4),)
CIVETWEB_COPT += -DNO_ATOMICS=1
endif

ifeq ($(BR2_PACKAGE_CIVETWEB_WITH_LUA),y)
CIVETWEB_CONF_OPTS += WITH_LUA=1
CIVETWEB_LIBS += -ldl
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
CIVETWEB_COPT += -DNO_SSL_DL
CIVETWEB_LIBS += -lssl -lcrypto -lz
CIVETWEB_DEPENDENCIES += openssl
else
CIVETWEB_COPT += -DNO_SSL
endif

ifeq ($(BR2_PACKAGE_CIVETWEB_SERVER),y)
CIVETWEB_BUILD_TARGETS += build
CIVETWEB_INSTALL_TARGETS += install
endif

ifeq ($(BR2_PACKAGE_CIVETWEB_LIB),y)
CIVETWEB_INSTALL_STAGING = YES
CIVETWEB_INSTALL_TARGETS += install-headers

ifeq ($(BR2_STATIC_LIBS)$(BR2_STATIC_SHARED_LIBS),y)
CIVETWEB_BUILD_TARGETS += lib
CIVETWEB_INSTALL_TARGETS += install-lib
endif

ifeq ($(BR2_SHARED_LIBS)$(BR2_STATIC_SHARED_LIBS),y)
CIVETWEB_BUILD_TARGETS += slib
CIVETWEB_INSTALL_TARGETS += install-slib
CIVETWEB_COPT += -fPIC
endif

endif # BR2_PACKAGE_CIVETWEB_LIB

define CIVETWEB_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(CIVETWEB_BUILD_TARGETS) \
		$(CIVETWEB_CONF_OPTS) \
		COPT="$(CIVETWEB_COPT)" LIBS="$(CIVETWEB_LIBS)"
endef

define CIVETWEB_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(CIVETWEB_INSTALL_TARGETS) \
		PREFIX="$(STAGING_DIR)/usr" \
		$(CIVETWEB_INSTALL_OPTS) \
		$(CIVETWEB_CONF_OPTS) \
		COPT='$(CIVETWEB_COPT)'
endef

define CIVETWEB_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/include
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(CIVETWEB_INSTALL_TARGETS) \
		PREFIX="$(TARGET_DIR)/usr" \
		$(CIVETWEB_INSTALL_OPTS) \
		$(CIVETWEB_CONF_OPTS) \
		COPT='$(CIVETWEB_COPT)'
endef

$(eval $(generic-package))
