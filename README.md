# libs-uikit

`libs-uikit` is an Objective-C UIKit compatibility layer for GNUstep. It provides
UIKit objects backed by private AppKit peers, including native controls, windows,
menus, file panels, layout, and input handling.

The goal is **unchanged Objective-C application source** across Apple UIKit and
GNUstep UIKit. Applications import `<UIKit/UIKit.h>` and must be rebuilt for the
target platform. The implementation remains a subset of UIKit; headers and live
examples do not imply complete API or behavioral compatibility.

The framework is at **0.2.0**, with library interface version **1**. Applications
built against the former NSView/NSWindow-based adapter must be rebuilt.
`UIResponder` inherits `NSObject`, `UIView` inherits `UIResponder`, and `UIWindow`
inherits `UIView`. Ordinary public headers do not import AppKit.

See [SOURCE-COMPATIBILITY.md](SOURCE-COMPATIBILITY.md) for the compatibility
contract and current limits, [UIKit-Gaps.md](UIKit-Gaps.md) for layout details,
and [RELEASE-MILESTONE-1.md](RELEASE-MILESTONE-1.md) for the original desktop core
coverage matrix.

## Current coverage

The following areas have working implementations, with the limits described below.

| Area | Supported examples and behavior |
| --- | --- |
| Application and windows | Application entry point, responders, windows, basic scenes, screen/device information, controller containment and presentation |
| Layout and resources | Autoresizing, constraint anchors, layout guides, scroll content/frame guides, stack views, XML XIB loading with outlets, actions and constraints |
| Controls and text | Labels, buttons, text fields/views, switches, sliders, steppers, segmented controls, progress/activity indicators, color wells, paste controls and clipboard text |
| Search and pickers | Search bars/controllers, standalone search text fields, option/date/calendar pickers, page controls, color and font pickers |
| Lists and content | Tables, reusable cells, collection views and flow layout, subtitle/image rows, automatic table row sizing, list content configurations, collection list cells, header/footer views and content-unavailable views |
| Navigation and containers | Navigation items and bar buttons, navigation/tool/tab bars, navigation/tab controllers, programmatic page replacement and split columns |
| Menus and alerts | Button menus, context menus, edit menus, action blocks, responder-chain commands, alerts, and a text-copy activity interface |
| System interfaces | Document picker/browser file selection, image-file selection, dictionary lookup and basic text formatting |
| Effects | Visual-effect views, glass backdrop approximations, interactive glass highlighting and background extension |
| Interaction | Tap, pan, long-press and swipe gestures; hover, pointer cursors, tooltips, and text drag and drop |

The companion **UIKitTest** project, maintained outside this repository, now has
**73 live catalog entries**, including 24 additions for controls, content views,
menus, system interfaces, effects and pointer/drag interactions. Open its
**Widgets → Live widgets** catalog and search by class name. That companion
catalog is separate from the bundled `UIKitCoreCatalog` example.

## Desktop screen size

On desktop platforms, `UIScreen.mainScreen.bounds` defaults to
**`(0, 0, 1366, 1024)`**: a large iPad's landscape size in logical points. An app
that creates its initial window from those bounds therefore starts with that
size rather than the desktop display's full dimensions.

Set `GSUIKitUseFullScreenSize` to `YES` to report the native `NSScreen` frame.
For all GNUstep UIKit applications:

```sh
defaults write NSGlobalDomain GSUIKitUseFullScreenSize YES
```

Restore the iPad-sized default:

```sh
defaults write NSGlobalDomain GSUIKitUseFullScreenSize NO
```

An unset preference behaves like `NO`. Applications can also set the preference
in their own defaults domain. The preference changes the reported bounds; it does
not resize existing windows, change the monitor's resolution, or request a desktop
full-screen window mode. Relaunch an application to recreate its initial window.
Android continues to report its native screen bounds.

## Requirements

- GNUstep Make, Base and GUI, with a working GUI backend.
- Clang and a compatible Objective-C runtime/Foundation build. The expanded
  examples use blocks for menu actions and completion handlers.
- A configured GNUstep environment with `gnustep-config` on `PATH`.
- CMake 3.21 or later for the CMake build.
- Xvfb for headless Linux GUI tests.

The GNUmake build discovers `GNUSTEP_MAKEFILES` through
`gnustep-config --variable=GNUSTEP_MAKEFILES` when it is not already set.

## Build and install

### GNUmake

From the repository root:

```sh
make
```

This builds `UIKit.framework` and the `UIKitExample`, `UIKitCoreCatalog`, and
`UIKitStudio` applications. To build and install only the framework:

```sh
make -C Source
make -C Source install
```

Installation uses the configured GNUstep installation domain and may require
administrator privileges. Install matching headers and the library together;
applications using new APIs need both. On Linux, the framework contains
`libUIKit.so`, and applications link with `-lUIKit`.

After building the framework, the examples can be built separately:

```sh
make -C Examples
```

The OpenGL example is optional:

```sh
make UIKIT_BUILD_OPENGL_EXAMPLE=yes
```

### CMake

```sh
cmake -S . -B build -DCMAKE_OBJC_COMPILER=clang -DBUILD_TESTING=ON
cmake --build build
```

CMake builds a standalone shared library, `UIKitCoreCatalog`, `UIKitStudio`, and
the test targets. To install the library and public headers into a chosen prefix:

```sh
cmake --install build --prefix /path/to/install-prefix
```

When several UIKit builds are installed, ensure the application's include paths,
linker paths and runtime library search path select the intended version.

## Examples

