# libs-uikit

`libs-uikit` is a GNUstep Objective-C library that provides a UIKit-like API on
top of GNUstep Base and GUI. It is intended for code that wants familiar UIKit
class names and application structure while running in a GNUstep/AppKit
environment.

The library currently exposes a focused subset of UIKit-style classes including
application/window management, views and view controllers, common controls,
table/navigation/tab containers, images, colors, fonts, nib loading helpers, and
basic device/screen abstractions.

The 0.1 desktop core candidate adds tested navigation, forms, viewport-based lists,
basic touch/gesture handling, and a runnable catalog. It remains an AppKit-backed
UIKit subset. See [the milestone scope and release gates](RELEASE-MILESTONE-1.md)
for tested behavior, build/test commands, and explicit compatibility limits.

## AI Disclosure

AI was used for some of the concepts of this library.  Particularly the repetative
coding parts.

## Contents

- `Headers/UIKit/` - public headers and the umbrella `UIKit.h` header.
- `Source/` - Objective-C implementation files and the library makefile.
- `Examples/` - a small `UIKitExample` GNUstep application using a xib file.
- `COPYING.LIB` - GNU Lesser General Public License text.

## Requirements

- GNUstep Make
- GNUstep Base
- GNUstep GUI
- Objective-C compiler supported by GNUstep

`GNUSTEP_MAKEFILES` must be available. If it is not already exported by your
environment, the top-level makefile tries to discover it with:

```sh
gnustep-config --variable=GNUSTEP_MAKEFILES
```

## Building

From the repository root:

```sh
make
```

The top-level build includes both subprojects:

- `Source` builds the `libs-uikit` shared library.
- `Examples` builds `UIKitExample` and `UIKitCoreCatalog`. The OpenGL example is
  opt-in with `UIKIT_BUILD_OPENGL_EXAMPLE=yes`.

To build only the library:

```sh
make -C Source
```

To build only the example application:

```sh
make -C Examples
```

## Building For Android

The Android build uses the NDK CMake toolchain and builds the library target
only. It expects GNUstep Base, GNUstep GUI, and libobjc to already be built for
the same Android ABI and available in one prefix.

```sh
cmake -S . -B build-android \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-24 \
  -DGNUSTEP_ANDROID_ROOT=/path/to/android-gnustep-prefix

cmake --build build-android
```

`GNUSTEP_ANDROID_ROOT` should contain GNUstep headers under either
`include/GNUstep` or `include`, and Android ABI libraries under either `lib` or
`lib/<abi>`. If your Objective-C runtime is not libobjc2's GNUstep 2.0 runtime,
override `UIKIT_ANDROID_OBJC_RUNTIME`.

## Running The Example

After building, run the example application from the `Examples` directory using
the normal GNUstep application launch method for your environment. The example
creates a `UIWindow`, loads `MainView.xib` through an `ExampleViewController`,
and demonstrates labels, text fields, sliders, switches, buttons, and control
events.

## Using The Library

Import the umbrella header:

```objc
#import <UIKit/UIKit.h>
```

Applications use the familiar UIKit-style entry point:

```objc
int main(int argc, char **argv)
{
  return UIApplicationMain(argc, argv, nil, @"ExampleAppDelegate");
}
```

The public API is intentionally modeled around UIKit names, but the underlying
types are GNUstep/AppKit types. For example, `CGPoint`, `CGSize`, and `CGRect`
are typedefs for `NSPoint`, `NSSize`, and `NSRect`.

## Implemented Public Headers

- `UIApplication`, `UIResponder`, `UIScreen`, `UIDevice`
- `UIView`, `UIWindow`, `UIViewController`
- `UIColor`, `UIImage`, `UIFont`
- `UILabel`, `UIImageView`
- `UIControl`, `UIButton`, `UITextField`, `UITextView`
- `UISlider`, `UISwitch`, `UISegmentedControl`, `UIScrollView`
- `UITableView`, `UITableViewCell`, `NSIndexPath+UIKit`
- `UINavigationItem`, `UINavigationController`, `UITabBarController`
- `UIActivityIndicatorView`, `UIAlertView`
- `UINib`, `NSBundle+UIKit`

## License

This project is distributed under the GNU Lesser General Public License. See
`COPYING.LIB` for the full license text.

## Core tests and catalog

See [RELEASE-MILESTONE-1.md](RELEASE-MILESTONE-1.md) for the coverage matrix.
With a configured GNUstep environment, `make test` runs the regression suite.
For a headless Linux run use `xvfb-run -a make test`. A CMake build also provides
`UIKitCoreCatalog` and two CTest entries, including a catalog smoke test.
