#ifndef GNUSTEP_UIKIT_UISEGMENTEDCONTROL_H
#define GNUSTEP_UIKIT_UISEGMENTEDCONTROL_H

#import <UIKit/UIControl.h>

@interface UISegmentedControl : UIControl
{
  NSSegmentedControl *_segmentedControl;
}
- (id)initWithItems:(NSArray *)items;
- (NSUInteger)numberOfSegments;
- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment;
- (NSInteger)selectedSegmentIndex;
- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex;
@end

#endif
