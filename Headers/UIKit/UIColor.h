#ifndef GNUSTEP_UIKIT_UICOLOR_H
#define GNUSTEP_UIKIT_UICOLOR_H

#import <UIKit/UIKitTypes.h>

@interface UIColor : NSObject <NSCopying>
{
  NSColor *_color;
}
+ (UIColor *)blackColor;
+ (UIColor *)whiteColor;
+ (UIColor *)clearColor;
+ (UIColor *)redColor;
+ (UIColor *)greenColor;
+ (UIColor *)blueColor;
+ (UIColor *)grayColor;
+ (UIColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (NSColor *)NSColor;
@end

#endif
