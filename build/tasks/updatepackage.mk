# Copyright (C) 2022 PixysOS Project
# Copyright (C) 2023 Blackiron Project
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
# Blackiron fastboot update package

BLACKIRON_TARGET_UPDATEPACKAGE := $(PRODUCT_OUT)/Blackiron-$(BLACKIRON_BUILD_VERSION)-fastboot.zip

.PHONY: updatepackage dinner
updatepackage: $(DEFAULT_GOAL) $(INTERNAL_UPDATE_PACKAGE_TARGET)
	$(hide) ln -f $(INTERNAL_UPDATE_PACKAGE_TARGET) $(BLACKIRON_TARGET_UPDATEPACKAGE)
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
	@echo "****************************************************************" >&2
	@echo " Size            : $(shell du -hs $(BLACKIRON_TARGET_UPDATEPACKAGE) | awk '{print $$1}')"
	@echo " Size(in bytes)  : $(shell wc -c $(BLACKIRON_TARGET_UPDATEPACKAGE) | awk '{print $$1}')"
	@echo " Package Complete: $(BLACKIRON_TARGET_UPDATEPACKAGE)               " >&2
	@echo "****************************************************************" >&2
	@echo ""
dinner: updatepackage
