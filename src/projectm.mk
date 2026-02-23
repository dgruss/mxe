# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := projectm
$(PKG)_WEBSITE  := https://github.com/projectM-visualizer/projectm
$(PKG)_DESCR    := projectM
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.2.1
$(PKG)_CHECKSUM := 9bbb33c5ba048537e97ea5ba2bd9fef76972c881597599a272b0194ec1d5f2a3
$(PKG)_SUBDIR   := projectM-$($(PKG)_VERSION)
$(PKG)_FILE     := projectM-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://github.com/projectM-visualizer/projectm/releases/download/v$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_PATCHES  := $(realpath $(sort $(wildcard $(addsuffix /projectm-[0-9]*.patch, $(TOP_DIR)/src))))
$(PKG)_DEPS     := cc zlib libpng libjpeg-turbo freetype dlfcn-win32

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-sdl \
        --disable-qt \
        --disable-ftgl
    $(MAKE) -C '$(1)' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=

    # Upstream install omits internal headers required by projectM.hpp
    # (event.h, fatal.h, config.h, etc.), but the USDX wrapper includes
    # projectM.hpp directly. Install generated config.h and only header files.
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/include'
    [ -f '$(1)/config.h' ] && $(INSTALL) -m644 '$(1)/config.h' '$(PREFIX)/$(TARGET)/include/config.h' || true
    cd '$(1)/src/libprojectM' && find . -type f \( -name '*.h' -o -name '*.hpp' \) | while read -r f; do \
        d=$$(dirname "$$f"); \
        $(INSTALL) -d '$(PREFIX)/$(TARGET)/include/'"$$d"; \
        $(INSTALL) -m644 "$$f" '$(PREFIX)/$(TARGET)/include/'"$$f"; \
    done

    # Windows convention: DLLs in bin/, not in lib/.
    $(if $(BUILD_SHARED), \
        mv -fv '$(PREFIX)/$(TARGET)/lib/'libprojectM*.dll '$(PREFIX)/$(TARGET)/bin/' 2>/dev/null || true, \
				true
			fi)
endef
