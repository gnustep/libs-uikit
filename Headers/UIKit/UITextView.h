#ifndef GNUSTEP_UIKIT_UITEXTVIEW_H
#define GNUSTEP_UIKIT_UITEXTVIEW_H

#import <UIKit/UIView.h>

@class UIColor, UIFont;

@interface UITextView : UIView
{
  NSScrollView *_scrollView;
  NSTextView *_textView;
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
