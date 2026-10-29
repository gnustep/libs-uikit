#!/bin/sh
# Build UIKit against an existing Android GNUstep installation.
set -eu

usage()
{
  cat <<'EOF'
Usage: ./build-android.sh [options]

Requires CMake 3.21+, an Android NDK, and Android-built GNUstep Base,
GNUstep GUI and libobjc2 for the selected ABI. This builds a library, not an APK.

Options (environment variables can supply defaults):
  --ndk PATH             Android NDK (ANDROID_NDK_HOME or ANDROID_NDK_ROOT)
  --gnustep PATH         Android GNUstep prefix (GNUSTEP_ANDROID_ROOT)
  --abi ABI              Target ABI (ANDROID_ABI; default: arm64-v8a)
  --platform PLATFORM    Minimum API (ANDROID_PLATFORM; default: android-24)
  --runtime NAME         Objective-C runtime (UIKIT_ANDROID_OBJC_RUNTIME;
                         default: gnustep-2.0)
  --build-dir PATH       Build directory (default: build-android/<abi> in repo)
  --install-prefix PATH  Also install headers and library at this prefix
  --jobs NUMBER          Parallel build jobs (default: CMake's default)
  -h, --help             Show this help

Example:
  ./build-android.sh --ndk /opt/android-ndk --gnustep /opt/gnustep-android

GNUstep headers must be under include/GNUstep or include; libraries must
be under lib or lib/<abi>. Dependencies are not downloaded or built.
Relative paths are resolved from the current working directory.
EOF
}

fail()
{
  printf 'error: %s\n' "$*" >&2
  exit 1
}

root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ndk=${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-}}
gnustep=${GNUSTEP_ANDROID_ROOT:-}
abi=${ANDROID_ABI:-arm64-v8a}
platform=${ANDROID_PLATFORM:-android-24}
runtime=${UIKIT_ANDROID_OBJC_RUNTIME:-gnustep-2.0}
build_dir=
install_prefix=
jobs=

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --ndk|--gnustep|--abi|--platform|--runtime|--build-dir|--install-prefix|--jobs)
      [ "$#" -ge 2 ] && [ -n "$2" ] || fail "Missing value for $1"
      case "$2" in --*) fail "Missing value for $1" ;; esac
      case "$1" in
        --ndk) ndk=$2 ;;
        --gnustep) gnustep=$2 ;;
        --abi) abi=$2 ;;
        --platform) platform=$2 ;;
        --runtime) runtime=$2 ;;
        --build-dir) build_dir=$2 ;;
        --install-prefix) install_prefix=$2 ;;
        --jobs) jobs=$2 ;;
      esac
      shift 2 ;;
    *) fail "Unknown option: $1 (use --help)" ;;
  esac
done

case "$abi" in
  arm64-v8a|armeabi-v7a|x86|x86_64) ;;
  *) fail "Unsupported Android ABI: $abi" ;;
esac
if [ -n "$jobs" ]; then
  case "$jobs" in *[!0-9]*|0) fail "--jobs must be a positive integer" ;; esac
  [ "$jobs" -gt 0 ] || fail "--jobs must be a positive integer"
fi
[ -n "$ndk" ] || fail "Set ANDROID_NDK_HOME or pass --ndk PATH."
[ -f "$ndk/build/cmake/android.toolchain.cmake" ] ||
  fail "NDK toolchain not found under $ndk/build/cmake."
[ -n "$gnustep" ] || fail "Set GNUSTEP_ANDROID_ROOT or pass --gnustep PATH (Android-built dependencies)."
[ -d "$gnustep" ] || fail "GNUstep prefix does not exist: $gnustep"
command -v cmake >/dev/null 2>&1 || fail "CMake 3.21 or newer is required."

# CMake validates the version and locates the dependency headers and libraries.
ndk=$(CDPATH= cd -- "$ndk" && pwd)
gnustep=$(CDPATH= cd -- "$gnustep" && pwd)
build_dir=${build_dir:-"$root/build-android/$abi"}
case "$build_dir" in /*) ;; *) build_dir="$PWD/$build_dir" ;; esac
if [ -n "$install_prefix" ]; then
  case "$install_prefix" in /*) ;; *) install_prefix="$PWD/$install_prefix" ;; esac
fi

cmake -S "$root" -B "$build_dir" \
  "-DCMAKE_TOOLCHAIN_FILE=$ndk/build/cmake/android.toolchain.cmake" \
  "-DANDROID_ABI=$abi" \
  "-DANDROID_PLATFORM=$platform" \
  "-DGNUSTEP_ANDROID_ROOT=$gnustep" \
  "-DUIKIT_ANDROID_OBJC_RUNTIME=$runtime"

if [ -n "$jobs" ]; then
  cmake --build "$build_dir" --parallel "$jobs"
else
  cmake --build "$build_dir" --parallel
fi
if [ -n "$install_prefix" ]; then
  cmake --install "$build_dir" --prefix "$install_prefix"
fi
printf '\nUIKit Android library built in %s\n' "$build_dir"
