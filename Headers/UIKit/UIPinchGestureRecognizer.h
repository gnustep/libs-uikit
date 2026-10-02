#ifndef GNUSTEP_UIKIT_UIPINCHGESTURERECOGNIZER_H
#define GNUSTEP_UIKIT_UIPINCHGESTURERECOGNIZER_H
#import <UIKit/UIGestureRecognizer.h>
@interface UIPinchGestureRecognizer : UIGestureRecognizer
{ CGFloat _scale, _velocity, _initialDistance, _previousScale; NSTimeInterval _previousTime; }
@property(nonatomic) CGFloat scale;
@property(nonatomic, readonly) CGFloat velocity;
@end
#endif
