#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
: "${CC:=clang}"
objc_headers=$(gcc -print-file-name=include)
for header in Headers/UIKit/*.h; do
  printf '#import <%s>\n' "${header#Headers/}" |
    $CC $(gnustep-config --objc-flags) -I"$objc_headers" -IHeaders -x objective-c -fsyntax-only -
done
