#import "UIKitPrivate.h"
#import <UIKit/UITouch.h>
#import <UIKit/UIView.h>
#import <UIKit/UIWindow.h>

@implementation UITouch
+ (UITouch *)touchWithNSEvent:(NSEvent *)event view:(UIView *)view
{
  UIWindow *window = UIKitWindowForNativeWindow([event window]);
  CGPoint location = [[window _nativeView] convertPoint:[event locationInWindow] fromView:nil];
  UITouch *touch;

  touch = [[[self alloc] initWithLocation:location
                                 inWindow:window
                                     view:view
                                    phase:UITouchPhaseBegan
                                 tapCount:[event clickCount]
                                timestamp:[event timestamp]] autorelease];
  touch->_NSEvent = [event retain];
  return touch;
}
- (id)initWithLocation:(CGPoint)location
              inWindow:(UIWindow *)window
                  view:(UIView *)view
                 phase:(UITouchPhase)phase
              tapCount:(NSUInteger)tapCount
             timestamp:(NSTimeInterval)timestamp
{
  self = [super init];
  if (self != nil)
    {
      _locationInWindow = location;
      _previousLocationInWindow = location;
      _window = [window retain];
      _view = view;
      _phase = phase;
      _tapCount = tapCount;
      _timestamp = timestamp;
    }
  return self;
}
- (void)dealloc
{
  [_window release];
  [_NSEvent release];
  [super dealloc];
}
- (NSTimeInterval)timestamp { return _timestamp; }
- (NSUInteger)tapCount { return _tapCount; }
- (UITouchPhase)phase { return _phase; }
- (void)setPhase:(UITouchPhase)phase { _phase = phase; }
- (UIWindow *)window { return _window; }
- (UIView *)view { return _view; }
- (CGPoint)_location:(CGPoint)location inView:(UIView *)view
{
  if (view == nil || _window == nil)
    return location;
  return [view convertPoint:location fromView:nil];
}
- (CGPoint)locationInView:(UIView *)view
{
  return [self _location:_locationInWindow inView:view];
}
- (CGPoint)previousLocationInView:(UIView *)view
{
  return [self _location:_previousLocationInWindow inView:view];
}
- (void)_updateWithNSEvent:(NSEvent *)event phase:(UITouchPhase)phase
{
  _previousLocationInWindow = _locationInWindow;
  _locationInWindow = [[_window _nativeView] convertPoint:[event locationInWindow] fromView:nil]; _timestamp = [event timestamp]; _phase = phase;
  ASSIGN(_NSEvent, event);
}
- (NSEvent *)NSEvent { return _NSEvent; }
@end
