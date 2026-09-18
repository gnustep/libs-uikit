#import "UIKitPrivate.h"
#import <UIKit/UIKit.h>

@implementation UINavigationController
- (id)init { return [self initWithRootViewController:nil]; }
- (id)initWithRootViewController:(UIViewController *)root
{
  self = [super init];
  if (self) {
    _viewControllers = [[NSMutableArray alloc] init];
    if (root) [self pushViewController:root animated:NO];
  }
  return self;
}
- (void)dealloc { [_viewControllers release]; [_contentHost release]; [super dealloc]; }
- (NSArray *)viewControllers { return [[_viewControllers copy] autorelease]; }
- (UIViewController *)topViewController { return [_viewControllers lastObject]; }
- (NSArray *)_appearanceChildren { return [self topViewController] ? [NSArray arrayWithObject:[self topViewController]] : [NSArray array]; }
- (void)loadView
{
  [super loadView];
  CGRect bounds = [_view bounds];
  _backButton = [UIButton buttonWithType:0];
  [_backButton setFrame:CGRectMake(4, 4, 70, 36)];
  [_backButton setTitle:@"Back" forState:UIControlStateNormal];
  [_backButton addTarget:self action:@selector(_goBack:) forControlEvents:UIControlEventTouchUpInside];
  [_view addSubview:_backButton];
  _titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(80, 4, bounds.size.width - 84, 36)] autorelease];
  [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  [_view addSubview:_titleLabel];
  _contentHost = [[UIView alloc] initWithFrame:CGRectMake(0, 44, bounds.size.width, MAX(0, bounds.size.height - 44))];
  [_contentHost setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_view addSubview:_contentHost];
  [self _installTopView];
}
- (void)_goBack:(id)sender { [self popViewControllerAnimated:NO]; }
- (void)_installTopView
{
  if (!_contentHost) return;
  for (UIView *view in [[[_contentHost subviews] copy] autorelease]) [view removeFromSuperview];
  UIViewController *top = [self topViewController];
  if (top) {
    UIView *view = [top view]; [view setFrame:[_contentHost bounds]];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_contentHost addSubview:view];
  }
  [_titleLabel setText:[top title]];
  [_backButton setHidden:[_viewControllers count] <= 1];
}
- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated
{
  if (!controller) return;
  if ([_viewControllers containsObject:controller])
    [NSException raise:NSInvalidArgumentException format:@"Cannot push the same controller twice"];
  UIViewController *old = [self topViewController];
  [self addChildViewController:controller];
  if (_visible) { [old beginAppearanceTransition:NO animated:animated]; [controller beginAppearanceTransition:YES animated:animated]; }
  [_viewControllers addObject:controller];
  [self _installTopView]; [controller didMoveToParentViewController:self];
  if (_visible) { [old endAppearanceTransition]; [controller endAppearanceTransition]; }
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
  if ([_viewControllers count] <= 1) return nil;
  UIViewController *old = [[[self topViewController] retain] autorelease];
  [old willMoveToParentViewController:nil];
  if (_visible) [old beginAppearanceTransition:NO animated:animated];
  [_viewControllers removeLastObject];
  UIViewController *next = [self topViewController];
  if (_visible) [next beginAppearanceTransition:YES animated:animated];
  [self _installTopView]; [old removeFromParentViewController];
  if (_visible) { [old endAppearanceTransition]; [next endAppearanceTransition]; }
  return old;
}
- (void)setViewControllers:(NSArray *)controllers animated:(BOOL)animated
{
  NSArray *replacement = [[controllers copy] autorelease];
  NSMutableSet *seen = [NSMutableSet set];
  for (UIViewController *controller in replacement) {
    if (controller == self || [seen containsObject:controller] ||
        ([controller parentViewController] && [controller parentViewController] != self))
      [NSException raise:NSInvalidArgumentException format:@"Invalid navigation stack"];
    [seen addObject:controller];
  }
  UIViewController *old = [[[self topViewController] retain] autorelease];
  UIViewController *next = [replacement lastObject];
  BOOL transition = _visible && old != next;
  if (transition) { [old beginAppearanceTransition:NO animated:animated]; [next beginAppearanceTransition:YES animated:animated]; }
  for (UIViewController *controller in [[_viewControllers copy] autorelease]) {
    if (![replacement containsObject:controller]) { [controller willMoveToParentViewController:nil]; [controller removeFromParentViewController]; }
  }
  for (UIViewController *controller in replacement) {
    if ([controller parentViewController] != self) { [self addChildViewController:controller]; [controller didMoveToParentViewController:self]; }
  }
  [_viewControllers setArray:replacement ?: [NSArray array]]; [self _installTopView];
  if (transition) { [old endAppearanceTransition]; [next endAppearanceTransition]; }
}
@end
