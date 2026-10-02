#import "UIKitPrivate.h"
#include <math.h>
@implementation UILongPressGestureRecognizer
@synthesize minimumPressDuration = _minimumPressDuration, allowableMovement = _allowableMovement;
- (id)initWithTarget:(id)target action:(SEL)action { self = [super initWithTarget:target action:action]; if (self) { _minimumPressDuration = 0.5; _allowableMovement = 10; } return self; }
- (void)dealloc { [NSObject cancelPreviousPerformRequestsWithTarget:self]; [super dealloc]; }
- (void)reset { [NSObject cancelPreviousPerformRequestsWithTarget:self]; [super reset]; }
- (void)_setView:(UIView *)view { if (!view) [self reset]; [super _setView:view]; }
- (void)setEnabled:(BOOL)enabled { if (!enabled) [NSObject cancelPreviousPerformRequestsWithTarget:self]; [super setEnabled:enabled]; }
- (void)_pressed { if (_enabled && _state == UIGestureRecognizerStatePossible) [self setState:UIGestureRecognizerStateBegan]; }
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event]; _start = _location;
  [self performSelector:@selector(_pressed) withObject:nil afterDelay:_minimumPressDuration];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  if (hypot(_location.x-_start.x,_location.y-_start.y) > _allowableMovement && _state == UIGestureRecognizerStatePossible) { [NSObject cancelPreviousPerformRequestsWithTarget:self]; [self setState:UIGestureRecognizerStateFailed]; }
  else if (_state == UIGestureRecognizerStateBegan || _state == UIGestureRecognizerStateChanged) [self setState:UIGestureRecognizerStateChanged];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event]; [NSObject cancelPreviousPerformRequestsWithTarget:self];
  [self setState:_state == UIGestureRecognizerStateBegan || _state == UIGestureRecognizerStateChanged ? UIGestureRecognizerStateEnded : UIGestureRecognizerStateFailed];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event { [NSObject cancelPreviousPerformRequestsWithTarget:self]; [super touchesCancelled:touches withEvent:event]; }
@end
@implementation UISwipeGestureRecognizer
@synthesize direction = _direction;
- (id)initWithTarget:(id)target action:(SEL)action { self = [super initWithTarget:target action:action]; if (self) _direction = UISwipeGestureRecognizerDirectionRight; return self; }
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { [super touchesBegan:touches withEvent:event]; _start = _location; _startTime = event.timestamp; }
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event]; CGFloat dx = _location.x-_start.x, dy = _location.y-_start.y;
  CGPoint a = [_view convertPoint:_start fromView:nil], b = [_view convertPoint:_location fromView:nil];
  dy = b.y-a.y; dx = b.x-a.x;
  NSUInteger direction = fabs(dx) > fabs(dy) ? (dx > 0 ? UISwipeGestureRecognizerDirectionRight : UISwipeGestureRecognizerDirectionLeft) : (dy > 0 ? UISwipeGestureRecognizerDirectionDown : UISwipeGestureRecognizerDirectionUp);
  [self setState:hypot(dx,dy) >= 30 && event.timestamp-_startTime < 0.75 && (_direction & direction) ? UIGestureRecognizerStateRecognized : UIGestureRecognizerStateFailed];
}
@end
static BOOL UIKitTouchVector(NSSet *touches, UIView *view, CGFloat *distance, CGFloat *angle) {
  if (touches.count != 2) return NO;
  NSArray *pair = [touches allObjects];
  id first = [pair objectAtIndex:0], second = [pair objectAtIndex:1];
  if ((uintptr_t)first > (uintptr_t)second) { id swap = first; first = second; second = swap; }
  CGPoint a = [first locationInView:view], b = [second locationInView:view];
  *distance = hypot(b.x-a.x,b.y-a.y); *angle = atan2(b.y-a.y,b.x-a.x); return YES;
}
@implementation UIPinchGestureRecognizer
@synthesize scale = _scale, velocity = _velocity;
- (id)initWithTarget:(id)target action:(SEL)action { self = [super initWithTarget:target action:action]; if (self) _scale = 1; return self; }
- (void)reset { [super reset]; _scale = 1; _velocity = 0; _initialDistance = 0; }
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { [super touchesBegan:touches withEvent:event]; CGFloat angle; UIKitTouchVector(touches,_view,&_initialDistance,&angle); _previousTime = event.timestamp; _previousScale = _scale; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event]; CGFloat distance,angle;
  if (!UIKitTouchVector(touches,_view,&distance,&angle) || _initialDistance <= 0) return;
  _scale = distance/_initialDistance; NSTimeInterval dt = event.timestamp-_previousTime;
  if (dt > 0) _velocity = (_scale-_previousScale)/dt; _previousScale = _scale; _previousTime = event.timestamp;
  [self setState:_state == UIGestureRecognizerStatePossible ? UIGestureRecognizerStateBegan : UIGestureRecognizerStateChanged];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { [self setState:_state == UIGestureRecognizerStatePossible ? UIGestureRecognizerStateFailed : UIGestureRecognizerStateEnded]; }
@end
@implementation UIRotationGestureRecognizer
@synthesize rotation = _rotation, velocity = _velocity;
- (void)reset { [super reset]; _rotation = _velocity = 0; }
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { [super touchesBegan:touches withEvent:event]; CGFloat distance; UIKitTouchVector(touches,_view,&distance,&_initialAngle); _previousTime = event.timestamp; _previousRotation = _rotation; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event]; CGFloat distance,angle;
  if (!UIKitTouchVector(touches,_view,&distance,&angle)) return;
  _rotation = remainder(angle-_initialAngle,2*M_PI); NSTimeInterval dt = event.timestamp-_previousTime;
  if (dt > 0) _velocity = (_rotation-_previousRotation)/dt; _previousRotation = _rotation; _previousTime = event.timestamp;
  [self setState:_state == UIGestureRecognizerStatePossible ? UIGestureRecognizerStateBegan : UIGestureRecognizerStateChanged];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { [self setState:_state == UIGestureRecognizerStatePossible ? UIGestureRecognizerStateFailed : UIGestureRecognizerStateEnded]; }
@end