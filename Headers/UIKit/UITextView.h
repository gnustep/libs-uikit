#ifndef GNUSTEP_UIKIT_UITEXTVIEW_H
#define GNUSTEP_UIKIT_UITEXTVIEW_H

#import <UIKit/UIScrollView.h>

@class UIColor, UIFont;

@interface UITextView : UIScrollView
{
  id _textView;
  UIFont *_font;
  UIColor *_textColor;
}
- (NSString *)text;
- (void)setText:(NSString *)text;
- (UIFont *)font;
- (void)setFont:(UIFont *)font;
- (UIColor *)textColor;
- (void)setTextColor:(UIColor *)color;
@end

#endif
