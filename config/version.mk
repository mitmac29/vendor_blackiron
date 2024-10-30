# (C) 2023-2024 Blackiron

# Blackiron versioning

PRODUCT_SOONG_NAMESPACES += \
    vendor/blackiron/version

BLACKIRON_FLAVOR := VanillaIceCream
BLACKIRON_VERSION := 5.0
BLACKIRON_CODENAME := MacteAnimo
BLACKIRON_RELEASE_TYPE := BETA
BLACKIRON_CODE := $(BLACKIRON_VERSION)

BLACKIRON_BUILD_DATE := $(shell date -u +%Y%m%d)

CURRENT_DEVICE := $(shell echo "$(TARGET_PRODUCT)" | cut -d'_' -f 2,3)
MAINTAINER_LIST := $(shell cat OTA/Blackiron.maintainers)
DEVICE_LIST := $(shell cat OTA/Blackiron.devices)

ifeq ($(filter $(CURRENT_DEVICE),$(DEVICE_LIST)), $(CURRENT_DEVICE))
    ifdef BLACKIRON_MAINTAINER
        ifneq ($(filter $(BLACKIRON_MAINTAINER),$(MAINTAINER_LIST)),)
            BLACKIRON_BUILDTYPE := OFFICIAL
        else
            BLACKIRON_BUILDTYPE := UNOFFICIAL
        endif
    else
        BLACKIRON_BUILDTYPE := UNOFFICIAL
    endif
else
    BLACKIRON_BUILDTYPE := COMMUNITY
endif

ifeq ($(WITH_GMS), true)
	ifeq ($(TARGET_CORE_GMS), true)
    	BLACKIRON_PACKAGE_TYPE ?= CORE
	else 
    	BLACKIRON_PACKAGE_TYPE ?= GAPPS
	endif
else
    BLACKIRON_PACKAGE_TYPE ?= VANILLA
endif

# Build version
BLACKIRON_BUILD_VERSION := $(BLACKIRON_VERSION)-$(BLACKIRON_RELEASE_TYPE)-$(BLACKIRON_BUILD_DATE)-$(BLACKIRON_PACKAGE_TYPE)-$(BLACKIRON_BUILDTYPE)-$(CURRENT_DEVICE)

# Display version
BLACKIRON_DISPLAY_VERSION := $(BLACKIRON_VERSION)-$(BLACKIRON_RELEASE_TYPE)-$(BLACKIRON_PACKAGE_TYPE)-$(BLACKIRON_BUILDTYPE)-$(CURRENT_DEVICE)

# Blackiron properties
PRODUCT_PRODUCT_PROPERTIES += \
    ro.blackiron.code=$(BLACKIRON_CODENAME) \
    ro.blackiron.packagetype=$(BLACKIRON_PACKAGE_TYPE) \
    ro.blackiron.releasetype=$(BLACKIRON_BUILDTYPE) \
    ro.blackiron.version?=$(BLACKIRON_VERSION) \
    ro.blackiron.build.version=$(BLACKIRON_BUILD_VERSION) \
    ro.blackiron.display.version?=$(BLACKIRON_DISPLAY_VERSION) \
    ro.blackiron.platform_release_codename=$(BLACKIRON_FLAVOR) \
    ro.blackiron.device=$(CURRENT_DEVICE) \
    ro.blackiron.storage?=$(BLACKIRON_STORAGE) \
    ro.blackiron.ram?=$(BLACKIRON_RAM) \
    ro.blackiron.battery?=$(BLACKIRON_BATTERY) \
    ro.blackiron.display_resolution?=$(BLACKIRON_DISPLAY)
