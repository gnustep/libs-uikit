#!/usr/bin/env bash
# Build the actual GNUstep UIKit cube, package it, and launch an x86_64 emulator.
set -Eeuo pipefail
root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
usage() {
  cat <<'HELP'
Usage: ./run-android-cube.sh [options]

Build GNUstep GUI, UIKit and the existing Objective-C spinning cube; package,
sign, install and launch a debug APK in an Android x86_64 emulator.
Linux x86_64 host; first library build downloads about 800 MB.

  --sdk PATH        Android SDK (ANDROID_SDK_ROOT or ANDROID_HOME)
  --avd NAME        Boot this existing x86_64 AVD if no emulator is running
  --serial SERIAL   Use this running emulator (never selects physical devices)
  --work-dir PATH   Native build/output (default: build-android/automatic)
  --cache-dir PATH  Verified library download cache
  --jobs NUMBER     Native build parallelism (default: 4)
  --build-only      Build and sign APK without starting or installing
  --skip-build      Repackage existing native build (development only)
  --smoke           Also run native rendering/input/layout regression checks
  --headless        Start emulator without a window
  --software        Disable KVM; use software graphics (slow)
  --timeout SEC     Emulator boot timeout (default: 300)
  -h, --help        Show help

SDK packages required: platform-tools, build-tools;34.0.0, platforms;android-34.
Deployment also needs emulator and an x86_64 AVD at API 24 or later.
Install these through Android Studio or sdkmanager before running this script.
Host tools: setup-android.sh prerequisites, JDK (javac/keytool), Python 3.
All builds and the debug signing key stay under --work-dir; no sudo/install.
HELP
}
fail() { printf 'error: %s\n' "$*" >&2; exit 1; }
sdk=${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}
work="$root/build-android/automatic"
cache="$root/build-android/downloads"
jobs=4; avd=; serial=; timeout=300
smoke=no; build_only=no; skip_build=no; headless=no; software=no
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --build-only) build_only=yes; shift ;;
    --skip-build) skip_build=yes; shift ;;
    --smoke) smoke=yes; shift ;;
    --headless) headless=yes; shift ;;
    --software) software=yes; shift ;;
    --sdk|--avd|--serial|--work-dir|--cache-dir|--jobs|--timeout)
      [ "$#" -ge 2 ] && [ -n "$2" ] && [[ "$2" != --* ]] || fail "Missing value for $1"
      case "$1" in
        --sdk) sdk=$2 ;; --avd) avd=$2 ;; --serial) serial=$2 ;;
        --work-dir) work=$2 ;; --cache-dir) cache=$2 ;;
        --jobs) jobs=$2 ;; --timeout) timeout=$2 ;;
      esac
      shift 2 ;;
    *) fail "Unknown option: $1" ;;
  esac
