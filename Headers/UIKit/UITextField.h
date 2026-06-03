#ifndef GNUSTEP_UIKIT_UITEXTFIELD_H
#define GNUSTEP_UIKIT_UITEXTFIELD_H

#import <UIKit/UIControl.h>

@class UIColor, UIFont;

@interface UITextField : UIControl
{
  NSTextField *_textField;
  NSString *_placeholder;
  BOOL _secureTextEntry;
  NSTextAlignment _textAlignment;
}
- (NSString *)text;
- (void)setText:(NSString *)text;
- (NSString *)placeholder;
- (void)setPlaceholder:(NSString *)placeholder;
- (UIColor *)textColor;
- (void)setTextColor:(UIColor *)color;
- (UIFont *)font;
- (void)setFont:(UIFont *)font;
- (BOOL)isSecureTextEntry;
- (void)setSecureTextEntry:(BOOL)secureTextEntry;
- (NSTextAlignment)textAlignment;
- (void)setTextAlignment:(NSTextAlignment)alignment;
@end

#endif
