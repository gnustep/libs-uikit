cmake_minimum_required(VERSION 3.21)

project(libs-uikit VERSION 0.2.0 LANGUAGES C OBJC)

if(ANDROID)

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

else()
  find_program(GNUSTEP_CONFIG gnustep-config REQUIRED)
  execute_process(COMMAND ${GNUSTEP_CONFIG} --objc-flags
    OUTPUT_VARIABLE GNUSTEP_OBJC_FLAGS OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
  execute_process(COMMAND ${GNUSTEP_CONFIG} --gui-libs
    OUTPUT_VARIABLE GNUSTEP_GUI_FLAGS OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
  separate_arguments(GNUSTEP_OBJC_FLAGS UNIX_COMMAND "${GNUSTEP_OBJC_FLAGS}")
  separate_arguments(GNUSTEP_GUI_FLAGS UNIX_COMMAND "${GNUSTEP_GUI_FLAGS}")
  list(REMOVE_ITEM GNUSTEP_OBJC_FLAGS -MMD -MP)
  # Clang on distributions using GCC's Objective-C runtime needs its headers.
  execute_process(COMMAND gcc -print-file-name=include
    OUTPUT_VARIABLE GNUSTEP_OBJC_INCLUDE OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

# Keep both build systems on one explicit source inventory.
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/Source/Sources.list" UIKIT_SOURCE_NAMES)
set(UIKIT_SOURCES)
foreach(source IN LISTS UIKIT_SOURCE_NAMES)
  list(APPEND UIKIT_SOURCES "Source/${source}")
endforeach()
add_library(UIKit SHARED ${UIKIT_SOURCES})
set_target_properties(UIKit PROPERTIES OUTPUT_NAME UIKit VERSION ${PROJECT_VERSION} SOVERSION 1)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/Source/Sources.list")

target_compile_options(UIKit PRIVATE -std=gnu11)
target_include_directories(UIKit PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Headers>
  $<INSTALL_INTERFACE:include>
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Source)
if(ANDROID)
  target_include_directories(UIKit PUBLIC ${GNUSTEP_BASE_INCLUDE_DIR} ${GNUSTEP_GUI_INCLUDE_DIR})
  target_compile_options(UIKit PRIVATE -Wall -Wextra -fobjc-exceptions
    -fconstant-string-class=NSConstantString -fobjc-runtime=${UIKIT_ANDROID_OBJC_RUNTIME})
  target_link_options(UIKit PRIVATE -fobjc-runtime=${UIKIT_ANDROID_OBJC_RUNTIME} -Wl,--no-undefined)
  target_link_libraries(UIKit PRIVATE ${GNUSTEP_GUI_LIBRARY} ${GNUSTEP_BASE_LIBRARY} ${OBJC_LIBRARY})
else()
  target_include_directories(UIKit PUBLIC ${GNUSTEP_OBJC_INCLUDE})
  target_compile_options(UIKit PUBLIC ${GNUSTEP_OBJC_FLAGS})
  target_link_libraries(UIKit PUBLIC ${GNUSTEP_GUI_FLAGS})
  add_executable(UIKitCoreCatalog Examples/CoreCatalog.m)
  target_link_libraries(UIKitCoreCatalog PRIVATE UIKit)
  target_link_options(UIKitCoreCatalog PRIVATE "-Wl,-rpath,$<TARGET_FILE_DIR:UIKit>")
  add_executable(UIKitStudio Examples/UIKitStudio/main.m Examples/UIKitStudio/StudioApp.m)
  target_link_libraries(UIKitStudio PRIVATE UIKit)
  target_link_options(UIKitStudio PRIVATE "-Wl,-rpath,$<TARGET_FILE_DIR:UIKit>")
  include(CTest)
  if(BUILD_TESTING)
    add_executable(UIKitStudioCapture Tests/StudioCapture.m Examples/UIKitStudio/StudioApp.m)
    target_link_libraries(UIKitStudioCapture PRIVATE UIKit)
    target_link_options(UIKitStudioCapture PRIVATE "-Wl,-rpath,$<TARGET_FILE_DIR:UIKit>")
    add_executable(UIKitCoreTests Tests/CoreTests.m Tests/UIKitContract.m Tests/LayoutTests.m Tests/EditingAndControllerTests.m)
    target_link_libraries(UIKitCoreTests PRIVATE UIKit)
    target_link_options(UIKitCoreTests PRIVATE "-Wl,-rpath,$<TARGET_FILE_DIR:UIKit>")
    add_test(NAME UIKitCore COMMAND UIKitCoreTests)
    add_test(NAME UIKitStudio COMMAND UIKitStudio --smoke)
    set_tests_properties(UIKitStudio PROPERTIES TIMEOUT 60)
    add_test(NAME UIKitCatalog COMMAND UIKitCoreCatalog --smoke)
    set_tests_properties(UIKitCatalog PROPERTIES TIMEOUT 30)
    set_tests_properties(UIKitCore PROPERTIES WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" TIMEOUT 60)
  endif()
endif()

install(TARGETS UIKit
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(DIRECTORY Headers/UIKit
  DESTINATION include
  FILES_MATCHING PATTERN "*.h"
)
