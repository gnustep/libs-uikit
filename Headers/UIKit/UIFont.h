#ifndef GNUSTEP_UIKIT_UIFONT_H
#define GNUSTEP_UIKIT_UIFONT_H

#import <UIKit/UIKitTypes.h>

@interface UIFont : NSObject
{
  NSFont *_font;
}
+ (UIFont *)systemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize;
- (CGFloat)pointSize;
- (NSString *)fontName;
- (CGFloat)lineHeight;
- (NSFont *)NSFont;
@end

#endif
