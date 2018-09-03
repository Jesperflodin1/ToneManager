#GO_EASY_ON_ME=1

include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:8.0
#export TARGET = simulator:clang::8.0
#ARCHS = x86_64
ARCHS = arm64 armv7

DEBUG = 1
FINALPACKAGE = 0

APPLICATION_NAME = ToneManager
ToneManager_FILES = $(wildcard *.swift)
#ToneManager_FILES = $(wildcard *.mm) $(wildcard *.m) $(wildcard CocoaLumberjack/*.m) $(wildcard LogglyLogger/*.m)
ToneManager_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
ToneManager_CODESIGN_FLAGS = -Sentitlements.xml

ToneManager_FRAMEWORKS = MobileCoreServices AVFoundation UIKit CoreGraphics
ToneManager_PRIVATEFRAMEWORKS = ToneLibrary FrontBoard
ToneManager_EXTRA_FRAMEWORKS += cephei

include $(THEOS_MAKE_PATH)/application.mk


after-install::
	install.exec "killall \"ToneManager\"" || true
