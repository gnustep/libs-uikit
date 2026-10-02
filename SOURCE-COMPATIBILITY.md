# Unchanged-source compatibility contract

An application must use the same Objective-C source on Apple UIKit and this
framework. Missing APIs, backend differences, and resource conversion belong in
the framework/toolchain. Replacing imports, adding GNUstep conditionals, rewriting
controllers, or using native widget accessors in application code does not count
as a successful port. Recompilation, platform linking and packaging are expected;
running an existing iOS executable is a separate binary-compatibility project.

## Implemented foundation

- `UIResponder : NSObject`, `UIView : UIResponder`, `UIWindow : UIView`, and
  `UITextView : UIScrollView` expose UIKit inheritance.
- AppKit peers are private implementation objects. `subviews`, `superview`,
  `window`, reparenting and ordering describe the logical UIKit hierarchy.
- Window hosting, native resize, drawing, input, controls and scrolling bridge
  through those peers. Scrollers do not displace the UIKit content coordinates.
- First-responder lookup maps native focus back to UIKit; nil-target control
  actions traverse UIKit responders. Control event masks use `NSUInteger`.
- Public headers do not import AppKit. Alignment values follow UIKit and are
  translated when sent to native widgets. `loadNibNamed:owner:options:` returns
  the top-level object array.
- Backend-only examples and test infrastructure can import `GNUstepUIKit.h`.
  This extension must precede direct AppKit imports, because the two toolkits
  define conflicting text-alignment names. It is not part of the app contract.

The library is now version 0.2.0, interface version 1. Clients of the former
NSView/NSWindow-based adapter must rebuild. Code that deliberately used native
selectors on UIKit objects was adapter-specific and requires migration to the
explicit backend extension.

## Evidence and limits

`Tests/UIKitContract.m` imports only UIKit and exercises inheritance, application
hierarchy, hidden native children, responder actions, scroll coordinates,
hit testing, ordering, reparenting and text focus. The separate desktop test host
initializes AppKit. `Tests/check-headers.sh` rejects accidental AppKit imports in
ordinary public headers. The original core regressions and catalog smoke test
remain enabled in CTest and the shell test runner.

This is a project-authored contract fixture, not an independently developed iOS
application or an Apple differential test. It does not prove complete source
compatibility. No frozen third-party app has yet been qualified. The catalog has
explicit backend integration for screenshots and window titles and is not the
unchanged-app acceptance corpus.

## Remaining release gates, in order

1. Pin a specific Apple SDK/version and deployment range as the conformance
   baseline. Import a machine-readable declaration inventory, including enums,
   protocols, properties, categories and method types; classify declarations as
   implemented, partial or missing. Existing declarations alone are not evidence
   of behavior. CoreGraphics headers, geometry type identity and other framework
   dependencies need their own compatibility surface.
2. Check in licensed, independent Objective-C apps with immutable source hashes.
   Start with a programmatic form/navigation app, then an Interface Builder app
   and a scrolling/custom-drawing app. Build the same source files against both
   implementations. Fix all compile/link failures in the framework. Record the
   compiler/runtime requirements: ARC, blocks and modern Objective-C need an
   appropriate runtime and Foundation build; the Debian legacy-runtime tests
   currently validate manually managed Objective-C code.
3. Implement resource fidelity. The existing XML XIB loader supports only a
   subset and does not provide compiled iOS nibs, storyboard graphs, asset
   catalogs, or full NSCoder decoding. Preserve original resources; convert
   them as a build step where necessary. Test custom classes, outlets, actions,
   localization and startup from bundle metadata. A blank fallback view is not
   a successful resource load.
4. Complete the new constraint-layout, intrinsic-size and desktop safe-area subset
   (see `UIKit-Gaps.md`), and add traits; controller presentation,
   navigation/bar APIs; drawing/layer/animation support; complete text input/delegate coverage;
   touch arbitration, keyboard and accessibility. Expand the app corpus as these
   features become available. Native-control gesture interception and exact
   appearance remain incomplete even in the present frame-based subset.
