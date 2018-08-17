include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:8.0
ARCHS = arm64

BUNDLE_NAME = THPrefsBundle
THPrefsBundle_FILES = $(wildcard *.m)
THPrefsBundle_INSTALL_PATH = /Library/PreferenceBundles
THPrefsBundle_FRAMEWORKS = UIKit
THPrefsBundle_PRIVATE_FRAMEWORKS = Preferences
THPrefsBundle_EXTRA_FRAMEWORKS += cephei cepheiprefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/THPrefsBundle.plist$(ECHO_END)
