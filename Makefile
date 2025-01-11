ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
    TARGET = iphone:clang:latest:15.0
else
    TARGET = iphone:clang:14.5:7.0
    export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
endif
PACKAGE_VERSION = 1.3.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CAHighFPS

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
