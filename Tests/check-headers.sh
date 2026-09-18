#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
: "${CC:=clang}"
objc_headers=$(gcc -print-file-name=include)
for header in Headers/UIKit/*.h; do
  case "$header" in
    */GNUstepUIKit.h|*/UIOpenGLView.h) boundary='' ;;
    *) boundary='#ifdef _GNUstep_H_NSView
#error Public UIKit headers must not import AppKit
#endif' ;;
  esac
  printf '#import <%s>\n%s\n' "${header#Headers/}" "$boundary" |
    $CC $(gnustep-config --objc-flags) -I"$objc_headers" -IHeaders -x objective-c -fsyntax-only -
done
