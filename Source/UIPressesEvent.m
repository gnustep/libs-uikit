#import <UIKit/UIPressesEvent.h>
#import <UIKit/UIPress.h>

@implementation UIPressesEvent
+ (UIPressesEvent *)eventWithPresses:(NSSet *)presses
{
  NSTimeInterval timestamp = 0.0;
  UIPress *press = [presses anyObject];

  if (press != nil)
    timestamp = [press timestamp];
  return [[[self alloc] initWithPresses:presses timestamp:timestamp] autorelease];
}
- (id)initWithPresses:(NSSet *)presses timestamp:(NSTimeInterval)timestamp
{
  self = [super initWithType:UIEventTypePresses subtype:UIEventSubtypeNone timestamp:timestamp];
  if (self != nil)
    _allPresses = [presses copy];
  return self;
}
- (void)dealloc
{
  [_allPresses release];
  [super dealloc];
}
- (NSSet *)allPresses { return _allPresses; }
- (NSSet *)pressesForResponder:(UIResponder *)responder
{
  NSMutableSet *presses;
  NSEnumerator *enumerator;
  UIPress *press;

  if (responder == nil || _allPresses == nil)
    return nil;

  presses = [NSMutableSet set];
  enumerator = [_allPresses objectEnumerator];
  while ((press = [enumerator nextObject]) != nil)
    {
      if ([press responder] == responder)
        [presses addObject:press];
    }

  return presses;
}
@end
