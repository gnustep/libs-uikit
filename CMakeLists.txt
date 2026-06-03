cmake_minimum_required(VERSION 3.21)

project(libs-uikit LANGUAGES OBJC)

if(NOT ANDROID)
  message(WARNING "This CMake build is intended for the Android NDK toolchain.")
endif()

set(GNUSTEP_ANDROID_ROOT "" CACHE PATH
  "Prefix containing Android-built GNUstep Base, GNUstep GUI, and libobjc2")
set(UIKIT_ANDROID_OBJC_RUNTIME "gnustep-2.0" CACHE STRING
  "Objective-C runtime name passed to clang with -fobjc-runtime")

set(_gnustep_roots
  "${GNUSTEP_ANDROID_ROOT}"
  "$ENV{GNUSTEP_ANDROID_ROOT}"
  ${CMAKE_PREFIX_PATH}
)

if(ANDROID)
  foreach(_gnustep_root IN LISTS _gnustep_roots)
    if(_gnustep_root)
      list(APPEND CMAKE_FIND_ROOT_PATH "${_gnustep_root}")
    endif()
  endforeach()
endif()

find_path(GNUSTEP_BASE_INCLUDE_DIR
  NAMES Foundation/Foundation.h
  HINTS ${_gnustep_roots}
  PATH_SUFFIXES include/GNUstep include
)

find_path(GNUSTEP_GUI_INCLUDE_DIR
  NAMES AppKit/AppKit.h
  HINTS ${_gnustep_roots}
  PATH_SUFFIXES include/GNUstep include
)

find_library(GNUSTEP_BASE_LIBRARY
  NAMES gnustep-base
  HINTS ${_gnustep_roots}
  PATH_SUFFIXES lib lib/${ANDROID_ABI}
)

find_library(GNUSTEP_GUI_LIBRARY
  NAMES gnustep-gui
  HINTS ${_gnustep_roots}
  PATH_SUFFIXES lib lib/${ANDROID_ABI}
)

find_library(OBJC_LIBRARY
  NAMES objc
  HINTS ${_gnustep_roots}
  PATH_SUFFIXES lib lib/${ANDROID_ABI}
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GNUstepAndroid
  REQUIRED_VARS
    GNUSTEP_BASE_INCLUDE_DIR
    GNUSTEP_GUI_INCLUDE_DIR
    GNUSTEP_BASE_LIBRARY
    GNUSTEP_GUI_LIBRARY
    OBJC_LIBRARY
)

if(NOT GNUstepAndroid_FOUND)
  message(FATAL_ERROR
    "Set GNUSTEP_ANDROID_ROOT or CMAKE_PREFIX_PATH to an Android-built "
    "GNUstep prefix containing Foundation, AppKit, gnustep-base, "
    "gnustep-gui, and libobjc.")
endif()

add_library(libs-uikit SHARED
  Source/UIResponder.m
  Source/UIApplication.m
  Source/UIView.m
  Source/UIWindow.m
  Source/UIViewController.m
  Source/UIColor.m
  Source/UIImage.m
  Source/UIFont.m
  Source/UILabel.m
  Source/UIImageView.m
  Source/UIControl.m
  Source/UIButton.m
  Source/UITextField.m
  Source/UITextView.m
  Source/UISlider.m
  Source/UISwitch.m
  Source/UISegmentedControl.m
  Source/UIScrollView.m
  Source/UITableViewCell.m
  Source/NSIndexPath+UIKit.m
  Source/UITableView.m
  Source/UINavigationItem.m
  Source/UINavigationController.m
  Source/UITabBarController.m
  Source/UIActivityIndicatorView.m
  Source/UIAlertView.m
  Source/UIScreen.m
  Source/UIDevice.m
  Source/UINib.m
  Source/NSBundle+UIKit.m
)

target_include_directories(libs-uikit
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Headers>
    $<BUILD_INTERFACE:${GNUSTEP_BASE_INCLUDE_DIR}>
    $<BUILD_INTERFACE:${GNUSTEP_GUI_INCLUDE_DIR}>
    $<INSTALL_INTERFACE:include>
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/Source
)

target_compile_options(libs-uikit PRIVATE
  -Wall
  -Wextra
  -fobjc-exceptions
  -fconstant-string-class=NSConstantString
  -fobjc-runtime=${UIKIT_ANDROID_OBJC_RUNTIME}
)

target_link_options(libs-uikit PRIVATE
  -fobjc-runtime=${UIKIT_ANDROID_OBJC_RUNTIME}
  -Wl,--no-undefined
)

target_link_libraries(libs-uikit PRIVATE
  ${GNUSTEP_GUI_LIBRARY}
  ${GNUSTEP_BASE_LIBRARY}
  ${OBJC_LIBRARY}
)

install(TARGETS libs-uikit
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(DIRECTORY Headers/UIKit
  DESTINATION include
  FILES_MATCHING PATTERN "*.h"
)
