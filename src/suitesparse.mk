# This file is part of mingw-cross-env.
# See doc/index.html for further information.

# SuiteSparse
PKG             := suitesparse
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.4.0
$(PKG)_CHECKSUM := 6de027d48a573659b40ddf57c10e32b39ab034c6
$(PKG)_SUBDIR   := SuiteSparse
$(PKG)_FILE     := SuiteSparse-$($(PKG)_VERSION).tar.gz
$(PKG)_WEBSITE  := http://www.cise.ufl.edu/
$(PKG)_URL      := http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-3.4.0.tar.gz
$(PKG)_DEPS     := gcc metis lapack

define $(PKG)_UPDATE
    wget -q -O- 'http://www.cise.ufl.edu/research/sparse/SuiteSparse/' | \
    $(SED) -n 's,.*SuiteSparse-\([0-9]\.[0-9]\.[0-9]\)\.tar.*,\1,ip' | \
    head -1
endef

define $(PKG)_BUILD
    
    # If not building metis in it's makefile, then
    # build it here since the config seems to expect it
    cd '$(1)' && $(call UNPACK_PKG_ARCHIVE,metis)
    $(SED) -i 's,cc,$(TARGET)-gcc,'        $(1)/$(metis_SUBDIR)/Makefile.in
    $(SED) -i 's,ar ,$(TARGET)-ar ,'       $(1)/$(metis_SUBDIR)/Makefile.in
    $(SED) -i 's,ranlib,$(TARGET)-ranlib,' $(1)/$(metis_SUBDIR)/Makefile.in
    $(MAKE) -C '$(1)/$(metis_SUBDIR)/Lib' -j '$(JOBS)'

    # Otherwise hack the config so it can find metis
    #$(SED) -i 's,\(METIS_PATH = \)\(../../metis-4.0\),\1'$(PREFIX)/$(TARGET)/include/metis',' $(1)/UFconfig/UFconfig.mk
    #$(SED) -i 's,\(METIS = \)\(../../metis-4.0/libmetis.a\),\1'$(PREFIX)/$(TARGET)/lib/libmetis.a',' $(1)/UFconfig/UFconfig.mk
    
    # use cross tools
    $(SED) -i 's,cc,$(TARGET)-gcc,'        $(1)/UFconfig/UFconfig.mk
    $(SED) -i 's,g++,$(TARGET)-g++,'       $(1)/UFconfig/UFconfig.mk
    $(SED) -i 's,f77,$(TARGET)-gfortran,'  $(1)/UFconfig/UFconfig.mk
    $(SED) -i 's,ar ,$(TARGET)-ar ,'       $(1)/UFconfig/UFconfig.mk
    $(SED) -i 's,ranlib,$(TARGET)-ranlib,' $(1)/UFconfig/UFconfig.mk

    # use BLAS from GSL since it's already part of mingw-cross-env
    $(SED) -i 's,-lblas -lgfortran -lgfortranbegin -lg2c,-lblas -lgfortran -lgfortranbegin,' $(1)/UFconfig/UFconfig.mk
    
    # however, we get linking errros
    $(MAKE) -C '$(1)' -j '$(JOBS)'

    # CHOLMOD has no errors on it's own though, but seems to be missing a link step
    $(MAKE) -C '$(1)/CHOLMOD/Lib' -j '$(JOBS)'

endef

