# This file is part of MXE.
# See index.html for further information.

PKG             := glibmm
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.40.0
$(PKG)_CHECKSUM := 52eba9254ebf1d53c01a8afee44f4b709c35816e
$(PKG)_SUBDIR   := glibmm-$($(PKG)_VERSION)
$(PKG)_FILE     := glibmm-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := http://ftp.gnome.org/pub/gnome/sources/glibmm/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc glib libsigc++

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://git.gnome.org/browse/glibmm/refs/tags' | \
    grep '<a href=' | \
    $(SED) -n 's,.*<a[^>]*>\([0-9]*\.[0-9]*[02468]\.[^<]*\)<.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        CXX='$(TARGET)-g++' \
        PKG_CONFIG='$(PREFIX)/bin/$(TARGET)-pkg-config' \
        GLIB_COMPILE_SCHEMAS='$(PREFIX)/$(TARGET)/bin/glib-compile-schemas' \
        MAKE=$(MAKE)
    $(MAKE) -C '$(1)/gio/src' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS= MISC_STUFF=
    $(MAKE) -C '$(1)'         -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef
