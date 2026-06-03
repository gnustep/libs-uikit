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
  NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
    target, @"target", NSStringFromSelector(action), @"action",
    [NSNumber numberWithUnsignedInt:events], @"events", nil];
  [_uiTargets addObject:entry];
}
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events
{
  [_uiTargets removeAllObjects];
}
- (void)sendActionsForControlEvents:(UIControlEvents)events
{
  NSEnumerator *enumerator = [_uiTargets objectEnumerator];
  NSDictionary *entry;

  while ((entry = [enumerator nextObject]) != nil)
    {
      UIControlEvents entryEvents = [[entry objectForKey:@"events"] unsignedIntValue];
      id target = [entry objectForKey:@"target"];
      SEL action = NSSelectorFromString([entry objectForKey:@"action"]);

      if ((entryEvents & events) != 0 || entryEvents == UIControlEventAllEvents)
        {
          if ([target respondsToSelector:action])
            [target performSelector:action withObject:self];
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
