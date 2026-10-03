#ifndef GNUSTEP_UIKIT_UIBUTTON_H
#define GNUSTEP_UIKIT_UIBUTTON_H

#import <UIKit/UIControl.h>

@class UILabel, UIMenu;
@interface UIButton : UIControl
{
  UILabel *_titleLabel;
  UIMenu *_menu; BOOL _showsMenuAsPrimaryAction;
  id _button;
  NSMutableDictionary *_titles;
}
@property(nonatomic, retain) UIMenu *menu;
@property(nonatomic) BOOL showsMenuAsPrimaryAction;
@property(nonatomic, readonly) UILabel *titleLabel;
+ (UIButton *)buttonWithType:(int)buttonType;
- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (NSString *)titleForState:(UIControlState)state;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;
@end

#endif
