#ifndef GNUSTEP_UIKIT_UILONGPRESSGESTURERECOGNIZER_H
#define GNUSTEP_UIKIT_UILONGPRESSGESTURERECOGNIZER_H
#import <UIKit/UIGestureRecognizer.h>
@interface UILongPressGestureRecognizer : UIGestureRecognizer
{ NSTimeInterval _minimumPressDuration; CGFloat _allowableMovement; CGPoint _start; }
@property(nonatomic) NSTimeInterval minimumPressDuration;
@property(nonatomic) CGFloat allowableMovement;
@end
#endif
