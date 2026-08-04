#import <UIKit/UIApplication.h>
#import <UIKit/UIEvent.h>
#import <UIKit/UISceneConfiguration.h>
#import <UIKit/UISceneSession.h>
#import <UIKit/UIWindowScene.h>
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
    {
      _windows = [[NSMutableArray alloc] init];
      _connectedScenes = [[NSMutableSet alloc] init];
      _openSessions = [[NSMutableSet alloc] init];
    }
  return self;
}
- (void)dealloc
{
  [_windows release];
  [_connectedScenes release];
  [_openSessions release];
  [super dealloc];
}
- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }
- (NSArray *)windows { return _windows; }
- (NSSet *)connectedScenes { return _connectedScenes; }
- (NSSet *)openSessions { return _openSessions; }
- (UIWindowScene *)_defaultWindowScene
{
  NSEnumerator *enumerator = [_connectedScenes objectEnumerator];
  UIScene *scene;
  UISceneConfiguration *configuration;
  UISceneSession *session;
  UIWindowScene *windowScene;

  while ((scene = [enumerator nextObject]) != nil)
    {
      if ([scene isKindOfClass:[UIWindowScene class]])
        return (UIWindowScene *)scene;
    }

  configuration = [UISceneConfiguration configurationWithName:@"Default Configuration"
                                                  sessionRole:UISceneSessionRoleApplication];
  [configuration setSceneClass:[UIWindowScene class]];
  session = [[[UISceneSession alloc] initWithRole:UISceneSessionRoleApplication
                                    configuration:configuration] autorelease];
  windowScene = [[[UIWindowScene alloc] initWithSession:session] autorelease];
  [windowScene setActivationState:UISceneActivationStateForegroundActive];
  [_openSessions addObject:session];
  [_connectedScenes addObject:windowScene];
  return windowScene;
}
- (void)addWindow:(UIWindow *)window
{
  if (window != nil && [_windows containsObject:window] == NO)
    {
      [_windows addObject:window];
      if ([window windowScene] == nil)
        [window setWindowScene:[self _defaultWindowScene]];
      [[window windowScene] addWindow:window];
    }
}
- (void)sendEvent:(NSEvent *)event
{
  NSEvent *nativeEvent = nil;

  if ([event isKindOfClass:[UIEvent class]])
    nativeEvent = [(UIEvent *)event NSEvent];
  else
    nativeEvent = (NSEvent *)event;

  if (nativeEvent != nil)
    [NSApp sendEvent:nativeEvent];
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
