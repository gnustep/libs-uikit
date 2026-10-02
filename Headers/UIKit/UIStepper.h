#ifndef GNUSTEP_UIKIT_UISTEPPER_H
#define GNUSTEP_UIKIT_UISTEPPER_H
#import <UIKit/UIControl.h>
@interface UIStepper : UIControl
{
  id _stepper;
}
@property(nonatomic) double value;
@property(nonatomic) double minimumValue;
@property(nonatomic) double maximumValue;
@property(nonatomic) double stepValue;
@property(nonatomic) BOOL wraps;
@property(nonatomic) BOOL autorepeat;
@property(nonatomic, getter=isContinuous) BOOL continuous;
@end
#endif
