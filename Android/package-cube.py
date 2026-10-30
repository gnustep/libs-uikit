#!/usr/bin/env python3
"""Package native dependency closure and the shared UIKit Activity without Gradle."""
import argparse
from pathlib import Path
import re
import struct
import subprocess
import tempfile
import zipfile

p = argparse.ArgumentParser()
p.add_argument('--sdk', type=Path, required=True)
p.add_argument('--work', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent.parent
sdk, work = a.sdk.resolve(), a.work.resolve()
tools = sdk / 'build-tools/34.0.0'
android = sdk / 'platforms/android-34/android.jar'
ndk = work / 'android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64'
readelf = ndk / 'bin/llvm-readelf'
output = work / 'apk'
output.mkdir(exist_ok=True)

def run(*args):
    subprocess.run([str(arg) for arg in args], check=True)

# Only Android NDK public libraries may remain outside the APK.
system = {'libc.so', 'libm.so', 'libdl.so', 'liblog.so', 'libandroid.so',
          'libz.so', 'libEGL.so', 'libGLESv1_CM.so'}
search = [work / 'uikit-build', work / 'GNUstep/x86_64/lib',
          ndk / 'sysroot/usr/lib/x86_64-linux-android']
closure = {}
pending = ['libUIKitCube.so']
while pending:
    name = pending.pop()
    if name in closure or name in system:
        continue
    source = next((directory / name for directory in search if (directory / name).is_file()), None)
    if source is None:
        raise SystemExit(f'Missing Android dependency: {name}')
    if not name.endswith('.so'):
        raise SystemExit(f'APK dependency needs an unversioned SONAME: {name}')
    info = subprocess.check_output([str(readelf), '-h', '-d', str(source)], text=True)
    if 'Advanced Micro Devices X86-64' not in info:
        raise SystemExit(f'Wrong architecture: {source}')
    closure[name] = source
    pending += re.findall(r'\(NEEDED\).*\[(.*?)\]', info)

# Android 7 exposes system ICU in the app namespace. Give the bundled ICU
# libraries private SONAMEs, updating only ELF dynamic string references.
renames = {name: name.replace('libicu', 'libgsi', 1) for name in closure if name.startswith('libicu')}
def isolated_library(source):
    data = bytearray(source.read_bytes())
    if data[:6] != b'\x7fELF\x02\x01':
        raise SystemExit(f'Expected little-endian ELF64: {source}')
    phoff = struct.unpack_from('<Q', data, 32)[0]
    phsize, phnum = struct.unpack_from('<HH', data, 54)
    segments = [struct.unpack_from('<IIQQQQQQ', data, phoff + i * phsize) for i in range(phnum)]
    dynamic = next(segment for segment in segments if segment[0] == 2)
    entries = []
    for offset in range(dynamic[2], dynamic[2] + dynamic[5], 16):
        tag, value = struct.unpack_from('<QQ', data, offset)
        if not tag:
            break
        entries.append((tag, value))
    address = next(value for tag, value in entries if tag == 5)
    load = next(segment for segment in segments if segment[0] == 1 and segment[3] <= address < segment[3] + segment[5])
    strings = load[2] + address - load[3]
    for tag, value in entries:
        if tag not in (1, 14):
            continue
        start = strings + value
        end = data.index(0, start)
        name = data[start:end].decode()
        if name in renames:
            replacement = renames[name].encode()
            assert len(replacement) == end - start
            data[start:end] = replacement
    return data

with tempfile.TemporaryDirectory(prefix='stage-', dir=output) as temporary:
    stage = Path(temporary)
    classes, dex = stage / 'classes', stage / 'dex'
    classes.mkdir(); dex.mkdir()
    run('javac', '-parameters', '-source', '8', '-target', '8', '-bootclasspath', android, '-d', classes,
        root / 'Android/src/org/gnustep/uikit/UIKitActivity.java')
    run(tools / 'd8', '--lib', android, '--min-api', '24', '--output', dex, *sorted(classes.rglob('*.class')))
    raw = stage / 'unsigned.apk'
    run(tools / 'aapt', 'package', '-f', '-M', root / 'Examples/AndroidCube/AndroidManifest.xml',
        '-I', android, '-F', raw)
    with zipfile.ZipFile(raw, 'a', compression=zipfile.ZIP_DEFLATED) as archive:
        archive.write(dex / 'classes.dex', 'classes.dex')
        for name, source in sorted(closure.items()):
            archive.writestr('lib/x86_64/' + renames.get(name, name), isolated_library(source))
    aligned = stage / 'aligned.apk'
    run(tools / 'zipalign', '-f', '4', raw, aligned)
    key = output / 'debug.keystore'
    if not key.exists():
        run('keytool', '-genkeypair', '-keystore', key, '-storepass', 'android', '-keypass', 'android',
            '-alias', 'androiddebugkey', '-keyalg', 'RSA', '-keysize', '2048', '-validity', '10000',
            '-dname', 'CN=UIKit Android Debug,O=GNUstep,C=US')
    apk = output / 'UIKitCube.apk'
    run(tools / 'apksigner', 'sign', '--ks', key, '--ks-pass', 'pass:android', '--key-pass', 'pass:android',
        '--out', apk, aligned)
    run(tools / 'apksigner', 'verify', apk)
    (output / 'native-libraries.txt').write_text('\n'.join(sorted(renames.get(name, name) for name in closure)) + '\n')
print(apk)
