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
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_nativeActivation:) name:NSApplicationDidBecomeActiveNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_nativeActivation:) name:NSApplicationWillResignActiveNotification object:nil];
    }
  return self;
}
- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  [windowScene setActivationState:UISceneActivationStateForegroundInactive];
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
- (void)removeWindow:(UIWindow *)window
{
  [[window retain] autorelease];
  UIWindowScene *scene = [[[window windowScene] retain] autorelease];
  [window setWindowScene:nil];
  [_windows removeObjectIdenticalTo:window];
  if (scene && [[scene windows] count] == 0) {
    [scene setActivationState:UISceneActivationStateUnattached];
    [_openSessions removeObject:[scene session]];
    [_connectedScenes removeObject:scene];
  }
}
- (void)_nativeActivation:(NSNotification *)notification
{
  BOOL active = [[notification name] isEqual:NSApplicationDidBecomeActiveNotification];
  for (UIScene *scene in [[_connectedScenes copy] autorelease])
    [scene setActivationState:active ? UISceneActivationStateForegroundActive : UISceneActivationStateForegroundInactive];
  SEL selector = active ? @selector(applicationDidBecomeActive:) : @selector(applicationWillResignActive:);
  if ([_delegate respondsToSelector:selector]) [_delegate performSelector:selector withObject:self];
}
- (void)sendEvent:(UIEvent *)event
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
  Class applicationClass = principalClassName ? NSClassFromString(principalClassName) : [UIApplication class];
  application = [applicationClass sharedApplication];

  delegateClass = delegateClassName == nil ? Nil : NSClassFromString(delegateClassName);
  if (delegateClass != Nil)
    {
      delegate = [[delegateClass alloc] init];
      [application setDelegate:delegate];
    }

  if ([[application delegate] respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)])
    [(id<UIApplicationDelegate>)[application delegate] application:application didFinishLaunchingWithOptions:nil];
  else if ([[application delegate] respondsToSelector:@selector(applicationDidFinishLaunching:)])
    [(id<UIApplicationDelegate>)[application delegate] applicationDidFinishLaunching:application];

  [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidFinishLaunchingNotification object:application];
  [NSApp run];
  RELEASE(pool);
  return 0;
}
