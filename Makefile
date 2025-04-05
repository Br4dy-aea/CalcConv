ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Calculator

THEOS_DEVICE_IP = 192.168.40.209

PACKAGE_VERSION = 5.0

# Disable Logos warnings as errors
export THEOS_LOGOSFLAGS = -Wno-error

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = calcconv
calcconv_FILES = Tweak.xm
calcconv_CFLAGS = -fobjc-arc
calcconv_LDFLAGS = -lsqlite3 -lz

include $(THEOS_MAKE_PATH)/tweak.mk
