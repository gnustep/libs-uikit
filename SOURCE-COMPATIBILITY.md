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
