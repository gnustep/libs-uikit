#!/usr/bin/env python3
"""Add linked Android-backend discovery to the private bootstrap GUI checkout."""
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
marker = '/* UIKit Android linked backend */'
needle = '      first = 0;\n#ifdef BACKEND_BUNDLE'
replacement = '''      first = 0;
#if defined(__ANDROID__)
      /* UIKit Android linked backend */
      backend = NSClassFromString (@"GSUIKitAndroidBackend");
      if (backend != Nil)
        {
          [backend initializeBackend];
          return YES;
        }
#endif
#ifdef BACKEND_BUNDLE'''
if marker not in source:
    if source.count(needle) != 1:
        raise SystemExit('Unexpected GNUstep NSApplication source; refusing to patch')
    path.write_text(source.replace(needle, replacement))

# Android applications do not run the desktop distributed-notification daemon.
# Keep in-process defaults notifications and workspace notification delivery.
for filename in ('GSTheme.m', 'NSWorkspace.m'):
    other = path.with_name(filename)
    text = other.read_text()
    marker = '/* UIKit Android local notifications */'
    if marker in text:
        continue
    needle = '[NSDistributedNotificationCenter defaultCenter]'
    if text.count(needle) != 1:
        raise SystemExit(f'Unexpected {filename}; refusing to patch')
    replacement = '''
#if defined(__ANDROID__)
      /* UIKit Android local notifications */
      (NSClassFromString (@"GSUIKitAndroidBackend") != Nil ? nil : [NSDistributedNotificationCenter defaultCenter])
#else
      [NSDistributedNotificationCenter defaultCenter]
#endif
'''
    other.write_text(text.replace(needle, replacement))
