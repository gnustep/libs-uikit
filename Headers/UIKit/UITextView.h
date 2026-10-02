#ifndef GNUSTEP_UIKIT_UITEXTVIEW_H
#define GNUSTEP_UIKIT_UITEXTVIEW_H

#import <UIKit/UIScrollView.h>

@class UIColor, UIFont, UITextView;
extern NSString *UITextViewTextDidBeginEditingNotification;
extern NSString *UITextViewTextDidChangeNotification;
extern NSString *UITextViewTextDidEndEditingNotification;
@protocol UITextViewDelegate <UIScrollViewDelegate>
@optional
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
- (BOOL)textViewShouldEndEditing:(UITextView *)textView;
- (void)textViewDidBeginEditing:(UITextView *)textView;
- (void)textViewDidEndEditing:(UITextView *)textView;
- (void)textViewDidChange:(UITextView *)textView;
- (void)textViewDidChangeSelection:(UITextView *)textView;
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
@end

@interface UITextView : UIScrollView
{
  BOOL _adjustsFontForContentSizeCategory;
  id _textView;
  UIFont *_font;
  UIColor *_textColor;
  BOOL _uiSettingText;
  NSTextAlignment _textAlignment;
}
@property(nonatomic) BOOL adjustsFontForContentSizeCategory;
@property(nonatomic, assign) id<UITextViewDelegate> delegate;
@property(nonatomic, getter=isEditable) BOOL editable;
@property(nonatomic, getter=isSelectable) BOOL selectable;
@property(nonatomic) NSRange selectedRange;
@property(nonatomic, copy) NSAttributedString *attributedText;
@property(nonatomic) NSTextAlignment textAlignment;
- (NSString *)text;
- (void)setText:(NSString *)text;
- (UIFont *)font;
- (void)setFont:(UIFont *)font;
- (UIColor *)textColor;
- (void)setTextColor:(UIColor *)color;
@end

#endif
