#import <UIKit/UIApplication.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIWindow.h>

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
  [_rootViewController release];
  [super dealloc];
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
