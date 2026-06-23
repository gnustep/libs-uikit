#import <UIKit/UITabBarController.h>

@implementation UITabBarController
- (void)dealloc
{
  [_viewControllers release];
  [_selectedViewController release];
  [super dealloc];
}
- (NSArray *)viewControllers { return _viewControllers; }
- (void)setViewControllers:(NSArray *)viewControllers
{
  ASSIGN(_viewControllers, viewControllers);
  if ([viewControllers count] > 0)
    [self setSelectedViewController:[viewControllers objectAtIndex:0]];
}
- (UIViewController *)selectedViewController { return _selectedViewController; }
- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
  UIViewController *oldController = _selectedViewController;
  if (oldController == selectedViewController)
    return;
  [oldController viewWillDisappear:NO];
  [selectedViewController viewWillAppear:NO];
  ASSIGN(_selectedViewController, selectedViewController);
  if (selectedViewController != nil)
    [self setView:[selectedViewController view]];
  [oldController viewDidDisappear:NO];
  [selectedViewController viewDidAppear:NO];
}
@end
