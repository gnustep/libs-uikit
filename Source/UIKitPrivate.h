#import <UIKit/UIKit.h>

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
