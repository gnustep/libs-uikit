# UIKit Implementation Gaps

This document summarizes the current public UIKit-style surface in this
repository and the major UIKit class families that are not implemented yet.

`libs-uikit` targets unchanged Objective-C UIKit application source, using private
GNUstep/AppKit peers. It is not currently a complete UIKit implementation. See
[SOURCE-COMPATIBILITY.md](SOURCE-COMPATIBILITY.md) for the contract and remaining gates.

See [the core coverage matrix](RELEASE-MILESTONE-1.md) for behavior verified
by tests and the release gates that remain. A public header does not imply full
UIKit compatibility.

## Current Public Surface

The current implementation exposes these public UIKit-style headers through
`Headers/UIKit/UIKit.h` and builds matching source files from `Source/GNUmakefile`:

- Application and environment: `UIApplication`, `UIResponder`, `UIScreen`,
  `UIDevice`
- View hierarchy: `UIView`, `UIWindow`, `UIViewController`
- Drawing resources: `UIColor`, `UIImage`, `UIFont`
- Display views: `UILabel`, `UIImageView`
- Controls: `UIControl`, `UIButton`, `UITextField`, `UITextView`, `UISlider`,
  `UISwitch`, `UISegmentedControl`
- Scrolling and lists: `UIScrollView`, `UITableView`, `UITableViewCell`,
  `NSIndexPath` UIKit helpers
- Collections: `UICollectionView`, `UICollectionViewCell`,
  `UICollectionViewLayout`, `UICollectionViewLayoutAttributes`,
  `UICollectionViewFlowLayout`
- Containers and layout: `UIStackView`, `UINavigationItem`,
  `UINavigationController`, `UITabBarController`
- Indicators and alerts: `UIActivityIndicatorView`, `UIAlertView`
- Loading helpers: `UINib`, `NSBundle` UIKit helpers
`UIOpenGLView` is an explicit GNUstep extension, outside the UIKit umbrella.

## Missing Class Families

The following sections list important UIKit areas that are currently absent from
the public implementation. The lists are representative, not exhaustive.

### App Lifecycle, Events, and Scenes

`UIEvent`, `UITouch`, `UIPress`, `UIPressesEvent`, `UIScene`, `UIWindowScene`,
`UISceneSession`, and `UISceneConfiguration` are present. The desktop core now
tracks mouse-backed touches through UIView and delivers basic scene state
callbacks. These are partial implementations: multitouch, keyboard/focus delivery,
independent scene sessions, restoration, and mobile lifecycle services remain.

### View Controllers and Presentation

- `UISplitViewController`
- `UIPageViewController`
- `UIAlertController`
- `UIActivityViewController`
- `UIDocumentPickerViewController`
- `UIImagePickerController`
- `UIPopoverPresentationController`
- `UIPresentationController`

The implementation has base, navigation, tab, table, and collection controllers.
The list controllers provide lazy view creation, delegate/data-source wiring,
appearance reloads and selection clearing. Modal presentation and the controller
types listed above remain absent.

### Bars, Items, and Navigation UI

- `UINavigationBar`
- `UITabBar`
- `UITabBarItem`
- `UIToolbar`
- `UIBarItem`
- `UIBarButtonItem`
- `UISearchController`

`UINavigationController`, `UINavigationItem`, and `UITabBarController` exist,
but their related bar and item view classes are not implemented as standalone
public API.

### Controls and Common Views

- `UIPageControl`
- `UIStepper`
- `UIDatePicker`
- `UIPickerView`
- `UIProgressView`
- `UISearchBar`
- `UIRefreshControl`
- `UIVisualEffectView`
- `UIBlurEffect`
- `UIVibrancyEffect`

The current controls cover basic buttons, text entry, sliders, switches, and
segmented controls. Many standard UIKit controls and visual effect views remain
absent.

### Gesture Recognizers and Interactions

- `UISwipeGestureRecognizer`
- `UILongPressGestureRecognizer`
- `UIPinchGestureRecognizer`
- `UIRotationGestureRecognizer`
- `UIDragInteraction`
- `UIDropInteraction`
- `UIContextMenuInteraction`
- `UIPointerInteraction`
- `UIFocusGuide`

The desktop core provides basic `UIGestureRecognizer`, `UITapGestureRecognizer`,
and `UIPanGestureRecognizer` support on UIView content. Multitouch, recognizer
arbitration/failure dependencies, native-control interception, and the interaction
APIs above remain unimplemented.

### Layout, Traits, and Appearance

- `UITraitCollection`
- `UIAppearance`
- `UIBarAppearance`
- `UINavigationBarAppearance`
- `UITabBarAppearance`

The implementation includes `UIStackView` and a first constraint-layout subset:
anchors, dimension multipliers, equalities/inequalities, mutable constants and
priorities, activation on common ancestors, custom guides, layout margins,
desktop safe-area guides, and intrinsic-size hugging/compression priorities.
Labels, buttons and text fields supply intrinsic sizes. XML XIB constraints use
the same engine.

This is not complete Auto Layout. Visual Format Language, baseline/margin
attributes, RTL-aware leading/trailing, fitting-size APIs, full autoresizing-mask
constraint translation, multiline intrinsic-height negotiation and incremental
solver performance remain. Optional constraints are admitted greedily by priority
and insertion order; they do not minimize aggregate error within a priority tier.
Safe-area insets are currently zero for desktop view content, without propagation
of controller bars, occlusion or additional safe-area insets. Traits and appearance
APIs remain absent.

Public `NSLayoutConstraint` and anchor names are compile-time aliases to UIKit
runtime classes so they do not collide with GNUstep AppKit's native classes.
Runtime lookup by Apple class-name strings and constraint archive decoding are
not covered by this source-compatibility implementation.

### Drawing, Text, and Fonts

- `UIBezierPath`
- `UIFontDescriptor`
- `NSTextStorage`
- `NSLayoutManager`
- `NSTextContainer`
- Text input accessory and input view management classes

The implementation has `UIColor`, `UIImage`, `UIFont`, `UILabel`, `UITextField`
and `UITextView`. Text editing now forwards begin/end permission, character-change
vetoes and editing callbacks to UIKit delegates; text fields also support Return
permission. Text views expose attributed text, selection, editability and
selectability. Full UITextInput/TextKit, keyboard traits, IME qualification,
attributed labels and broader UIKit drawing APIs remain incomplete.

### Documents, Pasteboard, Printing, and Sharing

- `UIPasteboard`
- `UIDocument`
- `UIDocumentInteractionController`
- `UIPrintInteractionController`
- `UIPrintInfo`
- `UIActivity`
- `UIActivityItemProvider`

Document workflows, pasteboard integration, printing, and activity/sharing
classes are not currently implemented.

### Accessibility and Input Support

- `UIAccessibilityElement`
- `UIAccessibilityCustomAction`
- `UIAccessibilityCustomRotor`
- `UIInputView`
- `UIInputViewController`
- `UIKeyCommand`
- `UITextInputMode`

Accessibility object modeling, custom input views, keyboard command handling,
and related input APIs are not currently exposed.

## Notes for Future Work

- Keep this document aligned with `Headers/UIKit/UIKit.h`; that umbrella header
  is the clearest statement of the current public surface.
- Add new sections only when they represent a meaningful UIKit area, not every
  missing class one by one.
- Prefer implementing coherent class families together, such as gesture
  recognizers plus view integration, or bar item classes plus navigation/tab bar
  rendering.
