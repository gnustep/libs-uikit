#!/bin/sh
set -eu
example_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$example_dir/../.." && pwd)
device_id=''
if [ "$#" -gt 0 ]; then
  case "$1" in --*) ;; *) device_id=$1; shift ;; esac
fi
if [ -z "$device_id" ]; then
  device_id=$(python3 - <<'PY'
import json, subprocess
inventory = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'devices', 'available', '--json']))
devices = [d for runtime, group in inventory['devices'].items() if 'iOS' in runtime for d in group]
booted = [d for d in devices if d['state'] == 'Booted']
phones = [d for d in devices if d['name'].startswith('iPhone')]
choices = booted or phones or devices
if not choices:
    raise SystemExit('Install an iOS Simulator runtime in Xcode Settings > Components.')
print(choices[0]['udid'])
PY
  )
fi
xcodebuild -quiet -project "$example_dir/UIKitStudio.xcodeproj" -scheme UIKitStudio \
  -configuration Debug -sdk iphonesimulator -destination "generic/platform=iOS Simulator" -derivedDataPath "$repo_dir/build-studio-ios" \
  CODE_SIGNING_ALLOWED=NO build
# Bootstatus -b boots a shut-down device and waits for it to be ready.
xcrun simctl bootstatus "$device_id" -b
xcrun simctl install "$device_id" "$repo_dir/build-studio-ios/Build/Products/Debug-iphonesimulator/UIKitStudio.app"
open -a Simulator --args -CurrentDeviceUDID "$device_id"
case " $* " in
  *' --smoke '*) xcrun simctl launch --terminate-running-process --console "$device_id" org.gnustep.UIKitStudio "$@" ;;
  *) xcrun simctl launch --terminate-running-process "$device_id" org.gnustep.UIKitStudio "$@" ;;
esac
