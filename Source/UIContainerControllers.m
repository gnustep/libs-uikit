#import "UIKitPrivate.h"
@implementation UIPageViewController
- (id)init { return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil]; }
- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)orientation options:(NSDictionary *)options {
  self = [super initWithNibName:nil bundle:nil]; if (self) { _transitionStyle = style; _navigationOrientation = orientation; } return self;
}
- (void)dealloc { [_viewControllers release]; [super dealloc]; }
@synthesize viewControllers = _viewControllers, transitionStyle = _transitionStyle, navigationOrientation = _navigationOrientation;
- (void)loadView { [super loadView]; [self _installPage]; }
- (void)_installPage {
  if (!_view) return;
  for (UIView *view in [[_view.subviews copy] autorelease]) [view removeFromSuperview];
  UIView *page = [(UIViewController *)[_viewControllers firstObject] view];
  page.frame = _view.bounds; page.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  if (page) [_view addSubview:page];
}
- (void)setViewControllers:(NSArray *)controllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(UIPageViewControllerCompletion)completion {
  if (controllers.count != 1) [NSException raise:NSInvalidArgumentException format:@"This page controller requires one visible page"];
  UIViewController *next = [controllers firstObject], *old = [_viewControllers firstObject];
  if (next != old) {
    [self addChildViewController:next];
    if (_visible) { [old beginAppearanceTransition:NO animated:animated]; [next beginAppearanceTransition:YES animated:animated]; }
    [old willMoveToParentViewController:nil];
    ASSIGNCOPY(_viewControllers,controllers); [self _installPage];
    if (_visible) { [old endAppearanceTransition]; [next endAppearanceTransition]; }
    [old removeFromParentViewController]; [next didMoveToParentViewController:self];
  }
  if (completion) CALL_BLOCK(completion,YES);
}
@end

@interface _UIKitSplitHost : UIView { @public UISplitViewController *owner; }
@end
@interface UISplitViewController (Layout)
- (void)_layoutColumns;
@end
@implementation _UIKitSplitHost
- (void)layoutSubviews { [super layoutSubviews]; [owner _layoutColumns]; }
@end
@implementation UISplitViewController
- (id)init { return [self initWithStyle:UISplitViewControllerStyleDoubleColumn]; }
- (id)initWithStyle:(UISplitViewControllerStyle)style {
  self = [super initWithNibName:nil bundle:nil];
  if (self) { _style = style; _columns = [NSMutableDictionary new]; _displayModeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Columns" style:0 target:self action:@selector(_toggle:)]; }
  return self;
}
- (void)dealloc { if (_view) ((_UIKitSplitHost *)_view)->owner = nil; [_columns release]; [_displayModeButtonItem release]; [super dealloc]; }
@synthesize style = _style;
- (UIBarButtonItem *)displayModeButtonItem { return _displayModeButtonItem; }
- (UISplitViewControllerDisplayMode)preferredDisplayMode { return _preferredDisplayMode; }
- (void)setPreferredDisplayMode:(UISplitViewControllerDisplayMode)mode { _preferredDisplayMode = mode; [_view setNeedsLayout]; }
- (void)_toggle:(id)sender { self.preferredDisplayMode = _preferredDisplayMode == UISplitViewControllerDisplayModeSecondaryOnly ? UISplitViewControllerDisplayModeOneBesideSecondary : UISplitViewControllerDisplayModeSecondaryOnly; }
- (void)loadView {
  _UIKitSplitHost *host = [[_UIKitSplitHost alloc] initWithFrame:CGRectMake(0,0,800,480)]; host->owner = self; self.view = host; [host release];
  [self _layoutColumns];
}
- (UIViewController *)viewControllerForColumn:(UISplitViewControllerColumn)column { return [_columns objectForKey:[NSNumber numberWithInteger:column]]; }
- (void)setViewController:(UIViewController *)controller forColumn:(UISplitViewControllerColumn)column {
  NSNumber *key = [NSNumber numberWithInteger:column]; UIViewController *old = [_columns objectForKey:key];
  if (old == controller) return;
  if (controller) [self addChildViewController:controller];
  if (_visible) { [old beginAppearanceTransition:NO animated:NO]; [controller beginAppearanceTransition:YES animated:NO]; }
  [old willMoveToParentViewController:nil]; if (old.isViewLoaded) [old.view removeFromSuperview];
  if (_visible) [old endAppearanceTransition]; [old removeFromParentViewController];
  if (controller) [_columns setObject:controller forKey:key]; else [_columns removeObjectForKey:key];
  [self _layoutColumns]; [controller didMoveToParentViewController:self];
  if (_visible) [controller endAppearanceTransition];
}
- (void)_layoutColumns {
  if (!_view) return;
  NSArray *keys = [[_columns allKeys] sortedArrayUsingSelector:@selector(compare:)];
  NSMutableArray *shown = [NSMutableArray array];
  for (NSNumber *key in keys) {
    UIViewController *controller = [_columns objectForKey:key];
    BOOL hide = _preferredDisplayMode == UISplitViewControllerDisplayModeSecondaryOnly && key.integerValue != UISplitViewControllerColumnSecondary;
    if (hide) { [controller.view removeFromSuperview]; } else [shown addObject:controller];
  }
  CGFloat width = _view.bounds.size.width / MAX(1,shown.count); NSInteger index = 0;
  for (UIViewController *controller in shown) {
    controller.view.frame = CGRectMake(index++*width,0,width,_view.bounds.size.height);
    if (controller.view.superview != _view) [_view addSubview:controller.view];
  }
}
@end
