#import "UIKitPrivate.h"
#import <UIKit/UIKit.h>
#include <math.h>

@implementation UIGestureRecognizer
- (id)init { return [self initWithTarget:nil action:NULL]; }
- (id)initWithTarget:(id)target action:(SEL)action
{
  self = [super init];
  if (self) { _gestureTargets = [NSMutableArray new]; _enabled = YES; _cancelsTouchesInView = YES; if (target && action) [self addTarget:target action:action]; }
  return self;
}
- (void)dealloc { [_gestureTargets release]; [super dealloc]; }
- (void)addTarget:(id)target action:(SEL)action
{
  if (!target || !action) return;
  [_gestureTargets addObject:[NSArray arrayWithObjects:[NSValue valueWithNonretainedObject:target], NSStringFromSelector(action), nil]];
}
- (void)removeTarget:(id)target action:(SEL)action
{
  for (NSArray *entry in [[_gestureTargets copy] autorelease])
    if ((!target || [[entry objectAtIndex:0] nonretainedObjectValue] == target) && (!action || NSSelectorFromString([entry objectAtIndex:1]) == action))
      [_gestureTargets removeObjectIdenticalTo:entry];
}
- (UIView *)view { return _view; }
- (void)_setView:(UIView *)view { _view = view; }
- (UIGestureRecognizerState)state { return _state; }
- (void)setState:(UIGestureRecognizerState)state
{
  _state = state;
  if (state == UIGestureRecognizerStatePossible || state == UIGestureRecognizerStateFailed) return;
  for (NSArray *entry in [[_gestureTargets copy] autorelease]) {
    id target = [[entry objectAtIndex:0] nonretainedObjectValue];
    SEL action = NSSelectorFromString([entry objectAtIndex:1]);
    if ([target respondsToSelector:action]) [target performSelector:action withObject:self];
  }
}
- (BOOL)isEnabled { return _enabled; }
- (void)setEnabled:(BOOL)enabled
{
  if (_enabled && !enabled && (_state == UIGestureRecognizerStateBegan || _state == UIGestureRecognizerStateChanged)) [self setState:UIGestureRecognizerStateCancelled];
  _enabled = enabled;
}
- (BOOL)cancelsTouchesInView { return _cancelsTouchesInView; }
- (void)setCancelsTouchesInView:(BOOL)cancels { _cancelsTouchesInView = cancels; }
- (CGPoint)locationInView:(UIView *)view { return view ? [view convertPoint:_location fromView:nil] : _location; }
- (void)reset { _state = UIGestureRecognizerStatePossible; }
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { _location = [[touches anyObject] locationInView:nil]; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { _location = [[touches anyObject] locationInView:nil]; }
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { _location = [[touches anyObject] locationInView:nil]; }
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event { [self setState:UIGestureRecognizerStateCancelled]; }
@end

@implementation UITapGestureRecognizer
- (id)initWithTarget:(id)target action:(SEL)action
{
  self = [super initWithTarget:target action:action]; if (self) _numberOfTapsRequired = 1; return self;
}
- (NSUInteger)numberOfTapsRequired { return _numberOfTapsRequired; }
- (void)setNumberOfTapsRequired:(NSUInteger)count { _numberOfTapsRequired = MAX(1, count); }
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { [super touchesBegan:touches withEvent:event]; _start = _location; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
  if (hypot(_location.x - _start.x, _location.y - _start.y) > 10) [self setState:UIGestureRecognizerStateFailed];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
  if (_state == UIGestureRecognizerStatePossible)
    [self setState:([[touches anyObject] tapCount] == _numberOfTapsRequired ? UIGestureRecognizerStateRecognized : UIGestureRecognizerStateFailed)];
}
@end

@implementation UIPanGestureRecognizer
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event]; _start = _previous = _location;
  _velocity = CGPointZero; _previousTimestamp = [event timestamp];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
  NSTimeInterval dt = [event timestamp] - _previousTimestamp;
  if (dt > 0) _velocity = CGPointMake((_location.x - _previous.x) / dt, (_location.y - _previous.y) / dt);
  _previous = _location; _previousTimestamp = [event timestamp];
  if (_state == UIGestureRecognizerStatePossible && hypot(_location.x - _start.x, _location.y - _start.y) >= 3)
    [self setState:UIGestureRecognizerStateBegan];
  else if (_state == UIGestureRecognizerStateBegan || _state == UIGestureRecognizerStateChanged)
    [self setState:UIGestureRecognizerStateChanged];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
  [self setState:(_state == UIGestureRecognizerStateBegan || _state == UIGestureRecognizerStateChanged) ? UIGestureRecognizerStateEnded : UIGestureRecognizerStateFailed];
}
- (CGPoint)translationInView:(UIView *)view
{
  CGPoint start = view ? [view convertPoint:_start fromView:nil] : _start;
  CGPoint current = [self locationInView:view];
  return CGPointMake(current.x - start.x, current.y - start.y);
}
- (void)setTranslation:(CGPoint)translation inView:(UIView *)view
{
  CGPoint current = [self locationInView:view];
  CGPoint origin = CGPointMake(current.x - translation.x, current.y - translation.y);
  _start = view ? [view convertPoint:origin toView:nil] : origin;
}
- (CGPoint)velocityInView:(UIView *)view
{
  if (!view) return _velocity;
  CGPoint zero = [view convertPoint:CGPointZero fromView:nil];
  CGPoint vector = [view convertPoint:_velocity fromView:nil];
  return CGPointMake(vector.x - zero.x, vector.y - zero.y);
}
@end
