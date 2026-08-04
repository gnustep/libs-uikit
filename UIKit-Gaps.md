# UIKit Implementation Gaps

This document summarizes the current public UIKit-style surface in this
repository and the major UIKit class families that are not implemented yet.

`libs-uikit` is intentionally a focused UIKit-like compatibility layer on top of
GNUstep/AppKit. It is not currently a complete UIKit clone.

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
- GNUstep-specific compatibility: `UIOpenGLView`

## Missing Class Families

The following sections list important UIKit areas that are currently absent from
the public implementation. The lists are representative, not exhaustive.

### App Lifecycle, Events, and Scenes

- `UIEvent`
- `UITouch`
- `UIPress`
- `UIPressesEvent`
- `UIScene`
- `UIWindowScene`
- `UISceneSession`
- `UISceneConfiguration`

The current implementation has `UIApplication`, `UIWindow`, and `UIResponder`,
but does not expose UIKit's event object model or modern scene lifecycle.

### View Controllers and Presentation

- `UITableViewController`
- `UICollectionViewController`
- `UISplitViewController`
- `UIPageViewController`
- `UIAlertController`
- `UIActivityViewController`
- `UIDocumentPickerViewController`
- `UIImagePickerController`
- `UIPopoverPresentationController`
- `UIPresentationController`

The current implementation has base, navigation, and tab view controllers, but
does not include many common UIKit controller subclasses or presentation
controller types.

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

- `UIGestureRecognizer`
- `UITapGestureRecognizer`
- `UIPanGestureRecognizer`
- `UISwipeGestureRecognizer`
- `UILongPressGestureRecognizer`
- `UIPinchGestureRecognizer`
- `UIRotationGestureRecognizer`
- `UIDragInteraction`
- `UIDropInteraction`
- `UIContextMenuInteraction`
- `UIPointerInteraction`
- `UIFocusGuide`

The current implementation does not expose UIKit's gesture recognizer system or
modern interaction APIs.

### Layout, Traits, and Appearance

- `UILayoutGuide`
- `NSLayoutConstraint` UIKit integration
- `UITraitCollection`
- `UIAppearance`
- `UIBarAppearance`
- `UINavigationBarAppearance`
- `UITabBarAppearance`

The current implementation includes `UIStackView`, but does not expose UIKit's
layout guide, trait collection, or appearance-customization APIs.

### Drawing, Text, and Fonts

- `UIBezierPath`
- `UIFontDescriptor`
- `NSTextStorage`
- `NSLayoutManager`
- `NSTextContainer`
- Text input accessory and input view management classes

The current implementation has `UIColor`, `UIImage`, `UIFont`, `UILabel`,
`UITextField`, and `UITextView`, but does not expose broader UIKit drawing or
TextKit-style APIs.

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
