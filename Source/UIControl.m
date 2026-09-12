#import <UIKit/UIControl.h>

@implementation UIControl
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _uiTargets = [[NSMutableArray alloc] init];
      _enabled = YES;
    }
  return self;
}
- (void)dealloc
{
  [_uiTargets release];
  [super dealloc];
}
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events
{
  id storedTarget = target == nil ? (id)[NSNull null] : (id)[NSValue valueWithNonretainedObject:target];
  NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
    storedTarget, @"target", NSStringFromSelector(action), @"action",
    [NSNumber numberWithUnsignedInt:events], @"events", nil];
  [_uiTargets addObject:entry];
}
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events
{
  NSMutableArray *remaining = [NSMutableArray array];
  NSEnumerator *enumerator = [[[_uiTargets copy] autorelease] objectEnumerator];
  NSDictionary *entry;

  while ((entry = [enumerator nextObject]) != nil)
    {
      id entryTarget = [entry objectForKey:@"target"];
      SEL entryAction = NSSelectorFromString([entry objectForKey:@"action"]);
      UIControlEvents entryEvents = [[entry objectForKey:@"events"] unsignedIntValue];
      entryTarget = entryTarget == [NSNull null] ? nil : [entryTarget nonretainedObjectValue];
      BOOL targetMatches = (target == nil || target == entryTarget);
      BOOL actionMatches = (action == NULL || action == entryAction);
      BOOL eventsMatch = (events == 0 || (entryEvents & events) != 0 || entryEvents == UIControlEventAllEvents);

      if (targetMatches && actionMatches && eventsMatch) {
        UIControlEvents rest = entryEvents & ~events;
        if (rest && events != 0) {
          NSMutableDictionary *updated = [[entry mutableCopy] autorelease];
          [updated setObject:[NSNumber numberWithUnsignedInt:rest] forKey:@"events"];
          [remaining addObject:updated];
        }
        continue;
      }
      [remaining addObject:entry];
    }

  [_uiTargets setArray:remaining];
}
- (void)sendActionsForControlEvents:(UIControlEvents)events
{
  NSEnumerator *enumerator = [[[_uiTargets copy] autorelease] objectEnumerator];
  NSDictionary *entry;

  if (_enabled == NO)
    return;

  while ((entry = [enumerator nextObject]) != nil)
    {
      UIControlEvents entryEvents = [[entry objectForKey:@"events"] unsignedIntValue];
      id target = [entry objectForKey:@"target"];
      SEL action = NSSelectorFromString([entry objectForKey:@"action"]);
      target = target == [NSNull null] ? [NSApp targetForAction:action to:nil from:self] : [target nonretainedObjectValue];

      if ((entryEvents & events) != 0 || entryEvents == UIControlEventAllEvents)
        {
          if ([target respondsToSelector:action])
            {
              NSMethodSignature *signature = [target methodSignatureForSelector:action];
              NSUInteger count = [signature numberOfArguments];
              if (count < 2 || count > 4) continue;
              NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
              [invocation setTarget:target]; [invocation setSelector:action];
              id sender = self, event = nil;
              if (count > 2) [invocation setArgument:&sender atIndex:2];
              if (count > 3) [invocation setArgument:&event atIndex:3];
              [invocation invoke];
            }
        }
    }
}
- (BOOL)isEnabled { return _enabled; }
- (void)setEnabled:(BOOL)enabled { _enabled = enabled; }
- (BOOL)isSelected { return _selected; }
- (void)setSelected:(BOOL)selected { _selected = selected; }
- (BOOL)isHighlighted { return _highlighted; }
- (void)setHighlighted:(BOOL)highlighted { _highlighted = highlighted; }
@end
