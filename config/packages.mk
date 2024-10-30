PRODUCT_SOONG_NAMESPACES += \
    vendor/blackiron/packages

# /system_ext packages
PRODUCT_PACKAGES += \
    androidx.window.extensions \
    androidx.window.sidecar

PRODUCT_PACKAGES += \
    Backgrounds \
    BatteryStatsViewer \
    OmniJaws \
    Updater \
    GameSpace

ifneq ($(WITH_GMS),true)
PRODUCT_PACKAGES += \
    LatinIME
endif
