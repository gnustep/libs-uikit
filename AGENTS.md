# Working in libs-uikit

## Purpose and compatibility boundary

This is an Objective-C UIKit compatibility framework for GNUstep, backed by
private AppKit peers. Read `README.md` for build instructions and
`SOURCE-COMPATIBILITY.md` for the application contract and known limits.

- Preserve unchanged Objective-C application source across Apple UIKit and
  GNUstep UIKit. Resolve missing APIs and backend differences in the framework;
  do not require application-side GNUstep conditionals or native widget accessors.
- Preserve UIKit inheritance and the logical UIKit view/responder hierarchy.
  Native peer views must not leak into public `subviews`, ownership, or routing.
- Ordinary public headers must compile independently without importing AppKit.
  Keep backend declarations in `Source/UIKitPrivate.h` or the explicit
  `Headers/UIKit/GNUstepUIKit.h` extension. Backend hosts must import that
  extension before direct AppKit imports to avoid text-alignment name conflicts.
  The header checker also exempts the existing `UIOpenGLView.h` extension; do not
  extend those exceptions to ordinary UIKit APIs.
- Declarations and demos are not evidence of full UIKit behavior. Document
  partial implementations and distinguish desktop validation from Apple or
  Android runtime coverage.

## Repository map and coordinated changes

- `Headers/UIKit/`: public declarations; `UIKit.h` is the umbrella header.
- `Source/`: implementations and private bridge helpers. Several related classes
  share implementation files, so inspect nearby code before adding a new file.
- `Source/Sources.list`: shared implementation inventory consumed by GNUmake,
  CMake, and `Tests/run.sh`. Register new implementation files here.
- `Source/GNUmakefile`: explicit framework header installation list. Add new
  public headers here and expose them through `Headers/UIKit/UIKit.h` as needed.
  CMake installs headers from `Headers/UIKit/` automatically.
- `Tests/`: public contract, layout, controller/editing, playground, and catalog
  regressions; `Fixtures.bundle/` holds resource fixtures.
- `Examples/`: XIB example, Core Catalog, UIKit Studio, and optional OpenGL demo.
  UIKit Studio's shared-source and simulator instructions are in its README.
- `UIKit-Gaps.md` and `RELEASE-MILESTONE-1.md`: layout details and historical
  coverage context. Use current code and compatibility documentation when older
  milestone descriptions differ.

Recent work couples API additions with native behavior, regression coverage,
and compatibility documentation. Follow that pattern: check signatures, enum
values, ownership, callbacks, layout, and build registration together. The
companion UIKitTest catalog mentioned in the README lives outside this repo;
do not assume it is available as a bundled test target.

## Code and documentation style

- Match the surrounding file. Objective-C commonly uses two-space indentation,
  method opening braces on a new line, and compact one-line accessors. Older
  GNUstep-style blocks and newer compact blocks coexist; avoid wholesale
  reformatting. Preserve tabs in make recipes.
- Use existing `UI`/`NS` API names, underscore-prefixed ivars, header guards,
  `#import`, and forward declarations consistently with adjacent headers.
- The implementation uses manual reference counting. Balance retain/copy/release,
  release owned objects in `dealloc`, and call `[super dealloc]`. Preserve existing
  delegate/target ownership and block lifetime handling; do not introduce an ARC
  requirement or assume every GNUstep runtime supports the same features.
- Prefer existing private bridge helpers for geometry, alignment, native peer
  access, and event translation rather than duplicating conversions.
- Keep Markdown practical: descriptive headings, fenced commands, relative links,
  and explicit limits. Update compatibility claims when observable behavior changes.
- History uses short action-oriented commit subjects such as “Add …” or
  “Update …”; no Conventional Commits prefix is required. Describe the concrete
  change and validation in review summaries.

## Build and validation

Run commands from the repository root. Desktop builds need Clang, GNUstep Make,
Base and GUI, a working GUI backend, and `gnustep-config` on `PATH`. Headless GUI
tests need Xvfb; CMake requires version 3.21 or later.

```sh
# Framework and bundled applications
make

# Standalone public-header checks and core regressions
./Tests/check-headers.sh
xvfb-run -a make test

# CMake library, applications, and all three CTest suites
cmake -S . -B build -DCMAKE_OBJC_COMPILER=clang -DBUILD_TESTING=ON
cmake --build build
LD_LIBRARY_PATH="$PWD/build${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
  xvfb-run -a ctest --test-dir build --output-on-failure
```

- With a working display, `make test` can run directly. It invokes `Tests/run.sh`,
  which compiles sources into a standalone core test executable; override
  `UIKIT_TEST_BUILD_DIR` when a separate output directory is needed.
- CTest runs `UIKitCore`, `UIKitStudio`, and `UIKitCatalog`. The latter two are
  application smoke checks. `.github/workflows/core.yml` checks headers, builds
  both ways, and runs headless CTest; keep both build paths working.
- For behavioral fixes, extend the relevant existing regression file using its
  `CHECK`/`VERIFY` conventions. Keep `Tests/UIKitContract.m` limited to public UIKit
  imports; put AppKit setup and native assertions in backend test hosts.
- If adding a test translation unit, register it in both `Tests/run.sh` and
  `CMakeLists.txt`, and call its entry point from the core runner when appropriate.
- Exercise meaningful behavior such as callbacks, reparenting, geometry, resource
  loading, and object lifetimes. Isolate preferences and restore temporary state;
  tests must not alter persistent user defaults.
- For public API or build changes, run header checks and both build paths. For
  interaction/rendering changes, supplement regressions with the relevant example
  or smoke check. Documentation-only edits need link/path and diff review, not a
  GUI rebuild. Report commands run and any validation that could not be completed.
- Keep builds local unless installation is part of the task. When testing against
  an installed framework, ensure headers and runtime library come from the same
  build; an older installed UIKit can hide or create failures.

Do not commit generated `obj/`, `build/`, `build-*/`, `.app`, `.framework`, `.o`,
`.d`, or `Source/derived_src/` output. Keep changes focused and preserve unrelated
working-tree edits.
