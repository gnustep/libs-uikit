#import <UIKit/UIKit.h>

@interface UIColor (UIKitPrivate)
+ (UIColor *)_colorWithNSColor:(NSColor *)color;
@end

@interface UIFont (UIKitPrivate)
+ (UIFont *)_fontWithNSFont:(NSFont *)font;
@end

static inline NSAutoresizingMaskOptions
UIKitAutoresizingMaskToAppKit(UIViewAutoresizing mask)
{
  NSAutoresizingMaskOptions appKitMask = 0;

  if ((mask & UIViewAutoresizingFlexibleWidth) != 0)
    appKitMask |= NSViewWidthSizable;
  if ((mask & UIViewAutoresizingFlexibleHeight) != 0)
    appKitMask |= NSViewHeightSizable;
  if ((mask & UIViewAutoresizingFlexibleLeftMargin) != 0)
    appKitMask |= NSViewMinXMargin;
  if ((mask & UIViewAutoresizingFlexibleRightMargin) != 0)
    appKitMask |= NSViewMaxXMargin;
  if ((mask & UIViewAutoresizingFlexibleBottomMargin) != 0)
    appKitMask |= NSViewMinYMargin;
  if ((mask & UIViewAutoresizingFlexibleTopMargin) != 0)
    appKitMask |= NSViewMaxYMargin;

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
