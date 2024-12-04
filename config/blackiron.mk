-include vendor/addons/config.mk
WITH_GMS ?= false
ifeq ($(WITH_GMS),true)
-include vendor/gms/products/gms.mk
endif
include vendor/blackiron/config/properties.mk
include vendor/blackiron/config/packages.mk
include vendor/blackiron/config/vars.mk
include vendor/blackiron/config/version.mk
include vendor/blackiron/audio/audio.mk
include vendor/blackiron/overlays/build.mk
include vendor/blackiron/prebuilts/prebuilts.mk
-include vendor/pixeloverlays/config.mk
-include vendor/google/mainline_modules/config.mk


PRODUCT_SOONG_NAMESPACES += \
    vendor/blackiron/common

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.freeform_window_management.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.freeform_window_management.xml

# Dexopt
PRODUCT_DEXPREOPT_SPEED_APPS += \
    Trebuchet \
    NexusLauncherRelease

# Product Copy
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl \
    frameworks/native/data/etc/android.software.freeform_window_management.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.freeform_window_management.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

ifeq ($(LINEAGE_BUILD),)
# Extracted APN's from Cheetah
PRODUCT_COPY_FILES += \
    vendor/blackiron/prebuilts/apn/apns-conf.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/apns-conf.xml
endif

TARGET_SHIP_LEGACY_BOOT_ANIMAITON ?= false
ifeq ($(TARGET_SHIP_LEGACY_BOOT_ANIMAITON),true)
PRODUCT_COPY_FILES += vendor/blackiron/prebuilts/bootanimation.zip:$(TARGET_COPY_OUT_PRODUCT)/media/bootanimation.zip
endif
