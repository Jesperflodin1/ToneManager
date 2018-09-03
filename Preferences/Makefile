include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:8.0
ARCHS = arm64

BUNDLE_NAME = TMPreferences
TMPreferences_FILES = $(wildcard *.m) $(wildcard *.x)
TMPreferences_INSTALL_PATH = /Library/PreferenceBundles
#TMPreferences_FRAMEWORKS = UIKit MessageUI
TMPreferences_PRIVATE_FRAMEWORKS = Preferences
TMPreferences_EXTRA_FRAMEWORKS += cephei cepheiprefs

TMPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/THPrefsBundle.plist$(ECHO_END)
