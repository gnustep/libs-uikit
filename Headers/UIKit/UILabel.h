#ifndef GNUSTEP_UIKIT_UILABEL_H
#define GNUSTEP_UIKIT_UILABEL_H

#import <UIKit/UIView.h>

@class UIColor, UIFont;

@interface UILabel : UIView
{
  NSTextField *_textField;
  NSTextAlignment _textAlignment;
  NSInteger _numberOfLines;
}
- (NSString *)text;
- (void)setText:(NSString *)text;
- (UIColor *)textColor;
- (void)setTextColor:(UIColor *)color;
- (UIFont *)font;
- (void)setFont:(UIFont *)font;
- (NSTextAlignment)textAlignment;
- (void)setTextAlignment:(NSTextAlignment)alignment;
- (NSInteger)numberOfLines;
- (void)setNumberOfLines:(NSInteger)numberOfLines;
@end

#endif
