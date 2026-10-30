#!/usr/bin/env bash
# Bootstrap the validated Android emulator build without installing system files.
set -Eeuo pipefail

usage()
{
  cat <<'HELP'
Usage: ./setup-android.sh [options]

Download NDK r27c and GNUstep Android release-20250211, cross-build TIFF
4.7.0 and GNUstep GUI, then build/install UIKit locally. Linux x86_64 host
only; target is x86_64, Android API 24. Produces a library, not an APK.

  --cube            Also build the experimental Android cube host/backend
  --work-dir PATH   Toolchain, sources, logs and output (build-android/automatic)
  --cache-dir PATH  Verified download cache (build-android/downloads)
  --jobs NUMBER     Parallel build jobs (default: 4)
  -h, --help        Show this help

Defaults are relative to this repository; explicit paths are relative to the
current directory. GNUstep Make requires paths without spaces or shell/make
metacharacters. Rerun the same command to reuse downloads and incremental builds.
Do not move a populated work directory; use a fresh one at the new location.

Debian prerequisites (install separately if missing):
  sudo apt install build-essential cmake curl unzip xz-utils python3 pkg-config
CMake 3.21+ is required. No Android Studio or installed GNUstep is needed.
Allow several GB of disk space. Downloads are about 800 MB on the first run.
Use of the NDK is subject to Google's license: https://developer.android.com/ndk/downloads
HELP
}
fail() { printf 'error: %s\n' "$*" >&2; exit 1; }
root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
work="$root/build-android/automatic"
cache="$root/build-android/downloads"
jobs=4
cube=no
while [ "$#" -gt 0 ]; do
  case "$1" in
    --cube) cube=yes; shift ;;
    -h|--help) usage; exit 0 ;;
    --work-dir|--cache-dir|--jobs)
      [ "$#" -ge 2 ] && [ -n "$2" ] || fail "Missing value for $1"
      case "$2" in --*) fail "Missing value for $1" ;; esac
      case "$1" in
        --work-dir) work=$2 ;;
        --cache-dir) cache=$2 ;;
        --jobs) jobs=$2 ;;
      esac
      shift 2 ;;
    *) fail "Unknown option: $1 (use --help)" ;;
  esac
done
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || fail '--jobs must be a positive integer'
[ "$(uname -s)/$(uname -m)" = Linux/x86_64 ] || fail 'This bootstrap supports Linux x86_64 hosts only'
for tool in cmake make cc c++ curl unzip tar xz python3 pkg-config sha256sum flock; do
  command -v "$tool" >/dev/null || fail "Missing $tool; see --help for prerequisites"
done
python3 - <<'PY'
import re, subprocess
version = subprocess.check_output(['cmake', '--version'], text=True).splitlines()[0]
if tuple(map(int, re.search(r'(\d+)\.(\d+)', version).groups())) < (3, 21):
    raise SystemExit('CMake 3.21 or newer is required')
PY
work=$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$work")
cache=$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$cache")
for path in "$root" "$work" "$cache"; do
  [[ "$path" =~ ^/[a-zA-Z0-9_./-]+$ ]] || fail "Unsupported characters in path: $path"
done
mkdir -p "$work/logs" "$cache"
exec 9>"$work/.bootstrap.lock"
flock -n 9 || fail "Another build is using $work"
exec 8>"$cache/.downloads.lock"
flock -n 8 || fail "Another download is using $cache"
if [ -f "$work/.location" ]; then
  [ "$(cat "$work/.location")" = "$work" ] || fail 'Work directory was moved; use a fresh --work-dir'
fi
printf '%s\n' "$work" > "$work/.location"
trap 'printf "Build failed; inspect logs in %s/logs\n" "$work" >&2' ERR

# Download into a temporary file and only promote it after verification.
download()
{
  local name=$1 sum=$2 url=$3
  if [ ! -f "$cache/$name" ]; then
    printf 'Downloading %s ...\n' "$name"
    curl --fail --location --retry 3 --connect-timeout 30 "$url" -o "$cache/$name.part"
    printf '%s  %s\n' "$sum" "$cache/$name.part" | sha256sum --check --status || fail "Checksum mismatch: $cache/$name.part"
    mv "$cache/$name.part" "$cache/$name"
  fi
  printf '%s  %s\n' "$sum" "$cache/$name" | sha256sum --check --status || fail "Checksum mismatch: $cache/$name (replace this cached archive)"
}
download android-ndk-r27c-linux.zip 59c2f6dc96743b5daf5d1626684640b20a6bd2b1d85b13156b90333741bad5cc \
  https://dl.google.com/android/repository/android-ndk-r27c-linux.zip
download GNUstep-Android-NDK-r27c-Linux.tar.xz 670b5e4e7c19a86a5cb583eb541e8a61b703b70c49467f8f8df23e1d5876da0d \
  https://github.com/gnustep/tools-android/releases/download/release-20250211/GNUstep-Android-NDK-r27c-Linux.tar.xz
download tiff-4.7.0.tar.xz 273a0a73b1f0bed640afee4a5df0337357ced5b53d3d5d1c405b936501f71017 \
  https://download.osgeo.org/libtiff/tiff-4.7.0.tar.xz
gui_revision=4716e3a1b51e8c2cd6aaf00fbe89ff06f4a597ba
download libs-gui-4716e3a1b.tar.gz dec79d2f5bc71ab27aba66b7e5949ad83b55f236d289aa684f0b6239888439d7 \
  "https://codeload.github.com/gnustep/libs-gui/tar.gz/$gui_revision"
back_revision=36ac709b892caf697bf4d27624854dbbfdd19da4
if [ "$cube" = yes ]; then
  download libs-back-$back_revision.tar.gz 2558c5e8357ee633f1c8bee03bacbfbf51213f0c55c5f2aeaa630f6de2907641 \
    "https://codeload.github.com/gnustep/libs-back/tar.gz/$back_revision"
