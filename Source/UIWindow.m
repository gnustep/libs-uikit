#import "UIKitPrivate.h"
const UIWindowLevel UIWindowLevelNormal = 0;
const UIWindowLevel UIWindowLevelStatusBar = 1000;
const UIWindowLevel UIWindowLevelAlert = 2000;

@implementation _UIKitWindowPeer
- (void)close { [owner _nativeWindowWillClose]; [super close]; }
@end

@implementation UIWindow
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _UIKitWindowPeer *peer = [[_UIKitWindowPeer alloc] initWithContentRect:frame
      styleMask:NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
    _nativeWindow = peer; peer->owner = self; [peer setReleasedWhenClosed:NO];
    [peer setContentView:[self _nativeView]];
    [super setHidden:YES];
    [[UIApplication sharedApplication] addWindow:self];
  }
  return self;
}
- (void)dealloc
{
  ((_UIKitWindowPeer *)_nativeWindow)->owner = nil;
  [_nativeWindow setContentView:nil]; [_nativeWindow close]; [_nativeWindow release];
  [_rootViewController release]; [super dealloc];
}
- (NSWindow *)_nativeWindow { return _nativeWindow; }
- (UIWindow *)window { return self; }
- (UIWindow *)_responderWindow { return self; }
- (UIResponder *)nextResponder { return [UIApplication sharedApplication]; }
- (void)_nativeFrameChanged:(CGRect)frame
{
  frame.origin = _frame.origin;
  CGSize previous = _bounds.size;
  _frame = frame; _bounds.size = frame.size;
  if (_autoresizesSubviews && !NSEqualSizes(previous, frame.size))
    for (UIView *view in [self subviews]) [view resizeWithOldSuperviewSize:previous];
  [self setNeedsLayout];
}
- (void)setFrame:(CGRect)frame
{
  _frame.origin = frame.origin;
  if (_nativeWindow) [_nativeWindow setContentSize:frame.size];
  else [super setFrame:frame];
}
- (UIWindowScene *)windowScene { return _windowScene; }
- (void)setWindowScene:(UIWindowScene *)scene
{ if (_windowScene == scene) return; [_windowScene removeWindow:self]; _windowScene = scene; [_windowScene addWindow:self]; }
- (UIViewController *)rootViewController { return _rootViewController; }
- (void)setRootViewController:(UIViewController *)controller
{
  if (_rootViewController == controller) return;
  UIViewController *old = [[_rootViewController retain] autorelease];
  BOOL visible = ![self isHidden];
  if (visible) { [old beginAppearanceTransition:NO animated:NO]; [controller beginAppearanceTransition:YES animated:NO]; }
  if ([old isViewLoaded]) [[old view] removeFromSuperview];
  ASSIGN(_rootViewController, controller);
  if (controller) {
    UIView *view = [controller view]; [view setFrame:[self bounds]];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:view];
  }
  if (visible) { [old endAppearanceTransition]; [controller endAppearanceTransition]; }
}
- (void)setHidden:(BOOL)hidden
{
  if ([self isHidden] == hidden) return;
  [_rootViewController beginAppearanceTransition:!hidden animated:NO];
  [super setHidden:hidden];
  if (hidden) [_nativeWindow orderOut:nil]; else {
    [[UIApplication sharedApplication] addWindow:self]; [_nativeWindow orderFront:nil];
    [_windowScene setActivationState:UISceneActivationStateForegroundActive];
  }
  [_rootViewController endAppearanceTransition];
}
- (BOOL)isKeyWindow { return [_nativeWindow isKeyWindow]; }
- (void)makeKeyWindow { [_nativeWindow makeKeyWindow]; }
- (void)makeKeyAndVisible { [self setHidden:NO]; [self makeKeyWindow]; }
- (UIWindowLevel)windowLevel { return _windowLevel; }
- (void)setWindowLevel:(UIWindowLevel)level { _windowLevel = level; [_nativeWindow setLevel:level]; }
- (UIResponder *)_firstResponder
{
  NSResponder *native = [_nativeWindow firstResponder];
  if (_firstResponder && [_firstResponder _nativeResponder] == native) return _firstResponder;
  NSMutableArray *pending = [NSMutableArray arrayWithObject:self];
  while ([pending count]) {
    UIView *view = [[[pending lastObject] retain] autorelease];
    [pending removeLastObject];
    NSResponder *peer = [view _nativeResponder];
    if (peer == native || ([peer isKindOfClass:[NSControl class]] &&
        [(NSControl *)peer currentEditor] != nil && [(NSControl *)peer currentEditor] == native)) {
      _firstResponder = view; return view;
    }
    [pending addObjectsFromArray:[view subviews]];
  }
  _firstResponder = nil; return nil;
}
- (BOOL)_makeFirstResponder:(UIResponder *)responder
{
  if ([self _firstResponder] == responder) return YES;
  if (_firstResponder && ![_firstResponder canResignFirstResponder]) return NO;
  NSResponder *native = [responder _nativeResponder];
  if (responder && !native) return NO;
  if (![_nativeWindow makeFirstResponder:native]) return NO;
  _firstResponder = responder; return YES;
}
- (void)_nativeWindowWillClose
{
  [[self retain] autorelease]; [self endEditing:YES]; [self setHidden:YES];
  [[UIApplication sharedApplication] removeWindow:self];
  if (_rootViewController.presentingViewController)
    [_rootViewController dismissViewControllerAnimated:NO completion:NULL];
}
- (void)close { [_nativeWindow close]; }
- (void)sendEvent:(UIEvent *)event { [_nativeWindow sendEvent:[event NSEvent]]; }
@end
