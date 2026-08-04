#ifndef GNUSTEP_UIKIT_UIAPPLICATION_H
#define GNUSTEP_UIKIT_UIAPPLICATION_H

#import <UIKit/UIResponder.h>

@class UIApplication, UIEvent, UIScene, UISceneSession, UIWindow;

extern NSString *UIApplicationDidFinishLaunchingNotification;
extern NSString *UIApplicationWillTerminateNotification;

@protocol UIApplicationDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application;
@end

@interface UIApplication : UIResponder
{
  id _delegate;
  NSMutableArray *_windows;
  NSMutableSet *_connectedScenes;
  NSMutableSet *_openSessions;
}
+ (UIApplication *)sharedApplication;
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (NSArray *)windows;
- (NSSet *)connectedScenes;
- (NSSet *)openSessions;
- (void)addWindow:(UIWindow *)window;
- (void)sendEvent:(UIEvent *)event;
- (void)terminate:(id)sender;
@end

int UIApplicationMain(int argc, char **argv, NSString *principalClassName, NSString *delegateClassName);

#endif
