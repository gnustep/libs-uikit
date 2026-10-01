# Desktop core coverage (0.2 development)

This change establishes a tested GNUstep desktop core. It is a release candidate,
not an assertion of complete UIKit compatibility or successful ports of existing
large iOS applications. No release tag, binary publication, or system installation
is performed by this work.

## Compatibility boundary

The target is unchanged Objective-C application source. The implementation
currently covers the frame-based subset below. UIKit objects own private native
peers; public view hierarchies contain UIKit objects only. UIKit class inheritance
and responder routing no longer depend on AppKit inheritance. Rendering remains
theme-dependent and does not yet match iOS visually.

The 0.2 changes break the former desktop adapter ABI: rebuild clients (library
interface version 1). Explicit backend integrations import `GNUstepUIKit.h`;
ordinary UIKit applications must not need that extension.

The acceptance corpus currently consists of the automated core scenarios, a XIB
fixture, and the Core Catalog application's directory, editor, gallery, and canvas.
Qualification against several independent substantial Objective-C applications
remains necessary before calling the broader first-release goal complete.

## Implemented and checked

| Surface | Behavior covered | Evidence |
| --- | --- | --- |
| UIView layout | Top-left coordinates, portable autoresizing, recursive layout, deferred layout scheduling | `testViews` |
| Native scrolling | Correct host/document containment; bounded offsets | `testViews`, `testLists` |
| UIControl | Non-retaining targets; zero-, one-, and two-argument actions; partial event removal; mutation during dispatch | `testControls` |
| UIButton | Titles keyed by state; disabled and normal native rendering | `testControls` |
| UITextField | Secure native field replacement preserving contents; editing notifications; programmatic text changes do not emit editing events | `testControls`, catalog editor |
| UILabel | Borderless native text, wrapping, line-height bounds, text measurement | catalog rendering; backend-dependent line metrics |
| UIViewController | Lazy view/XIB loading, single viewDidLoad per load, child ownership, appearance transitions | `testControllers`, `testResourcesAndScenes` |
| Navigation | Persistent host and Back control; push/pop changes the displayed child | `testControllers`, catalog directory/editor |
| Tabs | Persistent host, selectable native bar, selection changes, clearing tabs | `testControllers`, catalog smoke |
| UITableView | Multiple and empty sections, fixed row heights, visible-cell reuse, selection and scrolling, shrink/reload | `testLists` with 20,000 rows |
| UICollectionView | Multiple and empty sections, viewport cell creation, stable index-path mapping, class registration, selection, flow layout | `testLists` with 20,000 items |
| Native table input | Window-dispatched mouse down/up selects a row and calls the delegate | `testLists` |
| Touch input | Stable touch identity and previous location during mouse drag, delivery to UIView | `testInput` |
| Gestures | Single-pointer tap/pan, translation, terminal states, cancellation of view delivery | `testInput`, catalog canvas |
| Scenes/windows | Transition callback order, no duplicate state callbacks, closed-window registry removal, broken session/scene retain cycle | `testInput`, `testResourcesAndScenes` |
| XIB | Lazy instantiation, outlets/actions, explicit event masks, balanced element tracking, parse errors | `testResourcesAndScenes` |
| Build | Shared source inventory, self-discovering makefiles, portable library linking, standalone headers, CMake/CTest, CI and Docker recipe | build commands below |

Table and collection programmatic selection does not call user-selection delegates.
Additional regression coverage in `Tests/LayoutTests.m` and
`Tests/EditingAndControllerTests.m` exercises constraint resizing, sibling and
nested coordinates, priority conflicts and inequalities, guides, intrinsic sizes,
detachment and lifetime cleanup, native text-edit vetoes (including secure fields),
Return permission, programmatic text changes, list-controller ownership and
selection clearing, and XML XIB constraints across resizing.

Cell object counts are bounded by the viewport; collection flow-layout attributes
are still generated for the complete data set and filtered linearly. Large-data
performance claims apply to cell creation, not constant-time layout queries.

## Build and run

With GNUstep Make, Base, GUI, and a GUI backend installed:

```sh
make
make test
```

