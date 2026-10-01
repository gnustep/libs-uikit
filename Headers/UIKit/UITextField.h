#ifndef GNUSTEP_UIKIT_UITEXTFIELD_H
#define GNUSTEP_UIKIT_UITEXTFIELD_H

#import <UIKit/UIControl.h>

@class UIColor, UIFont, UITextField;
extern NSString *UITextFieldTextDidBeginEditingNotification;
extern NSString *UITextFieldTextDidChangeNotification;
extern NSString *UITextFieldTextDidEndEditingNotification;
@protocol UITextFieldDelegate <NSObject>
@optional
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
@end

@interface UITextField : UIControl
{
  id _textField;
  id<UITextFieldDelegate> _delegate;
  BOOL _editing;
  NSString *_placeholder;
  BOOL _secureTextEntry;
  NSTextAlignment _textAlignment;
}
@property(nonatomic, assign) id<UITextFieldDelegate> delegate;
@property(nonatomic, readonly, getter=isEditing) BOOL editing;
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
