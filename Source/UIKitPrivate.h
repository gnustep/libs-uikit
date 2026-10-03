#ifndef GNUSTEP_UIKIT_PRIVATE_H
#define GNUSTEP_UIKIT_PRIVATE_H
#import <UIKit/GNUstepUIKit.h>

@interface UIColor (UIKitPrivate)
+ (UIColor *)_colorWithNSColor:(NSColor *)color;
@end

@interface UIFont (UIKitPrivate)
+ (UIFont *)_fontWithNSFont:(NSFont *)font;
@end

static inline NSUInteger
UIKitAutoresizingMaskToAppKit(UIViewAutoresizing mask)
{
  NSUInteger appKitMask = 0;

  if ((mask & UIViewAutoresizingFlexibleWidth) != 0)
    appKitMask |= NSViewWidthSizable;
  if ((mask & UIViewAutoresizingFlexibleHeight) != 0)
    appKitMask |= NSViewHeightSizable;
  if ((mask & UIViewAutoresizingFlexibleLeftMargin) != 0)
    appKitMask |= NSViewMinXMargin;
  if ((mask & UIViewAutoresizingFlexibleRightMargin) != 0)
    appKitMask |= NSViewMaxXMargin;
  if ((mask & UIViewAutoresizingFlexibleBottomMargin) != 0)
    appKitMask |= NSViewMaxYMargin;
  if ((mask & UIViewAutoresizingFlexibleTopMargin) != 0)
    appKitMask |= NSViewMinYMargin;

  return appKitMask;
}

static inline NSTextAlignment
UIKitTextAlignmentFromString(NSString *value)
{
  if ([value isEqualToString:@"center"])
    return NSTextAlignmentCenter;
  if ([value isEqualToString:@"right"])
    return NSTextAlignmentRight;
  if ([value isEqualToString:@"justified"])
    return NSTextAlignmentJustified;
  if ([value isEqualToString:@"natural"])
    return NSTextAlignmentNatural;
  return NSTextAlignmentLeft;
}

static inline NSColor *
UIKitNSColorFromRGBA(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha)
{
  if (red > 1.0 || green > 1.0 || blue > 1.0 || alpha > 1.0)
    return [NSColor colorWithCalibratedRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
  return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

@interface UICollectionViewCell (UIKitReuse)
- (void)_setReuseIdentifier:(NSString *)identifier;
@end

@interface NSTextField (UIKitOptionalNativeAPI)
- (void)setPlaceholderString:(NSString *)string;
- (void)setMaximumNumberOfLines:(NSInteger)count;
@end
@interface NSBundle (UIKitOptionalNibAPI)
- (BOOL)loadNibNamed:(NSString *)name owner:(id)owner topLevelObjects:(NSArray **)objects;
@end

@interface UIGestureRecognizer (UIKitNativeInput)
- (void)_setView:(UIView *)view;
@end
@interface UITouch (UIKitNativeInput)
- (void)_updateWithNSEvent:(NSEvent *)event phase:(UITouchPhase)phase;
@end
@interface UIEvent (UIKitNativeInput)
- (id)_initWithTouch:(UITouch *)touch nativeEvent:(NSEvent *)event;
@end

@interface UIView (UIKitControllerOwnership)
- (void)_setOwningViewController:(id)controller;
@end


@interface _UIKitViewPeer : NSView
{
@public
  UIView *owner; /* non-owning; UIView owns the peer */
  NSTrackingRectTag _trackingRect;
}
@end
@interface _UIKitWindowPeer : NSWindow
{
@public
  UIWindow *owner; /* non-owning; UIWindow owns the peer */
}
@end
@interface UIView (UIKitLayoutInternal)
- (void)_uiInitializeLayout;
- (void)_uiDestroyLayout;
- (void)_uiRemoveAncestorConstraints;
- (void)_uiSolveLayout;
- (void)_uiLayoutPass;
@end
@interface UIView (UIKitBackend)
- (NSView *)_nativeContainerView;
- (NSView *)_nativeCoordinateView;
- (void)_addNativeSubview:(NSView *)view;
- (void)_nativeFrameChanged:(CGRect)frame;
- (void)_sortSubviewsUsingFunction:(NSComparisonResult (*)(id,id,void *))function context:(void *)context;
- (void)_willMoveToWindow:(UIWindow *)window;
- (void)_didMoveToWindow;
- (void)_cancelActiveTouch;
- (void)_deliverMouse:(NSEvent *)event phase:(UITouchPhase)phase;
- (void)mouseDown:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)resizeWithOldSuperviewSize:(CGSize)size;
- (void)_syncNativeSubviewOrder;
@end
@interface UIResponder (UIKitBackend)
- (UIWindow *)_responderWindow;
- (NSResponder *)_nativeResponder;
@end
@interface UIWindow (UIKitBackend)
- (UIResponder *)_firstResponder;
- (BOOL)_makeFirstResponder:(UIResponder *)responder;
- (void)_nativeWindowWillClose;
@end
@interface UIColor (UIKitNativeColor)
- (NSColor *)NSColor;
@end
@interface UIFont (UIKitNativeFont)
- (NSFont *)NSFont;
@end
@interface UIImage (UIKitNativeImage)
- (id)initWithNSImage:(NSImage *)image;
- (NSImage *)NSImage;
@end
@interface UIEvent (UIKitNativeEvent)
+ (UIEvent *)eventWithNSEvent:(NSEvent *)event;
- (id)initWithNSEvent:(NSEvent *)event;
- (NSEvent *)NSEvent;
@end
@interface UITouch (UIKitNativeTouch)
+ (UITouch *)touchWithNSEvent:(NSEvent *)event view:(UIView *)view;
- (NSEvent *)NSEvent;
@end
@interface UIPress (UIKitNativePress)
+ (UIPress *)pressWithNSEvent:(NSEvent *)event responder:(UIResponder *)responder;
- (NSEvent *)NSEvent;
@end
static inline UIWindow *UIKitWindowForNativeWindow(NSWindow *window)
{ return [window isKindOfClass:[_UIKitWindowPeer class]] ? ((_UIKitWindowPeer *)window)->owner : nil; }
static inline GNUstepNSTextAlignment UIKitNativeTextAlignment(NSTextAlignment alignment)
{
  switch (alignment) {
    case NSTextAlignmentCenter: return NSCenterTextAlignment;
    case NSTextAlignmentRight: return NSRightTextAlignment;
    case NSTextAlignmentJustified: return NSJustifiedTextAlignment;
    case NSTextAlignmentNatural: return NSNaturalTextAlignment;
    default: return NSLeftTextAlignment;
  }
}

@interface UIMenu (UIKitNativeMenu)
- (NSMenu *)_nativeMenu;
- (void)_presentInView:(UIView *)view point:(CGPoint)point event:(NSEvent *)event;
@end
@interface UIContextMenuInteraction (UIKitNativeMenu)
- (void)_presentAtPoint:(CGPoint)point event:(NSEvent *)event;
@end
@interface UIView (UIKitContextMenu)
- (void)_contextMenu:(NSEvent *)event;
@end

@interface UIView (UIKitPointerEvents)
- (void)_hoverEvent:(NSEvent *)event state:(UIGestureRecognizerState)state;
- (BOOL)_beginNativeDrag:(NSEvent *)event;
- (NSUInteger)_nativeDrop:(id<NSDraggingInfo>)info perform:(BOOL)perform;
@end

#endif
