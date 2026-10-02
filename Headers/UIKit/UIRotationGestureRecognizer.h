#ifndef GNUSTEP_UIKIT_UIROTATIONGESTURERECOGNIZER_H
#define GNUSTEP_UIKIT_UIROTATIONGESTURERECOGNIZER_H
#import <UIKit/UIGestureRecognizer.h>
@interface UIRotationGestureRecognizer : UIGestureRecognizer
{ CGFloat _rotation, _velocity, _initialAngle, _previousRotation; NSTimeInterval _previousTime; }
@property(nonatomic) CGFloat rotation;
@property(nonatomic, readonly) CGFloat velocity;
@end
#endif