| Example | Purpose | GNUmake launch command |
| --- | --- | --- |
| `UIKitExample` | Loads `MainView.xib` and demonstrates basic controls and target/action events | `openapp Examples/UIKitExample.app` |
| `UIKitCoreCatalog` | Desktop directory, editor, gallery and drawing/input examples | `openapp Examples/UIKitCoreCatalog.app` |
| `UIKitStudio` | Shared-source Compose, Library and Palette screens | `openapp Examples/UIKitStudio.app` |

For a CMake build, launch `./build/UIKitCoreCatalog` or `./build/UIKitStudio`.

[UIKit Studio](Examples/UIKitStudio/README.md) builds the same Objective-C
application files against Apple UIKit for the iOS Simulator and this GNUstep
implementation. Its documentation covers the Xcode project, simulator launcher,
interaction smoke checks and screenshot host.

## Using the framework

Import the public umbrella header and use the UIKit application entry point:

```objc
#import <UIKit/UIKit.h>

int main(int argc, char **argv)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int result = UIApplicationMain(argc, argv, nil, @"ExampleAppDelegate");
    [pool drain];
    return result;
}
```

Geometry currently uses GNUstep Foundation types: `CGPoint`, `CGSize` and
`CGRect` are aliases for `NSPoint`, `NSSize` and `NSRect`. Backend integration and
test hosts can explicitly import `<UIKit/GNUstepUIKit.h>`; ordinary application
code should use `<UIKit/UIKit.h>`.

## Tests and validation

Run the core regressions and standalone public-header checks:

```sh
make test
./Tests/check-headers.sh
```

Without a desktop display:

```sh
xvfb-run -a make test
```

CMake registers **three CTest suites**: `UIKitCore`, `UIKitStudio` and
`UIKitCatalog`. On Linux, the following also ensures tests load the library from
this build even if an older UIKit is installed:

```sh
LD_LIBRARY_PATH="$PWD/build${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
  xvfb-run -a ctest --test-dir build --output-on-failure
```

Coverage includes view/controller lifetimes, responder routing, constraints,
XIB loading, text editing, reusable lists, navigation/search, native picker
callbacks, clipboard insertion, content configuration replacement, menu actions,
formatting, hover, tooltip attachment and native text drops. Screen-size checks
cover an unset `GSUIKitUseFullScreenSize` preference and explicit `YES`/`NO` values
without changing persistent user preferences.

Recent desktop validation passed all three CTest suites and a clean build of the
companion UIKitTest app against the installed framework. Separate integration
checks rendered all 73 catalog entries and opened their controller examples;
mouse checks exercised menu selection, command routing, text dragging and hover.
These checks do not establish full UIKit conformance or validate all new examples
on Apple platforms.

## Implementation limits

- **Resources and layout:** XML XIB loading and constraint layout cover a subset.
  Compiled iOS nibs, storyboard graphs, asset catalogs, traits and full decoding
  are not implemented.
- **Presentation and rendering:** controllers present in desktop windows. UIKit
  transition animations, full popover behavior, Core Animation, Dynamic Type and
  native accessibility bridging remain incomplete. `UIView.layer` is a drawing
  bridge, not `CALayer`.
- **Menus and pointer input:** context menus open on right-click. Context previews,
  touch context-menu gestures and custom pointer regions/styles are not covered.
  The desktop mouse backend does not generate multitouch pinch/rotation input.
- **Document and image interfaces:** native file panels return file URLs or decoded
  images. Document-provider/cloud coordination, security-scoped access, document
  export and camera capture are not implemented. Import mode currently returns
  the selected URL without making a sandbox copy.
- **Dictionary and formatting:** lookup uses a small offline technical glossary,
  extensible through an application's `UIKitDictionary.plist`. Formatting supports
  point size and bold face, not the full system formatting interface.
- **Effects:** ordinary blur styles use translucent fills. Glass softens sibling
  snapshots and adds tint/highlighting; background extension stretches softened
  content. These approximate the appearance without Apple's compositor or animated
  glass merging. Glass-container spacing is currently metadata.
- **Drag and drop:** local strings and native clipboard text are supported.
  General `NSItemProvider` loading is unavailable in the current GNUstep Base
  implementation; the desktop demo uses `UIDragItem.localObject`. Other payloads
  and drop previews are not implemented.

Consult [SOURCE-COMPATIBILITY.md](SOURCE-COMPATIBILITY.md) for further limits on
list styles, sizing, search presentation, scrolling, images and controller behavior.

## Android build

The Android configuration builds the library using the NDK CMake toolchain. It
requires GNUstep Base, GNUstep GUI and libobjc already built for the same ABI:

```sh
cmake -S . -B build-android \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-24 \
  -DGNUSTEP_ANDROID_ROOT=/path/to/android-gnustep-prefix

cmake --build build-android
```

The prefix should contain headers under `include/GNUstep` or `include`, and
libraries under `lib` or `lib/<abi>`. Override `UIKIT_ANDROID_OBJC_RUNTIME` if the
runtime differs from the default `gnustep-2.0`. Desktop validation described above
does not establish Android runtime coverage for the new interfaces.

## Repository layout

- `Headers/UIKit/`: public headers and the UIKit umbrella header.
- `Source/`: implementation, framework makefile and shared `Sources.list` inventory.
- `Examples/`: XIB example, Core Catalog, UIKit Studio and optional OpenGL example.
- `Tests/`: contract, layout, editing, playground and catalog regressions, header
  checks and screenshot support.
- `uikit.make`: GNUstep makefile integration helper.
- `COPYING.LIB`: GNU Lesser General Public License text.

## AI disclosure

AI assisted with portions of the library's design, implementation, tests and
documentation, including repetitive coding tasks.

## License

This project is distributed under the GNU Lesser General Public License.
See [COPYING.LIB](COPYING.LIB) for the full license text.