5. Run identical behavioral scenarios against Apple UIKit and GNUstep. Compare
   callbacks, geometry, responder behavior, rendering and resource loading. Test
   lifetime/ownership and long-running interaction on each supported backend.
   Publish compatibility claims only for the SDK surface and unchanged apps
   actually qualified by these runs.

An unsupported API is a framework gap to implement, not a request that the
application author change their source.

## UIKit playground coverage

The XML playground fixture now covers native-backed `UIProgressView` and
`UIStepper`, `UISwitch.on`, segmented-control items and selection, scroll content
and frame guides, and constrained fill/fill-equally stacks. Table support includes
footer views, disclosure accessories, scrolling without selection, and immediate
row deletion after a data-source update. `UIViewController.navigationController`
and presentation/dismissal relationships support a basic `UIAlertController`
with action handlers and completion callbacks in a separate desktop window.
`Tests/PlaygroundTests.m` exercises these behaviors; this is not full UIKit parity.

Current limits: row-update animations and swipe-to-delete UI are not implemented;
alert presentation uses desktop windows rather than iOS modal transitions or
popover/action-sheet placement. Keyboard dismissal ends editing on desktop wheel
scrolling, without interactive software-keyboard tracking. Preferred Title 1 uses
28 points; content-size-category adjustment and accessibility labels/identifiers
are stored, without Dynamic Type notifications or native accessibility bridging.
Progress styles share the native progress-bar appearance. Other stack distributions
and baseline alignment retain the existing limited layout behavior.


## Expanded widget catalog

The catalog additions include navigation items and bar buttons, toolbars and tab
bars, search fields with result-update callbacks, date/calendar pickers, multi-column
pickers, page controls, and refreshing state. Subtitle table cells support text,
images, section titles and width-dependent automatic row sizing. Tables and
collections load their data at layout time; register reusable cells before the
first layout. Automatic table sizing currently measures every row on reload;
fixed-height lists retain cell virtualization and binary-search visible rows.

Page controllers support programmatic single-page replacement. Split controllers
lay out their child controllers in columns. Color and font pickers use native
controls, and activity presentation offers text copying to the desktop clipboard.
The additional long-press and swipe recognizers process pointer input. Pinch and
rotation recognizers process two-touch sets, but the desktop mouse backend does
not generate multitouch input.

`Tests/CatalogTests.m` checks navigation drawing and actions, search callbacks,
width-dependent subtitle sizing, native picker actions, calendar selection,
spinner state and controller containment. A separate integration smoke run loaded
all 49 live views in UIKitTest's expanded catalog and opened its controller demos;
that is a loading/presentation check, not certification of every interaction.

Known limits of this subset:

- `UIView.layer` is a **UIViewLayer AppKit drawing bridge**, not `CALayer` or a Core
  Animation implementation. It rounds the background; rounded clipping of native
  subviews and animations remain unsupported. `masksToBounds` uses rectangular
  clipping.
- Visual effects use translucent light/dark fills. GNUstep's native visual-effect
  view does not render backdrop blur. System images currently provide drawn
  fallback glyphs for `hand.tap`, `doc.text` and `photo.artframe`; other names return
  nil. These are not SF Symbols assets.
- Preferred text styles use fixed desktop font sizes. Dynamic Type and native
  accessibility bridging remain unimplemented; the associated properties store
  metadata. Button labels forward font and wrapping settings to native buttons.
- Table grouped styles share the plain geometry; Value1/Value2 cells currently use
  subtitle geometry. Pickers use popup menus or native date fields/calendar views
  instead of wheel presentations. Countdown mode is explicitly unsupported.
- Search updating in the existing controller works; separate search-results
  presentation and background obscuring are not implemented. Navigation search
  bars stay visible. Toolbars divide available space equally among their items.
- Presentations use desktop windows. Modal style, presentation context and popover
  source properties are stored but do not implement iOS transition/placement
  behavior. Page transitions are immediate; interactive page swiping and page curl
  are not implemented. Split columns use equal widths and do not implement adaptive
  iOS display modes. Activity controllers support text copy, not the full share
  sheet or custom activities.
- Refreshing is triggered by upward wheel input at the top of a table; it does not
  implement elastic touch scrolling. Programmatic `beginRefreshing` does not emit
  a value-change action.
