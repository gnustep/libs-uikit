#ifndef GNUSTEP_UIKIT_UISLIDER_H
#define GNUSTEP_UIKIT_UISLIDER_H

#import <UIKit/UIControl.h>

@interface UISlider : UIControl
{
  NSSlider *_slider;
}
- (float)value;
- (void)setValue:(float)value;
- (float)minimumValue;
- (void)setMinimumValue:(float)value;
- (float)maximumValue;
- (void)setMaximumValue:(float)value;
@end

#endif
