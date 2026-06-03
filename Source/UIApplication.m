#import <UIKit/UIApplication.h>
#import <UIKit/UIWindow.h>

NSString *UIApplicationDidFinishLaunchingNotification = @"UIApplicationDidFinishLaunchingNotification";
NSString *UIApplicationWillTerminateNotification = @"UIApplicationWillTerminateNotification";

@implementation UIApplication
+ (UIApplication *)sharedApplication
{
  static UIApplication *shared = nil;
  if (shared == nil)
    shared = [[self alloc] init];
  return shared;
}
- (id)init
{
  self = [super init];
  if (self != nil)
    _windows = [[NSMutableArray alloc] init];
  return self;
}
- (void)dealloc
{
  [_windows release];
  [super dealloc];
}
- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }
- (NSArray *)windows { return _windows; }
- (void)addWindow:(UIWindow *)window
{
  if (window != nil && [_windows containsObject:window] == NO)
    [_windows addObject:window];
}
- (void)sendEvent:(NSEvent *)event
{
  [NSApp sendEvent:event];
}
- (void)terminate:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification object:self];
  [NSApp terminate:sender];
}
@end

int UIApplicationMain(int argc, char **argv, NSString *principalClassName, NSString *delegateClassName)
{
  CREATE_AUTORELEASE_POOL(pool);
  UIApplication *application;
  Class delegateClass;
  id delegate;

  [NSApplication sharedApplication];
  application = [UIApplication sharedApplication];

  if (principalClassName != nil)
    {
      Class principalClass = NSClassFromString(principalClassName);
      if (principalClass != Nil && principalClass != [UIApplication class])
        application = (UIApplication *)[principalClass sharedApplication];
    }

  delegateClass = delegateClassName == nil ? Nil : NSClassFromString(delegateClassName);
  if (delegateClass != Nil)
    {
      delegate = [[delegateClass alloc] init];
      [application setDelegate:delegate];
    }

  if ([[application delegate] respondsToSelector:@selector(applicationDidFinishLaunching:)])
    [[application delegate] applicationDidFinishLaunching:application];

  [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidFinishLaunchingNotification object:application];
  [NSApp run];
  RELEASE(pool);
  return 0;
}
