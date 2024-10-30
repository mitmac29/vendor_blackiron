# Copyright (C) 2017 Unlegacy-Android
# Copyright (C) 2017,2020 The LineageOS Project
# Copyright (C) 2024 Blackiron
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -----------------------------------------------------------------
# Blackiron OTA update package

BLACKIRON_TARGET_PACKAGE := $(PRODUCT_OUT)/Blackiron-$(BLACKIRON_BUILD_VERSION)-ota.zip

SHA256 := prebuilts/build-tools/path/$(HOST_PREBUILT_TAG)/sha256sum

.PHONY: bacon
bacon: $(DEFAULT_GOAL) $(INTERNAL_OTA_PACKAGE_TARGET)
	$(hide) ln -f $(INTERNAL_OTA_PACKAGE_TARGET) $(BLACKIRON_TARGET_PACKAGE)
	$(hide) $(SHA256) $(BLACKIRON_TARGET_PACKAGE) | sed "s|$(PRODUCT_OUT)/||" > $(BLACKIRON_TARGET_PACKAGE).sha256sum
	@echo ""
	@echo "                                                               " >&2
	@echo "                                                               " >&2
	@echo "                                                               " >&2
	@echo "                                                               " >&2
	@echo "  ____  __    ___    ___ __ __    __ ____    ___   __  __      " >&2
	@echo " || )) ||    // \\  //   || //    || || \\  // \\  ||\ ||      " >&2
	@echo " ||=)  ||    ||=|| ((    ||<<     || ||_// ((   )) ||\\||      " >&2
	@echo " ||_)) ||__| || ||  \\__ || \\    || || \\  \\_//  || \||      " >&2
	@echo "                                                               " >&2
	@echo "                                                               " >&2
	@echo "                                                               " >&2
	@echo "                                                               " >&2
	@echo "                                                               " >&2
	@echo "                                                               " >&2
	@echo ""
	@echo "Creating json OTA..." >&2
	$(hide) ./vendor/blackiron/build/tools/createjson.sh $(TARGET_DEVICE) $(PRODUCT_OUT) Blackiron-$(BLACKIRON_BUILD_VERSION)-ota.zip $(BLACKIRON_VERSION) $(BLACKIRON_CODENAME) $(BLACKIRON_PACKAGE_TYPE) $(BLACKIRON_RELEASE_TYPE)
	$(hide) cp -f $(PRODUCT_OUT)/$(BLACKIRON_PACKAGE_TYPE)_$(TARGET_DEVICE).json OTA/$(BLACKIRON_PACKAGE_TYPE)_$(TARGET_DEVICE).json
	@echo ":·.·.·::·.·.·::·.·.·::·.·.·::·.·.·::·.·.·::·.·.·::·.·.·::·.·.·:" >&2
	@echo " Size            : $(shell du -hs $(BLACKIRON_TARGET_PACKAGE) | awk '{print $$1}')"
	@echo " Size(in bytes)  : $(shell wc -c $(BLACKIRON_TARGET_PACKAGE) | awk '{print $$1}')"
	@echo " Package Complete: $(BLACKIRON_TARGET_PACKAGE)" >&2
	@echo ":·.·.·::·.·.·::·.·.·::·.·.·::·.·.·::·.·.·::·.·.·::·.·.·::·.·.·:" >&2
	@echo ""
