# libs-uikit

`libs-uikit` implements a growing Objective-C UIKit compatibility layer on GNUstep.
The target is **zero application source changes**: compatibility work belongs in
this framework and its build/resource tooling. Applications must be rebuilt for
the target platform; this is not an iOS binary loader.

The 0.2 development version separates UIKit objects from private AppKit peers.
`UIResponder` inherits `NSObject`, `UIView` inherits `UIResponder`, and `UIWindow`
inherits `UIView`. Ordinary applications import `<UIKit/UIKit.h>` without AppKit.
The supported implementation is still a subset; arbitrary iPhone applications
cannot yet be expected to run unchanged. See [the compatibility contract and
remaining gates](SOURCE-COMPATIBILITY.md) and [tested coverage](RELEASE-MILESTONE-1.md).

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
- `Examples` builds `UIKitExample`, `UIKitCoreCatalog`, and `UIKitStudio`. The OpenGL example is
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

## Shared-source graphical demo

[UIKit Studio](Examples/UIKitStudio/README.md) provides an interactive editor,
reusable list, and color gallery. Its application files compile unchanged against
Apple UIKit for the iOS Simulator and this GNUstep implementation. Open
`Examples/UIKitStudio/UIKitStudio.xcodeproj` in Xcode, or build the `UIKitStudio`
target with GNUmake/CMake. The example includes a simulator launch script and
shared interaction smoke checks.

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

Geometry currently uses GNUstep Foundation types. For example, `CGPoint`, `CGSize`, and `CGRect`
are typedefs for `NSPoint`, `NSSize`, and `NSRect`.

## Implemented Public Headers

- `UIApplication`, `UIResponder`, `UIScreen`, `UIDevice`
- `UIView`, `UIWindow`, `UIViewController`
- Constraint layout anchors, `NSLayoutConstraint`, `UILayoutGuide` (partial; see `UIKit-Gaps.md`)
- `UIColor`, `UIImage`, `UIFont`
- `UILabel`, `UIImageView`
- `UIControl`, `UIButton`, `UITextField`, `UITextView`
- `UISlider`, `UISwitch`, `UISegmentedControl`, `UIScrollView`
- `UITableView`, `UITableViewCell`, `UITableViewController`, `NSIndexPath+UIKit`
- `UICollectionView`, flow layout, cells, and `UICollectionViewController`
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
