# UIKit Studio

A graphical, interactive example built from **the same Objective-C application
files** on Apple UIKit and GNUstep UIKit. The app imports only `<UIKit/UIKit.h>`:
there are no AppKit calls, GNUstep conditionals, alternate screen implementations,
third-party dependencies, or required image assets in the application source.
Both targets use manual reference counting.

- **Compose:** type a name to update the preview, move the slider to change a
  constraint's constant, and press Save to exercise target/action delivery.
  The text-field delegate limits names to 18 UTF-16 code units. Return dismisses
  editing. The content scrolls on shorter windows and in landscape.
- **Library:** scroll through 30 reusable rows and select one to update the footer.
  Uses `UITableViewController`.
- **Palette:** browse 12 collection-view swatches. Selecting one changes the
  preview's accent and returns to Compose. Uses `UICollectionViewController`.

The shell uses safe-area insets and centers its content on wider windows.
Controls deliberately use the platform's native rendering; visual differences
between iOS and GNUstep are expected. Save updates the demonstration's status;
it does not write persistent data.

## iOS Simulator

Open `UIKitStudio.xcodeproj`, select the **UIKitStudio** scheme and an iPhone or
iPad simulator, and press Run. Xcode builds against **Apple UIKit**, without this
repository's headers or library. The deployment target is iOS 15 or later. No
signing team is required for the simulator.

Alternatively, from the repository root:

```sh
Examples/UIKitStudio/run-simulator.sh
```

The script requires Xcode, an installed iOS Simulator runtime, and Python 3. It
uses a booted iOS simulator when possible; otherwise it picks an available iPhone.
You can supply a specific device UDID from `xcrun simctl list devices available`:

```sh
Examples/UIKitStudio/run-simulator.sh DEVICE_UDID
```

## GNUstep UIKit

With GNUstep Make, Base, GUI and a GUI backend configured, from the repository
root:

```sh
make
openapp Examples/UIKitStudio.app
```

Or use CMake:

```sh
cmake -S . -B build -DCMAKE_OBJC_COMPILER=clang
cmake --build build --target UIKitStudio
./build/UIKitStudio
```

These targets compile the identical `main.m` and `StudioApp.m`, linked against
this repository's UIKit implementation. The initial window uses the screen's
bounds; resize it to demonstrate adaptive layout.

## Demonstration checks and screenshots

`--smoke` runs the same application-level interaction checks on either runtime:
preview text and constraint geometry, input length validation, Save target/action,
table data, collection data, and changing the accent through the collection
selection callback. A successful run prints
`PASS: UIKit Studio shared-source interaction scenarios` and exits.
These checks invoke UIKit controls and delegate callbacks programmatically; they
are not a complete touch/keyboard UI automation suite.

```sh
Examples/UIKitStudio/run-simulator.sh --smoke
./build/UIKitStudio --smoke
# Without a Linux display:
xvfb-run -a ./build/UIKitStudio --smoke
```

The GNUstep smoke check is also registered with CTest as `UIKitStudio`.
Pass `--screen=0`, `--screen=1`, or `--screen=2` to start on Compose, Library, or
Palette, respectively. These launch arguments work on both runtimes.

For screenshots of all three GNUstep screens, use the separate test host. Only
this screenshot host imports the backend extension; it does not replace any app
screen or application logic.

```sh
cmake --build build --target UIKitStudioCapture
UIKIT_STUDIO_SCREENSHOTS="$PWD/build/studio-previews" \
  xvfb-run -a -s '-screen 0 1024x900x24' ./build/UIKitStudioCapture
```

For an iOS screenshot after launching the desired screen:

```sh
xcrun simctl io booted screenshot /tmp/uikit-studio.png
```

Validated on an iPhone 16 Pro simulator running iOS 18.4 and on Debian bookworm
ARM64 GNUstep/Cairo under Xvfb. The iOS target was built with Xcode; the GNUstep
target was built with both CMake/Clang and GNUmake/GCC. This is a shared-source
example and regression fixture, not a claim of complete UIKit conformance.
