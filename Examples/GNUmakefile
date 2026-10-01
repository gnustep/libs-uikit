ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = UIKitExample UIKitCoreCatalog UIKitStudio
ifeq ($(UIKIT_BUILD_OPENGL_EXAMPLE),yes)
APP_NAME += OpenGLExample
endif
ADDITIONAL_OBJCFLAGS += -std=gnu11
ADDITIONAL_LIB_DIRS += -L../Source/obj
ifneq ($(GNUSTEP_TARGET_OS),darwin)
ADDITIONAL_LDFLAGS += -Wl,-rpath,$(CURDIR)/../Source/obj
endif

UIKitStudio_OBJC_FILES = UIKitStudio/main.m UIKitStudio/StudioApp.m
UIKitStudio_OBJCFLAGS = -I../Headers
UIKitStudio_GUI_LIBS = -ls-uikit

UIKitCoreCatalog_OBJC_FILES = CoreCatalog.m
UIKitCoreCatalog_OBJCFLAGS = -I../Headers
UIKitCoreCatalog_GUI_LIBS = -ls-uikit

UIKitExample_OBJC_FILES = main.m
UIKitExample_RESOURCE_FILES = MainView.xib
UIKitExample_OBJCFLAGS = -I../Headers
UIKitExample_GUI_LIBS = -ls-uikit

OpenGLExample_OBJC_FILES = OpenGLExample.m
OpenGLExample_OBJCFLAGS = -I../Headers
OpenGLExample_GUI_LIBS = -ls-uikit -lGL

include $(GNUSTEP_MAKEFILES)/application.make
