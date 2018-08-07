include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:11.0
ARCHS = arm64

DEBUG = 1
FINALPACKAGE = 0

TWEAK_NAME = ToneHelper
ToneHelper_FILES = Tweak.xm

ToneHelper_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk


