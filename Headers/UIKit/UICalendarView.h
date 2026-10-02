#ifndef GNUSTEP_UIKIT_UICALENDARVIEW_H
#define GNUSTEP_UIKIT_UICALENDARVIEW_H
#import <UIKit/UIView.h>
@class UICalendarSelectionSingleDate;
@protocol UICalendarSelectionSingleDateDelegate <NSObject>
@optional
- (void)dateSelection:(UICalendarSelectionSingleDate *)selection didSelectDate:(NSDateComponents *)dateComponents;
- (BOOL)dateSelection:(UICalendarSelectionSingleDate *)selection canSelectDate:(NSDateComponents *)dateComponents;
@end
@interface UICalendarSelectionSingleDate : NSObject
{ id<UICalendarSelectionSingleDateDelegate> _delegate; NSDateComponents *_selectedDate; id _calendarView; }
- (id)initWithDelegate:(id<UICalendarSelectionSingleDateDelegate>)delegate;
@property(nonatomic, readonly, assign) id<UICalendarSelectionSingleDateDelegate> delegate;
@property(nonatomic, copy) NSDateComponents *selectedDate;
- (void)setSelectedDate:(NSDateComponents *)date animated:(BOOL)animated;
@end
@interface UICalendarView : UIView
{ id _datePicker; UICalendarSelectionSingleDate *_selectionBehavior; }
@property(nonatomic, retain) UICalendarSelectionSingleDate *selectionBehavior;
@end
#endif
