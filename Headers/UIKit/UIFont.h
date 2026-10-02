#ifndef GNUSTEP_UIKIT_UIFONT_H
#define GNUSTEP_UIKIT_UIFONT_H

#import <UIKit/UIKitTypes.h>

typedef NSString *UIFontTextStyle;
extern UIFontTextStyle const UIFontTextStyleLargeTitle;
extern UIFontTextStyle const UIFontTextStyleTitle2;
extern UIFontTextStyle const UIFontTextStyleTitle3;
extern UIFontTextStyle const UIFontTextStyleHeadline;
extern UIFontTextStyle const UIFontTextStyleSubheadline;
extern UIFontTextStyle const UIFontTextStyleBody;
extern UIFontTextStyle const UIFontTextStyleCallout;
extern UIFontTextStyle const UIFontTextStyleFootnote;
extern UIFontTextStyle const UIFontTextStyleCaption1;
extern UIFontTextStyle const UIFontTextStyleCaption2;
extern UIFontTextStyle const UIFontTextStyleTitle1;

@interface UIFont : NSObject
{
  id _font;
}
+ (UIFont *)preferredFontForTextStyle:(UIFontTextStyle)style;
+ (UIFont *)systemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize;
- (CGFloat)pointSize;
- (NSString *)fontName;
- (CGFloat)lineHeight;
@end

#endif
