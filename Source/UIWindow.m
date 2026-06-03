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
  ASSIGN(_rootViewController, controller);
  if (controller != nil)
    [self setContentView:(NSView *)[controller view]];
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
