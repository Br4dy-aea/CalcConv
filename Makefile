ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:13.0
INSTALL_TARGET_PROCESSES = Calculator




THEOS_DEVICE_IP = 192.168.40.220

PACKAGE_VERSION = 2.55


# Disable Logos warnings as errors
export THEOS_LOGOSFLAGS = -Wno-error

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = calcconv14
calcconv14_FILES = Tweak.xm
calcconv14_CFLAGS = -fobjc-arc
calcconv14_LDFLAGS = -lsqlite3 -lz


include $(THEOS_MAKE_PATH)/tweak.mk
