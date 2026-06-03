#ifndef GNUSTEP_UIKIT_UISWITCH_H
#define GNUSTEP_UIKIT_UISWITCH_H

#import <UIKit/UIControl.h>

@interface UISwitch : UIControl
{
  NSButton *_switchButton;
}
- (BOOL)isOn;
- (void)setOn:(BOOL)on;
@end

#endif
