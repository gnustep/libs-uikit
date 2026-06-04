include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = UIKitExample OpenGLExample

UIKitExample_OBJC_FILES = main.m
UIKitExample_RESOURCE_FILES = MainView.xib
UIKitExample_OBJCFLAGS = -I../Headers
UIKitExample_GUI_LIBS = ../Source/obj/libs-uikit.so.0.0.1

OpenGLExample_OBJC_FILES = OpenGLExample.m
OpenGLExample_OBJCFLAGS = -I../Headers
OpenGLExample_GUI_LIBS = ../Source/obj/libs-uikit.so.0.0.1 -lGL

include $(GNUSTEP_MAKEFILES)/application.make
