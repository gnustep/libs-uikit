# libs-uikit

`libs-uikit` is a GNUstep Objective-C library that provides a UIKit-like API on
top of GNUstep Base and GUI. It is intended for code that wants familiar UIKit
class names and application structure while running in a GNUstep/AppKit
environment.

The library currently exposes a focused subset of UIKit-style classes including
application/window management, views and view controllers, common controls,
table/navigation/tab containers, images, colors, fonts, nib loading helpers, and
basic device/screen abstractions.

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
- `Examples` builds the `UIKitExample` application.

To build only the library:

```sh
make -C Source
```

To build only the example application:

```sh
make -C Examples
```

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
