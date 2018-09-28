include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:9.0

BUNDLE_NAME = ToneManagerSettings
ToneManagerSettings_FILES = JFTMRootListController.m ToneManagerTitleCell.m
ToneManagerSettings_INSTALL_PATH = /Library/PreferenceBundles
ToneManagerSettings_FRAMEWORKS = UIKit
ToneManagerSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ToneManagerSettings.plist$(ECHO_END)
