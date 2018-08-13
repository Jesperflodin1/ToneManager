include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:11.0
ARCHS = arm64

DEBUG = 1
FINALPACKAGE = 0

TWEAK_NAME = ToneHelper
ToneHelper_FILES = Tweak.xm $(wildcard JGProgressHUD/*.m)

ToneHelper_CFLAGS = -fobjc-arc

ToneHelper_FRAMEWORKS = UIKit QuartzCore MobileCoreServices
ToneHelper_PRIVATEFRAMEWORKS = ToneKit FrontBoard

include $(THEOS_MAKE_PATH)/tweak.mk


SUBPROJECTS += thprefsbundle
include $(THEOS_MAKE_PATH)/aggregate.mk
