#ifndef GNUSTEP_UIKIT_UIPANGESTURERECOGNIZER_H
#define GNUSTEP_UIKIT_UIPANGESTURERECOGNIZER_H
#import <UIKit/UIGestureRecognizer.h>
@interface UIPanGestureRecognizer : UIGestureRecognizer
{
  CGPoint _start;
  CGPoint _previous;
  CGPoint _velocity;
  NSTimeInterval _previousTimestamp;
}
- (CGPoint)translationInView:(UIView *)view;
- (void)setTranslation:(CGPoint)translation inView:(UIView *)view;
- (CGPoint)velocityInView:(UIView *)view;
@end
#endif
