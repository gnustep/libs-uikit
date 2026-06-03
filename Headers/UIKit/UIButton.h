#ifndef GNUSTEP_UIKIT_UIBUTTON_H
#define GNUSTEP_UIKIT_UIBUTTON_H

#import <UIKit/UIControl.h>

@interface UIButton : UIControl
{
  NSButton *_button;
}
+ (UIButton *)buttonWithType:(int)buttonType;
- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (NSString *)titleForState:(UIControlState)state;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;
@end

#endif
