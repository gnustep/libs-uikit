# Android UIKit cube

The Android host builds **the same `Examples/OpenGLExample.m`** used by the
GNUstep desktop demo. Its `UIWindow`, `UIView`, `UILabel`, `UIButton`, layout and
target/action code execute in `libUIKit.so`. The Activity supplies a surface and
frame scheduling; it does not implement the cube or its controls in Java.

## Build and launch

On Linux x86_64, install the host prerequisites listed in
[`setup-android.sh`](../../setup-android.sh), a JDK with `javac` and `keytool`,
and the Android SDK. Install these SDK packages using Android Studio or
`sdkmanager` (accept the SDK licenses when prompted):

```sh
sdkmanager 'platform-tools' 'build-tools;34.0.0' 'platforms;android-34' \
  'emulator' 'system-images;android-24;default;x86_64'
avdmanager create avd -n UIKitCube_API24 \
  -k 'system-images;android-24;default;x86_64'
```

Then run from the repository root:

```sh
./run-android-cube.sh --sdk /path/to/android-sdk --avd UIKitCube_API24
```

`ANDROID_SDK_ROOT` or `ANDROID_HOME` can supply the SDK path. A single running
emulator is reused; use `--serial emulator-5554` to choose among multiple running
emulators. Only x86_64 emulators running API 24 or later are accepted. The script
builds GNUstep GUI and UIKit, packages the native dependency closure and Java
host, signs a debug APK, installs it, launches it and waits for the first frame.
GNUstep Base, libobjc2 and their dependencies come from the pinned toolchain
release used by the existing bootstrap.

The APK and local debug key are under `build-android/automatic/apk/`. Libraries,
source downloads and logs stay under `build-android/`; nothing is installed into
the host GNUstep installation. The first library bootstrap downloads about
800 MB, in addition to the separately installed Android SDK and system image.
Subsequent runs reuse downloads and incremental native builds.

Useful options:

```sh
# Build/sign only, without an emulator:
./run-android-cube.sh --sdk /path/to/android-sdk --build-only

# Software emulation for hosts without KVM; startup can take several minutes:
./run-android-cube.sh --sdk /path/to/android-sdk --avd UIKitCube_API24 \
  --software --headless --timeout 600

# Repackage an existing native build during host development:
./run-android-cube.sh --sdk /path/to/android-sdk --skip-build --serial emulator-5554
```

Use `--jobs`, `--work-dir` and `--cache-dir` to control native builds. Work paths
have the same character restrictions as `setup-android.sh`. Do not move a
populated work directory. `--skip-build` deliberately skips all native changes;
use the normal command after editing Objective-C or backend code.

## Backend and limits

This is an experimental **single-window cube backend**, not general Android UIKit
coverage. It uses GNUstep's generic graphics-state implementation with Android
Canvas drawing and Android font measurement. An EGL pbuffer provides the
`NSOpenGLContext` used by `UIOpenGLView`; the rendered pixels are composited into
the Android view. This readback path favors simplicity over performance.

The private `Source/Android/GL/gl.h` shim translates the cube's immediate-mode
quads and projection call to OpenGL ES 1. It is not a complete desktop OpenGL
implementation. The application source has no Android conditionals. Logical
UIKit subviews and target/action ownership remain in the existing framework.
The cube remains a GNUstep extension example, not an Apple UIKit source-parity
fixture.

Current scope includes solid paths, basic text, the cube's buttons, resizing,
and Activity foreground/background scheduling. Android density is mapped to
logical UIKit points for drawing, layout and input. Clipping is rectangular;
complex text shaping, image drawing, general native control tracking, keyboard
input, multitouch, drag/drop, menus, dialogs and multiple windows are not
qualified. Desktop services and distributed theme/workspace notifications are
not available in this host. Basic local notifications remain enabled.

The bootstrap patches only its downloaded GNUstep GUI checkout to discover the
linked Android backend and avoid desktop notification-daemon dependencies. The
APK gives bundled ICU libraries private dynamic-library names to avoid Android
system ICU collisions. Build artifacts and dependency binaries are not committed.

The manifest targets API 28 for this experimental host and is not a Play Store
release configuration. It is debuggable and signed with a local development key.

## Runtime checks

```sh
./run-android-cube.sh --sdk /path/to/android-sdk --serial emulator-5554 --smoke
```

The optional native test host checks real EGL framebuffer pixels, timer-driven
rotation, Pause/Reset/Resume through Android touch dispatch and UIKit target/action,
touch cancellation, the logical view hierarchy, updated screen bounds, and
resizing the cube with its UIKit container. A separate `uikit-smoke` result is required before the script
reports success. These checks qualify the cube path only. They passed on an API 24 x86_64
emulator with software graphics; manual checks also exercised an Android input
tap, a stable paused framebuffer, landscape layout and Activity recreation.

## Diagnostics

```sh
/path/to/android-sdk/platform-tools/adb -s emulator-5554 logcat -d
```

Native exceptions are reported under the `UIKit` log tag. A successful install
alone does not establish rendering: the launcher checks a first-frame marker
written by the Activity. Emulator startup logs are in the work directory's
`logs/emulator.log` when the script starts the emulator.
