#ifndef GNUSTEP_UIKIT_UILABEL_H
#define GNUSTEP_UIKIT_UILABEL_H

#import <UIKit/UIView.h>

@class UIColor, UIFont;

@interface UILabel : UIView
{
  id _textField;
  NSTextAlignment _textAlignment;
  NSInteger _numberOfLines;
  BOOL _adjustsFontForContentSizeCategory;
}
@property(nonatomic) BOOL adjustsFontForContentSizeCategory;
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
