#import "UIKitPrivate.h"
#import <UIKit/UIEvent.h>
#import <UIKit/UITouch.h>
#import <UIKit/UIView.h>
#import <UIKit/UIWindow.h>

@implementation UIEvent
+ (UIEvent *)eventWithNSEvent:(NSEvent *)event
{
  return [[[self alloc] initWithNSEvent:event] autorelease];
}
- (id)initWithType:(UIEventType)type subtype:(UIEventSubtype)subtype timestamp:(NSTimeInterval)timestamp
{
  self = [super init];
  if (self != nil)
    {
      _type = type;
      _subtype = subtype;
      _timestamp = timestamp;
    }
  return self;
}
- (id)initWithNSEvent:(NSEvent *)event
{
  UIEventType type = UIEventTypeTouches;
  UIEventSubtype subtype = UIEventSubtypeNone;
  UITouchPhase phase = UITouchPhaseStationary;
  UITouch *touch;

  self = [self initWithType:type subtype:subtype timestamp:[event timestamp]];
  if (self != nil)
    {
      _NSEvent = [event retain];
      switch ([event type])
        {
          case NSLeftMouseDown:
          case NSRightMouseDown:
          case NSOtherMouseDown:
            phase = UITouchPhaseBegan;
            break;
          case NSLeftMouseDragged:
          case NSRightMouseDragged:
          case NSOtherMouseDragged:
          case NSMouseMoved:
            phase = UITouchPhaseMoved;
            break;
          case NSLeftMouseUp:
          case NSRightMouseUp:
          case NSOtherMouseUp:
            phase = UITouchPhaseEnded;
            break;
          default:
            break;
        }
      touch = [UITouch touchWithNSEvent:event view:UIKitWindowForNativeWindow([event window])];
      [touch setPhase:phase];
      _allTouches = [[NSSet alloc] initWithObjects:touch, nil];
    }
  return self;
}
- (id)_initWithTouch:(UITouch *)touch nativeEvent:(NSEvent *)event
{
  self = [self initWithType:UIEventTypeTouches subtype:UIEventSubtypeNone timestamp:[event timestamp]];
  if (self) { _allTouches = [[NSSet alloc] initWithObjects:touch, nil]; _NSEvent = [event retain]; }
  return self;
}
- (void)dealloc
{
  [_allTouches release];
  [_NSEvent release];
  [super dealloc];
}
- (NSTimeInterval)timestamp { return _timestamp; }
- (UIEventType)type { return _type; }
- (UIEventSubtype)subtype { return _subtype; }
- (NSSet *)allTouches { return _allTouches; }
- (NSSet *)touchesForView:(UIView *)view
{
  NSMutableSet *touches;
  NSEnumerator *enumerator;
  UITouch *touch;

  if (view == nil || _allTouches == nil)
    return nil;

  touches = [NSMutableSet set];
  enumerator = [_allTouches objectEnumerator];
  while ((touch = [enumerator nextObject]) != nil)
    {
      if ([touch view] == view)
        [touches addObject:touch];
    }

  return touches;
}
- (NSSet *)touchesForWindow:(UIWindow *)window
{
  NSMutableSet *touches;
  NSEnumerator *enumerator;
  UITouch *touch;

  if (window == nil || _allTouches == nil)
    return nil;

  touches = [NSMutableSet set];
  enumerator = [_allTouches objectEnumerator];
  while ((touch = [enumerator nextObject]) != nil)
    {
      if ([touch window] == window)
        [touches addObject:touch];
    }

  return touches;
}
- (NSEvent *)NSEvent { return _NSEvent; }
@end
