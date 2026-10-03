#import "UIKitPrivate.h"
#import <UIKit/UIView.h>
#import <UIKit/UIViewController.h>

@implementation UIPopoverPresentationController
@synthesize sourceView = _sourceView, sourceRect = _sourceRect;
- (void)dealloc { [_sourceView release]; [super dealloc]; }
@end

@implementation UIViewController
@synthesize tabBarItem = _tabBarItem, definesPresentationContext = _definesPresentationContext, modalPresentationStyle = _modalPresentationStyle;
- (UINavigationItem *)navigationItem
{
  if (!_navigationItem) _navigationItem = [[UINavigationItem alloc] initWithTitle:_title];
  return _navigationItem;
}
- (UIPopoverPresentationController *)popoverPresentationController
{
  if (!_popoverPresentationController) _popoverPresentationController = [UIPopoverPresentationController new];
  return _popoverPresentationController;
}
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
  if (_presentedViewController) _presentedViewController->_presentingViewController = nil;
  [_presentationWindow close]; [_presentationWindow release]; [_presentedViewController release];
  for (UIViewController *child in _childViewControllers) child->_parentViewController = nil;
  [_navigationItem release]; [_tabBarItem release]; [_popoverPresentationController release];
  [_view _setOwningViewController:nil];
  [_childViewControllers release]; [_view release]; [_title release];
  [_nibName release]; [_nibBundle release]; [_nibTopLevelObjects release];
  [super dealloc];
}
- (UINavigationController *)navigationController
{
  for (UIViewController *parent = self; parent; parent = parent.parentViewController)
    if ([parent isKindOfClass:[UINavigationController class]]) return (UINavigationController *)parent;
  return nil;
}
- (UIViewController *)presentedViewController { return _presentedViewController; }
- (UIViewController *)presentingViewController { return _presentingViewController; }
- (void)presentViewController:(UIViewController *)controller animated:(BOOL)animated completion:(UIViewControllerCompletion)completion
{
  if (!controller || controller == self || _presentedViewController || controller->_presentingViewController)
    [NSException raise:NSInvalidArgumentException format:@"Invalid presentation"];
  [controller loadViewIfNeeded];
  _presentedViewController = [controller retain]; controller->_presentingViewController = self;
  CGRect frame = controller.view.frame; frame.origin = CGPointMake(100,100);
  _presentationWindow = [[UIWindow alloc] initWithFrame:frame];
  _presentationWindow.rootViewController = controller;
  [[_presentationWindow _nativeWindow] setTitle:controller.title ?: @""];
  [_presentationWindow makeKeyAndVisible];
  if (completion) CALL_BLOCK_NO_ARGS(completion);
}
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(UIViewControllerCompletion)completion
{
  if (!_presentedViewController && _presentingViewController) {
    [_presentingViewController dismissViewControllerAnimated:animated completion:completion]; return;
  }
  if (!_presentedViewController && _parentViewController) {
    [_parentViewController dismissViewControllerAnimated:animated completion:completion]; return;
  }
  if (_presentedViewController) {
    if (_presentedViewController->_presentedViewController)
      [_presentedViewController dismissViewControllerAnimated:animated completion:nil];
    _presentedViewController->_presentingViewController = nil;
    [_presentationWindow close]; _presentationWindow.rootViewController = nil;
    DESTROY(_presentationWindow); DESTROY(_presentedViewController);
    [[self.view window] makeKeyWindow];
  }
  if (completion) CALL_BLOCK_NO_ARGS(completion);
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
- (void)setTitle:(NSString *)title { ASSIGNCOPY(_title, title); [_navigationItem setTitle:title]; }
@end
