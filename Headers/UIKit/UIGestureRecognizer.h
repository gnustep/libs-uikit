#ifndef GNUSTEP_UIKIT_UIGESTURERECOGNIZER_H
#define GNUSTEP_UIKIT_UIGESTURERECOGNIZER_H
#import <UIKit/UIKitTypes.h>
@class UIView, UIEvent;
typedef NSInteger UIGestureRecognizerState;
enum {
  UIGestureRecognizerStatePossible, UIGestureRecognizerStateBegan,
  UIGestureRecognizerStateChanged, UIGestureRecognizerStateEnded,
  UIGestureRecognizerStateCancelled, UIGestureRecognizerStateFailed,
  UIGestureRecognizerStateRecognized = UIGestureRecognizerStateEnded
};
@interface UIGestureRecognizer : NSObject
{
  UIView *_view;
  NSMutableArray *_gestureTargets;
  UIGestureRecognizerState _state;
  BOOL _enabled;
  BOOL _cancelsTouchesInView;
  CGPoint _location;
}
- (id)initWithTarget:(id)target action:(SEL)action;
- (void)addTarget:(id)target action:(SEL)action;
- (void)removeTarget:(id)target action:(SEL)action;
- (UIView *)view;
- (UIGestureRecognizerState)state;
- (void)setState:(UIGestureRecognizerState)state;
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)cancelsTouchesInView;
- (void)setCancelsTouchesInView:(BOOL)cancels;
- (CGPoint)locationInView:(UIView *)view;
- (void)reset;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end
#endif