fi
flock -u 8

# Extraction is transactional. An interrupted extraction never becomes a source
# or toolchain directory used by subsequent builds.
unpack()
{
  local name=$1 folder=$2 stage
  [ ! -d "$work/$folder" ] || return 0
  printf 'Extracting %s ...\n' "$name"
  stage=$(mktemp -d "$work/.unpack.XXXXXX")
  case "$name" in
    *.zip) unzip -q "$cache/$name" -d "$stage" ;;
    *) tar -xf "$cache/$name" -C "$stage" ;;
  esac
  mv "$stage/$folder" "$work/$folder"
  rmdir "$stage"
}
unpack android-ndk-r27c-linux.zip android-ndk-r27c
unpack GNUstep-Android-NDK-r27c-Linux.tar.xz GNUstep
unpack tiff-4.7.0.tar.xz tiff-4.7.0
unpack libs-gui-4716e3a1b.tar.gz "libs-gui-$gui_revision"
backend_args=()
if [ "$cube" = yes ]; then
  unpack libs-back-$back_revision.tar.gz "libs-back-$back_revision"
  backend_args=(--backend-source "$work/libs-back-$back_revision")
  # Prefer the linked UIKit backend on Android. Keep normal bundle loading as
  # fallback for library-only users. Patch only this private source checkout.
  python3 "$root/Android/patch-gui.py" "$work/libs-gui-$gui_revision/Source/NSApplication.m"
fi
ndk="$work/android-ndk-r27c"
prefix="$work/GNUstep/x86_64"

# The release's text configuration contains CI-host NDK paths and a default
# ~/Android/GNUstep prefix. Relocate only this private copy, preserving binaries.
python3 - "$work" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1])
for path in (root / 'GNUstep/x86_64').rglob('*'):
    if not path.is_file() or path.is_symlink():
        continue
    try:
        text = path.read_text()
    except UnicodeError:
        continue
    updated = text.replace('${HOME}/Android/GNUstep', str(root / 'GNUstep'))
    updated = updated.replace('/usr/local/lib/android/sdk/ndk/27.2.12479018', str(root / 'android-ndk-r27c'))
    if updated != text:
        path.write_text(updated)
PY
step()
{
  local name=$1
  shift
  printf '%s (log: %s/logs/%s.log)\n' "$name" "$work" "$name"
  if ! "$@" >"$work/logs/$name.log" 2>&1; then
    tail -n 35 "$work/logs/$name.log" >&2
    fail "$name failed; see $work/logs/$name.log"
  fi
}
# Keep host pkg-config and environment flags out of cross-compilation.
unset CC CXX OBJC OBJCXX CPP CFLAGS CXXFLAGS OBJCFLAGS CPPFLAGS LDFLAGS
unset CMAKE_PREFIX_PATH PKG_CONFIG_PATH PKG_CONFIG_SYSROOT_DIR
export PKG_CONFIG_LIBDIR="$prefix/lib/pkgconfig"
step tiff-configure cmake -S "$work/tiff-4.7.0" -B "$work/tiff-build" \
  -DCMAKE_TOOLCHAIN_FILE="$ndk/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=x86_64 -DANDROID_PLATFORM=android-24 -DCMAKE_INSTALL_PREFIX="$prefix" \
  -Dtiff-tools=OFF -Dtiff-tests=OFF -Dtiff-contrib=OFF -Dtiff-docs=OFF \
  -Djbig=OFF -Djpeg=OFF -Dlerc=OFF -Dlibdeflate=OFF -Dlzma=OFF -Dwebp=OFF -Dzstd=OFF
step tiff-build cmake --build "$work/tiff-build" --parallel "$jobs"
step tiff-install cmake --install "$work/tiff-build"
(
  export PATH="$prefix/bin:$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
  export GNUSTEP_MAKEFILES="$prefix/share/GNUstep/Makefiles"
  export GNUSTEP_CONFIG_FILE="$prefix/etc/GNUstep/GNUstep.conf"
  export GNUSTEP_USER_CONFIG_FILE="$prefix/etc/GNUstep/GNUstep-user.conf"
  export CC="$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android24-clang"
  export CXX="${CC}++" OBJC="$CC" CPP="$CC -E"
  export CPPFLAGS="-I$prefix/include"
  export LDFLAGS="-L$prefix/lib -Wl,-rpath-link,$prefix/lib"
  cd "$work/libs-gui-$gui_revision"
  step gui-configure ./configure --host=x86_64-linux-android --disable-jpeg --disable-png --without-x
  step gui-build make -j"$jobs"
  step gui-install make install
)
step uikit-build "$root/build-android.sh" --ndk "$ndk" --gnustep "$prefix" \
  --abi x86_64 --platform android-24 --runtime gnustep-2.0 \
  --build-dir "$work/uikit-build" --install-prefix "$work/install/x86_64" --jobs "$jobs" "${backend_args[@]}"
step binary-inspection "$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-readelf" \
  --file-header --notes --dynamic "$work/install/x86_64/lib/libUIKit.so"
printf '\nBuilt Android x86_64/API 24 UIKit:\n  %s/install/x86_64/lib/libUIKit.so\n' "$work"
printf 'Headers: %s/install/x86_64/include\nDependencies: %s/lib\nLogs: %s/logs\n' "$work" "$prefix" "$work"
if [ "$cube" = yes ]; then
  printf 'Cube host: %s/uikit-build/libUIKitCube.so (package with run-android-cube.sh)\n' "$work"
else
  printf 'Library only; use run-android-cube.sh for the experimental cube APK.\n'
fi
