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
    [[UIApplication sharedApplication] addWindow:self];
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
  UIViewController *oldController = _rootViewController;
  if (oldController == controller)
    return;
  [oldController viewWillDisappear:NO];
  [controller viewWillAppear:NO];
  ASSIGN(_rootViewController, controller);
  if (controller != nil)
    [self setContentView:(NSView *)[controller view]];
  [oldController viewDidDisappear:NO];
  [controller viewDidAppear:NO];
}
- (void)makeKeyAndVisible
{
  [self makeKeyAndOrderFront:nil];
}
- (void)addSubview:(UIView *)view
{
  [[self contentView] addSubview:view];
}
@end
