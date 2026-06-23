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
  UIViewController *oldController;
  if (viewController == nil)
    return;
  oldController = [self topViewController];
  [oldController viewWillDisappear:animated];
  [viewController viewWillAppear:animated];
  [_viewControllers addObject:viewController];
  [self setView:[viewController view]];
  [oldController viewDidDisappear:animated];
  [viewController viewDidAppear:animated];
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
  UIViewController *controller;
  UIViewController *newTopController;
  if ([_viewControllers count] <= 1)
    return nil;
  controller = [[[_viewControllers lastObject] retain] autorelease];
  [controller viewWillDisappear:animated];
  [_viewControllers removeLastObject];
  newTopController = [self topViewController];
  [newTopController viewWillAppear:animated];
  [self setView:[newTopController view]];
  [controller viewDidDisappear:animated];
  [newTopController viewDidAppear:animated];
  return controller;
}
@end
