#import "UIKitPrivate.h"
#import <UIKit/UIView.h>
#import <UIKit/UIViewController.h>

@implementation UIViewController
- (id)init { return [self initWithNibName:nil bundle:nil]; }
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
  self = [super init];
  if (self) {
    _nibName = [name copy]; _nibBundle = [bundle retain];
    _childViewControllers = [[NSMutableArray alloc] init];
  }
  return self;
}
- (void)dealloc
{
  for (UIViewController *child in _childViewControllers) child->_parentViewController = nil;
  [_view _setOwningViewController:nil];
  [_childViewControllers release]; [_view release]; [_title release];
  [_nibName release]; [_nibBundle release]; [_nibTopLevelObjects release];
  [super dealloc];
}
- (BOOL)isViewLoaded { return _view != nil; }
- (void)loadViewIfNeeded { (void)[self view]; }
- (UIView *)view
{
  if (!_view) [self loadView];
  if (_view && !_viewLoaded) { _viewLoaded = YES; [self viewDidLoad]; }
  return _view;
}
- (void)setView:(UIView *)view
{
  if (_view == view) return;
  [_view _setOwningViewController:nil];
  ASSIGN(_view, view);
  [_view _setOwningViewController:self];
  if (!view) _viewLoaded = NO;
}
- (void)loadView
{
  if (_nibName) {
    UINib *nib = [UINib nibWithNibName:_nibName bundle:_nibBundle];
    ASSIGN(_nibTopLevelObjects, [nib instantiateWithOwner:self options:nil]);
  }
  if (!_view) [self setView:[[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease]];
}
- (UIViewController *)parentViewController { return _parentViewController; }
- (NSArray *)childViewControllers { return [[_childViewControllers copy] autorelease]; }
- (void)addChildViewController:(UIViewController *)controller
{
  if (!controller || controller->_parentViewController == self) return;
  for (UIViewController *ancestor = self; ancestor; ancestor = [ancestor parentViewController])
    if (ancestor == controller) [NSException raise:NSInvalidArgumentException format:@"Controller containment cycle"];
  if (controller->_parentViewController)
    [NSException raise:NSInvalidArgumentException format:@"Controller already has a parent"];
  [controller willMoveToParentViewController:self];
  [_childViewControllers addObject:controller]; controller->_parentViewController = self;
}
- (void)removeFromParentViewController
{
  if (!_parentViewController) return;
  [[self retain] autorelease];
  [_parentViewController->_childViewControllers removeObjectIdenticalTo:self];
  _parentViewController = nil;
  [self didMoveToParentViewController:nil];
}
- (void)willMoveToParentViewController:(UIViewController *)parent {}
- (void)didMoveToParentViewController:(UIViewController *)parent {}
- (NSArray *)_appearanceChildren { return [self childViewControllers]; }
- (BOOL)_isVisible { return _visible; }
- (void)beginAppearanceTransition:(BOOL)appearing animated:(BOOL)animated
{
  _appearing = appearing; _appearanceAnimated = animated;
  if (appearing) { [self loadViewIfNeeded]; [self viewWillAppear:animated]; }
  else [self viewWillDisappear:animated];
  for (UIViewController *child in [self _appearanceChildren])
    [child beginAppearanceTransition:appearing animated:animated];
}
- (void)endAppearanceTransition
{
  _visible = _appearing;
  for (UIViewController *child in [self _appearanceChildren]) [child endAppearanceTransition];
  if (_appearing) [self viewDidAppear:_appearanceAnimated];
  else [self viewDidDisappear:_appearanceAnimated];
}
- (void)viewDidLoad {}
- (void)viewWillAppear:(BOOL)animated {}
- (void)viewDidAppear:(BOOL)animated {}
- (void)viewWillDisappear:(BOOL)animated {}
- (void)viewDidDisappear:(BOOL)animated {}
- (UIResponder *)nextResponder { return [_view superview] ?: (UIResponder *)[_view window]; }
- (UIWindow *)_responderWindow { return [_view window]; }
- (NSResponder *)_nativeResponder { return [[self view] _nativeView]; }
- (NSString *)title { return _title; }
- (void)setTitle:(NSString *)title { ASSIGNCOPY(_title, title); }
@end