done
[[ "$jobs" =~ ^[1-9][0-9]*$ && "$timeout" =~ ^[1-9][0-9]*$ ]] || fail 'Jobs and timeout must be positive integers'
if [ -n "$serial" ]; then [[ "$serial" =~ ^emulator-[0-9]+$ ]] || fail '--serial must identify an Android emulator'; fi
[ -z "$serial" ] || [ -z "$avd" ] || fail 'Use either --serial or --avd'
[ "$build_only" = no ] || [ "$smoke" = no ] || fail '--smoke needs an emulator; omit --build-only'
[ -n "$sdk" ] || fail 'Set ANDROID_SDK_ROOT or pass --sdk PATH'
[ -d "$sdk" ] || fail "SDK does not exist: $sdk"
sdk=$(CDPATH= cd -- "$sdk" && pwd)
work=$(python3 -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$work")
for tool in javac keytool python3 flock; do command -v "$tool" >/dev/null || fail "Missing $tool"; done
for file in build-tools/34.0.0/aapt build-tools/34.0.0/d8 build-tools/34.0.0/zipalign build-tools/34.0.0/apksigner platforms/android-34/android.jar; do
  [ -f "$sdk/$file" ] || fail "Missing SDK component: $file (see --help)"
done
adb="$sdk/platform-tools/adb"
if [ "$build_only" = no ]; then [ -x "$adb" ] || fail 'SDK platform-tools are required'; fi
if [ "$skip_build" = no ]; then
  "$root/setup-android.sh" --cube --work-dir "$work" --cache-dir "$cache" --jobs "$jobs"
fi
[ -f "$work/uikit-build/libUIKitCube.so" ] || fail 'Cube library missing; rerun without --skip-build'
exec 7>"$work/.package.lock"
flock -n 7 || fail "Another APK build is using $work"
python3 "$root/Android/package-cube.py" --sdk "$sdk" --work "$work"
flock -u 7
[ "$build_only" = no ] || exit 0

if [ -z "$serial" ]; then
  mapfile -t devices < <("$adb" devices | awk '$1 ~ /^emulator-/ && $2 == "device" {print $1}')
  [ "${#devices[@]}" -le 1 ] || fail 'Multiple emulators are running; pass --serial'
  if [ "${#devices[@]}" = 1 ]; then serial=${devices[0]}; fi
fi
if [ -z "$serial" ]; then
  emulator="$sdk/emulator/emulator"
  [ -x "$emulator" ] || fail 'Install the Android emulator SDK package'
  if [ -z "$avd" ]; then
    mapfile -t avds < <("$emulator" -list-avds)
    [ "${#avds[@]}" = 1 ] || fail 'Create an x86_64 AVD or select one with --avd NAME'
    avd=${avds[0]}
  fi
  # An explicit unused port makes device selection deterministic during boot.
  port=5554
  while "$adb" devices | awk '{print $1}' | grep -qx "emulator-$port"; do port=$((port + 2)); done
  [ "$port" -le 5682 ] || fail 'No emulator console port available'
  serial="emulator-$port"
  options=(-avd "$avd" -port "$port" -no-snapshot -no-audio)
  [ "$headless" = no ] || options+=(-no-window)
  [ "$software" = no ] || options+=(-accel off -gpu swiftshader_indirect)
  mkdir -p "$work/logs"
  "$emulator" "${options[@]}" >"$work/logs/emulator.log" 2>&1 &
  emulator_pid=$!
  printf 'Starting %s (%s); log: %s/logs/emulator.log\n' "$avd" "$serial" "$work"
fi
[[ "$serial" == emulator-* ]] || fail '--serial must identify an Android emulator'
deadline=$((SECONDS + timeout))
while [ "$("$adb" -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != 1 ]; do
  if [ -n "${emulator_pid:-}" ]; then kill -0 "$emulator_pid" 2>/dev/null || fail "Emulator exited; see $work/logs/emulator.log"; fi
  [ "$SECONDS" -lt "$deadline" ] || fail "Emulator boot timed out; see $work/logs/emulator.log"
  sleep 2
done
abi=$("$adb" -s "$serial" shell getprop ro.product.cpu.abi | tr -d '\r')
[ "$abi" = x86_64 ] || fail "Expected x86_64 emulator, got $abi"
api=$("$adb" -s "$serial" shell getprop ro.build.version.sdk | tr -d '\r')
[ "$api" -ge 24 ] || fail 'Emulator requires Android API 24 or later'
"$adb" -s "$serial" install -r "$work/apk/UIKitCube.apk"
"$adb" -s "$serial" shell am force-stop org.gnustep.uikit.cube
"$adb" -s "$serial" shell am start --ez smoke "$([ "$smoke" = yes ] && echo true || echo false)" -n org.gnustep.uikit.cube/org.gnustep.uikit.UIKitActivity
deadline=$((SECONDS + timeout))
while :; do
  pid=$("$adb" -s "$serial" shell pidof org.gnustep.uikit.cube 2>/dev/null | tr -d '\r' || true)
  ready=$("$adb" -s "$serial" shell run-as org.gnustep.uikit.cube cat files/uikit-ready 2>/dev/null | tr -d '\r' || true)
  if [ -n "$pid" ] && [ "$ready" = "$pid" ]; then
    if [ "$smoke" = no ]; then break; fi
    result=$("$adb" -s "$serial" shell run-as org.gnustep.uikit.cube cat files/uikit-smoke 2>/dev/null | tr -d '\r' || true)
    if [ "$result" = PASS ]; then printf 'Android cube regression checks passed.\n'; break; fi
  fi
  [ "$SECONDS" -lt "$deadline" ] || fail "App did not complete startup or requested smoke checks. Inspect: $adb -s $serial logcat -d"
  sleep 1
done
printf '\nLaunched UIKit cube on %s. APK: %s/apk/UIKitCube.apk\n' "$serial" "$work"
