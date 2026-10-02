#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
: "${CC:=clang}"
: "${UIKIT_TEST_BUILD_DIR:=${TMPDIR:-/tmp}/libs-uikit-tests}"
mkdir -p "$UIKIT_TEST_BUILD_DIR"
# GNUstep flags are whitespace-separated compiler options supplied by gnustep-config.
objc_headers=$(gcc -print-file-name=include)
sources=$(sed 's|^|Source/|' Source/Sources.list)
$CC -std=gnu11 -IHeaders -ISource $(gnustep-config --objc-flags) -I"$objc_headers" \
  $sources Tests/CoreTests.m Tests/UIKitContract.m Tests/LayoutTests.m Tests/EditingAndControllerTests.m Tests/PlaygroundTests.m Tests/CatalogTests.m -o "$UIKIT_TEST_BUILD_DIR/CoreTests" $(gnustep-config --gui-libs)
"$UIKIT_TEST_BUILD_DIR/CoreTests"
