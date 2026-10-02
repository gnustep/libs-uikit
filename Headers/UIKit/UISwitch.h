#ifndef GNUSTEP_UIKIT_UISWITCH_H
#define GNUSTEP_UIKIT_UISWITCH_H

#import <UIKit/UIControl.h>

@interface UISwitch : UIControl
{
  id _switchButton;
}
@property(nonatomic, getter=isOn) BOOL on;
- (BOOL)isOn;
- (void)setOn:(BOOL)on;
@end

#endif
