#import <UIKit/UIApplication.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIWindowScene.h>

@implementation UIWindow
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithContentRect:frame
                          styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask)
                            backing:NSBackingStoreBuffered
                              defer:NO];
  if (self != nil)
    { [self setReleasedWhenClosed:NO]; [[UIApplication sharedApplication] addWindow:self]; }
  return self;
}
- (void)dealloc
{
  [_windowScene removeWindow:self];
  [_rootViewController release];
  [super dealloc];
}
- (UIWindowScene *)windowScene { return _windowScene; }
- (void)setWindowScene:(UIWindowScene *)windowScene
{
  if (_windowScene == windowScene)
    return;
  [_windowScene removeWindow:self];
  _windowScene = windowScene;
  [_windowScene addWindow:self];
}
- (UIViewController *)rootViewController { return _rootViewController; }
- (void)setRootViewController:(UIViewController *)controller
{
  if (_rootViewController == controller) return;
  UIViewController *old = [[_rootViewController retain] autorelease];
  BOOL visible = [self isVisible];
  if (visible) { [old beginAppearanceTransition:NO animated:NO]; [controller beginAppearanceTransition:YES animated:NO]; }
  ASSIGN(_rootViewController, controller);
  [self setContentView:controller ? (NSView *)[controller view] : [[[NSView alloc] initWithFrame:NSZeroRect] autorelease]];
  if (visible) { [old endAppearanceTransition]; [controller endAppearanceTransition]; }
}
- (void)makeKeyAndVisible
{
  [[UIApplication sharedApplication] addWindow:self];
  [[self windowScene] setActivationState:UISceneActivationStateForegroundActive];
  BOOL appearing = ![_rootViewController _isVisible];
  if (appearing) [_rootViewController beginAppearanceTransition:YES animated:NO];
  [self makeKeyAndOrderFront:nil];
  if (appearing) [_rootViewController endAppearanceTransition];
}
- (void)close
{
  if ([_rootViewController _isVisible]) {
    [_rootViewController beginAppearanceTransition:NO animated:NO];
    [_rootViewController endAppearanceTransition];
  }
  [[self retain] autorelease];
  [super close];
  [[UIApplication sharedApplication] removeWindow:self];
}
- (void)addSubview:(UIView *)view
{
  [[self contentView] addSubview:view];
}
@end
