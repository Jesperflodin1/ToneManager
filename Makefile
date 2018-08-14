include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:8.0
#export TARGET = simulator:clang::8.0
#ARCHS = x86_64
ARCHS = arm64

DEBUG = 1
FINALPACKAGE = 0

TWEAK_NAME = ToneHelper
ToneHelper_FILES = Tweak.xm JFTHRingtoneImporter.m $(wildcard JGProgressHUD/*.m)

ToneHelper_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

ToneHelper_FRAMEWORKS = UIKit QuartzCore MobileCoreServices
ToneHelper_PRIVATEFRAMEWORKS = ToneKit FrontBoard
ToneHelper_EXTRA_FRAMEWORKS += cephei

include $(THEOS_MAKE_PATH)/tweak.mk


SUBPROJECTS += thprefsbundle
include $(THEOS_MAKE_PATH)/aggregate.mk

ifneq (,$(filter x86_64 i386,$(ARCHS)))
setup:: clean all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v /Users/jesper/Documents/Projects/Tweaks/$(TWEAK_NAME)/.theos/obj/iphone_simulator/debug/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
endif
