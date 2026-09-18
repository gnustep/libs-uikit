#ifndef GNUSTEP_UIKIT_UITOUCH_H
#define GNUSTEP_UIKIT_UITOUCH_H

#import <UIKit/UIKitTypes.h>

@class UIView, UIWindow;

typedef int UITouchPhase;
enum {
  UITouchPhaseBegan = 0,
  UITouchPhaseMoved = 1,
  UITouchPhaseStationary = 2,
  UITouchPhaseEnded = 3,
  UITouchPhaseCancelled = 4,
  UITouchPhaseRegionEntered = 5,
  UITouchPhaseRegionMoved = 6,
  UITouchPhaseRegionExited = 7
};

@interface UITouch : NSObject
{
  NSTimeInterval _timestamp;
  NSUInteger _tapCount;
  UITouchPhase _phase;
  CGPoint _locationInWindow;
  CGPoint _previousLocationInWindow;
  UIWindow *_window;
  UIView *_view;
  id _NSEvent;
}
- (id)initWithLocation:(CGPoint)location
              inWindow:(UIWindow *)window
                  view:(UIView *)view
                 phase:(UITouchPhase)phase
              tapCount:(NSUInteger)tapCount
             timestamp:(NSTimeInterval)timestamp;
- (NSTimeInterval)timestamp;
- (NSUInteger)tapCount;
- (UITouchPhase)phase;
- (void)setPhase:(UITouchPhase)phase;
- (UIWindow *)window;
- (UIView *)view;
- (CGPoint)locationInView:(UIView *)view;
- (CGPoint)previousLocationInView:(UIView *)view;
@end

#endif