Ensure `gnustep-config` is in PATH, or source the installation's `GNUstep.sh`.
`make -C Source` builds only the library. The examples link against that build;
OpenGLExample is opt-in with `UIKIT_BUILD_OPENGL_EXAMPLE=yes` and needs OpenGL.

CMake provides the same library plus the core tests and catalog:

```sh
cmake -S . -B build -DCMAKE_OBJC_COMPILER=/usr/bin/clang
cmake --build build --parallel 2
xvfb-run -a ctest --test-dir build --output-on-failure
./build/UIKitCoreCatalog
```

Use the appropriate compiler path on your platform. On an existing graphical
session, omit `xvfb-run`. `UIKitCoreCatalog --smoke` exercises each screen and exits.
Set `UIKIT_SCREENSHOT_DIR` to capture PNGs of the four catalog screens during smoke.
`Tests/check-headers.sh` checks that every public header compiles independently.

For isolated Linux testing:

```sh
docker build -f Tests/Dockerfile -t libs-uikit-core .
docker run --rm -v "$PWD:/work:ro" libs-uikit-core
```

The Android configuration is retained and now includes event, scene, and gesture
sources through the shared source inventory. Android runtime behavior has not been
qualified by the desktop tests.

## Validation snapshot

On 2026-09-12:

- Debian bookworm ARM64, GNUstep GUI 0.29 / Cairo: 94 core assertions and the
  four-screen catalog smoke pass under Xvfb through CMake/CTest.
- Every public header compiles independently with Clang and GNUstep headers.
- GNUmake builds the library and default examples on Debian and on the local
  macOS GNUstep installation. macOS GUI runtime behavior has not been qualified.
- Catalog PNGs were rendered and inspected during development. Native theme and
  toolchain warnings remain; these checks are not a warning-free-build claim.

On 2026-10-01, the added layout/editing/list-controller/XIB scenarios and the
existing core/catalog scenarios passed on Debian bookworm ARM64 under Xvfb.
CMake/CTest, GNUmake and standalone public-header compilation were checked.
AddressSanitizer also passed the core and catalog runs with leak detection disabled;
this does not establish leak freedom or qualify macOS/Android runtime behavior.
The new tests remain project-authored rather than Apple differential tests.

## Remaining release gates

1. Select and port independent applications covering the supported API surface;
   keep their application sources unchanged and turn compatibility failures into framework tests.
2. Run a differential subset of the behavioral tests against the chosen Apple
   UIKit SDK. Current tests assert expected behavior but are GNUstep-hosted and
   have backend-specific setup; they are not Apple conformance results.
3. Complete long-running ownership, accessibility, keyboard/IME, resize, and
   performance qualification on each supported backend. Automated tests and a
   short catalog smoke run do not establish production readiness.
4. Meet the unchanged-source qualification gates in `SOURCE-COMPATIBILITY.md`.
   The UIKit-only contract test is a regression fixture, not independent app qualification.

## Explicit limits

- Constraint layout and desktop safe-area guides are now partial implementations;
  see `UIKit-Gaps.md` for supported operations and solver limits. No trait system,
  layer animation, modal presentation, standalone navigation/tab bar API, or
  restoration engine.
- Navigation and scroll `animated:` parameters currently apply changes immediately.
- Lists support fixed-size cells and reloads, not batch updates, editing,
  supplementary views, self-sizing, diffable data sources, or grouped styling.
- Gestures cover a mouse pointer on UIView content, not multitouch, recognizer
  failure dependencies, arbitration, or gestures intercepting native controls.
  Existing press wrappers are not a complete keyboard/focus delivery system.
- Text editing is native with UIKit delegate bridges and attributed text-view
  support. Full UITextInput/TextKit, keyboard traits, Dynamic Type,
  attributed-label behavior and accessibility remain incomplete.
- XIB support includes basic constraints and layout guides but remains a subset
  of XML elements. Compiled iOS nibs, storyboards, size-class variations and asset
  catalogs are not implemented.
- Scene transitions adapt the desktop lifecycle; multiple independent scene
  sessions, restoration, and mobile background execution are not implemented.
- Full rendering fidelity and unsupported selectors still require implementation.
  Public hierarchy tests do not establish complete UIKit behavioral equivalence.
