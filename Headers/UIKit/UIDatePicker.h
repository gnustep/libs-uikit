#ifndef GNUSTEP_UIKIT_UIDATEPICKER_H
#define GNUSTEP_UIKIT_UIDATEPICKER_H
#import <UIKit/UIControl.h>
typedef NSInteger UIDatePickerMode;
enum { UIDatePickerModeTime, UIDatePickerModeDate, UIDatePickerModeDateAndTime, UIDatePickerModeCountDownTimer };
typedef NSInteger UIDatePickerStyle;
enum { UIDatePickerStyleAutomatic, UIDatePickerStyleWheels, UIDatePickerStyleCompact, UIDatePickerStyleInline };
@interface UIDatePicker : UIControl
{ id _datePicker; UIDatePickerMode _datePickerMode; UIDatePickerStyle _preferredDatePickerStyle; }
@property(nonatomic) UIDatePickerMode datePickerMode;
@property(nonatomic) UIDatePickerStyle preferredDatePickerStyle;
@property(nonatomic, copy) NSDate *date;
@property(nonatomic, copy) NSDate *minimumDate;
@property(nonatomic, copy) NSDate *maximumDate;
- (void)setDate:(NSDate *)date animated:(BOOL)animated;
@end
#endif
