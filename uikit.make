# -*-makefile-*-
#   uikit.make
#
#   Makefile flags and configs to build with the GNUstep UIKit library.

ifeq ($(UIKIT_MAKE_LOADED),)
UIKIT_MAKE_LOADED=yes

ifeq ($(GUI_LIB),gnu)

  GNUSTEP_UIKIT_VERSION = 0.0.1
  GNUSTEP_UIKIT_MAJOR_VERSION = 0
  GNUSTEP_UIKIT_MINOR_VERSION = 0
  GNUSTEP_UIKIT_SUBMINOR_VERSION = 1

  UIKIT_LDFLAGS =
  UIKIT_LIBS = -luikit $(GUI_LIBS)
  UIKIT_DEFINE = -DGNUSTEP_UIKIT_LIBRARY=1
  GNUSTEP_DEFINE = -DGNUSTEP

endif

endif # UIKIT_MAKE_LOADED
