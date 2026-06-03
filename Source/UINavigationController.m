#import <UIKit/UINavigationController.h>

@implementation UINavigationController
- (id)initWithRootViewController:(UIViewController *)rootViewController
{
  self = [super init];
  if (self != nil)
    {
      _viewControllers = [[NSMutableArray alloc] init];
      if (rootViewController != nil)
        [self pushViewController:rootViewController animated:NO];
    }
  return self;
}
- (void)dealloc
{
  [_viewControllers release];
  [super dealloc];
}
- (NSArray *)viewControllers { return _viewControllers; }
- (UIViewController *)topViewController { return [_viewControllers lastObject]; }
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  if (viewController == nil)
    return;
  [_viewControllers addObject:viewController];
  [self setView:[viewController view]];
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
  UIViewController *controller;
  if ([_viewControllers count] <= 1)
    return nil;
  controller = [[[_viewControllers lastObject] retain] autorelease];
  [_viewControllers removeLastObject];
  [self setView:[[self topViewController] view]];
  return controller;
}
@end
