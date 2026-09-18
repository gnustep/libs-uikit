#import "UIKitPrivate.h"
#import <UIKit/UIKit.h>

@implementation UITabBarController
- (void)dealloc { [_viewControllers release]; [_selectedViewController release]; [_contentHost release]; [super dealloc]; }
- (NSArray *)viewControllers { return _viewControllers; }
- (NSArray *)_appearanceChildren { return _selectedViewController ? [NSArray arrayWithObject:_selectedViewController] : [NSArray array]; }
- (void)loadView
{
  [super loadView];
  CGRect b = [_view bounds];
  _contentHost = [[UIView alloc] initWithFrame:CGRectMake(0, 0, b.size.width, MAX(0, b.size.height - 40))];
  [_contentHost setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_view addSubview:_contentHost];
  [self _rebuildTabs]; [self _installSelectedView];
}
- (void)_rebuildTabs
{
  if (!_contentHost) return;
  [_tabControl removeFromSuperview];
  NSMutableArray *titles = [NSMutableArray array];
  for (UIViewController *controller in _viewControllers) [titles addObject:[controller title] ?: @"Untitled"];
  _tabControl = [[[UISegmentedControl alloc] initWithItems:titles] autorelease];
  CGRect b = [_view bounds];
  [_tabControl setFrame:CGRectMake(0, MAX(0, b.size.height - 40), b.size.width, 40)];
  [_tabControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
  [_tabControl addTarget:self action:@selector(_tabChanged:) forControlEvents:UIControlEventValueChanged];
  [_view addSubview:_tabControl];
  [_tabControl setSelectedSegmentIndex:(_selectedViewController ? (NSInteger)[self selectedIndex] : -1)];
}
- (void)_tabChanged:(UISegmentedControl *)sender { [self setSelectedIndex:[sender selectedSegmentIndex]]; }
- (void)_installSelectedView
{
  if (!_contentHost) return;
  for (UIView *view in [[[_contentHost subviews] copy] autorelease]) [view removeFromSuperview];
  if (_selectedViewController) {
    UIView *view = [_selectedViewController view]; [view setFrame:[_contentHost bounds]];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_contentHost addSubview:view];
  }
  [_tabControl setSelectedSegmentIndex:(_selectedViewController ? (NSInteger)[self selectedIndex] : -1)];
}
- (void)setViewControllers:(NSArray *)controllers
{
  NSArray *replacement = [[controllers copy] autorelease];
  NSMutableSet *seen = [NSMutableSet set];
  for (UIViewController *controller in replacement) {
    if (controller == self || [seen containsObject:controller] ||
        ([controller parentViewController] && [controller parentViewController] != self))
      [NSException raise:NSInvalidArgumentException format:@"Invalid tab controllers"];
    [seen addObject:controller];
  }
  UIViewController *selection = [replacement containsObject:_selectedViewController] ? _selectedViewController : [replacement firstObject];
  for (UIViewController *controller in replacement)
    if ([controller parentViewController] != self) { [self addChildViewController:controller]; [controller didMoveToParentViewController:self]; }
  NSArray *old = [[_viewControllers retain] autorelease];
  ASSIGN(_viewControllers, replacement);
  [self setSelectedViewController:selection];
  for (UIViewController *controller in old)
    if (![replacement containsObject:controller]) { [controller willMoveToParentViewController:nil]; [controller removeFromParentViewController]; }
  [self _rebuildTabs];
}
- (NSUInteger)selectedIndex { return _selectedViewController ? [_viewControllers indexOfObjectIdenticalTo:_selectedViewController] : NSNotFound; }
- (void)setSelectedIndex:(NSUInteger)index
{
  if (index >= [_viewControllers count]) [NSException raise:NSRangeException format:@"Invalid tab index"];
  [self setSelectedViewController:[_viewControllers objectAtIndex:index]];
}
- (UIViewController *)selectedViewController { return _selectedViewController; }
- (void)setSelectedViewController:(UIViewController *)controller
{
  if (controller && ![_viewControllers containsObject:controller])
    [NSException raise:NSInvalidArgumentException format:@"Selected controller is not a tab"];
  if (controller == _selectedViewController) return;
  UIViewController *old = [[_selectedViewController retain] autorelease];
  if (_visible) { [old beginAppearanceTransition:NO animated:NO]; [controller beginAppearanceTransition:YES animated:NO]; }
  ASSIGN(_selectedViewController, controller); [self _installSelectedView];
  if (_visible) { [old endAppearanceTransition]; [controller endAppearanceTransition]; }
}
@end
