include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:11.0
ARCHS = arm64

TOOL_NAME = tonehelperd
tonehelperd_FILES = main.mm tonehelperd.m

ToneHelper_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk
