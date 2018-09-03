include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:8.0
#export TARGET = simulator:clang::8.0
#ARCHS = x86_64
ARCHS = arm64

DEBUG = 1
FINALPACKAGE = 0

TWEAK_NAME = ToneManager
ToneManager_FILES = Tweak.xm $(wildcard *.mm) $(wildcard *.m) $(wildcard CocoaLumberjack/*.m) $(wildcard LogglyLogger/*.m) 

ToneManager_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

Tweak.xm_CFLAGS = -fno-objc-arc

ToneManager_FRAMEWORKS = MobileCoreServices AVFoundation
ToneManager_PRIVATEFRAMEWORKS = ToneLibrary FrontBoard
ToneManager_EXTRA_FRAMEWORKS += cephei

include $(THEOS_MAKE_PATH)/tweak.mk


#SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk

#after-install::
#	install.exec "killall -9 SpringBoard"

ifneq (,$(filter x86_64 i386,$(ARCHS)))
setup:: clean all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v /Users/jesper/Documents/Projects/Tweaks/$(TWEAK_NAME)/.theos/obj/iphone_simulator/debug/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
endif
