#import "UIKitPrivate.h"
#import <UIKit/UIScreen.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIWindowScene.h>

@implementation UIWindowScene
- (id)initWithSession:(UISceneSession *)session
{
  self = [super initWithSession:session];
  if (self != nil)
    {
      _windows = [[NSMutableArray alloc] init];
      _screen = [[UIScreen mainScreen] retain];
    }
  return self;
}
- (void)dealloc
{
  [_windows release];
  [_screen release];
  [super dealloc];
}
- (NSArray *)windows { return _windows; }
- (void)addWindow:(UIWindow *)window
{
  if (window != nil && [_windows containsObject:window] == NO)
    [_windows addObject:window];
}
- (void)removeWindow:(UIWindow *)window
{
  if (window != nil)
    [_windows removeObjectIdenticalTo:window];
}
- (UIWindow *)keyWindow
{
  NSEnumerator *enumerator = [_windows objectEnumerator];
  UIWindow *window;

  while ((window = [enumerator nextObject]) != nil)
    {
      if ([window isKeyWindow])
        return window;
    }

  return nil;
}
- (UIScreen *)screen { return _screen; }
@end
