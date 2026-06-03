#ifndef GNUSTEP_UIKIT_UIAPPLICATION_H
#define GNUSTEP_UIKIT_UIAPPLICATION_H

#import <UIKit/UIResponder.h>

@class UIApplication, UIWindow;

extern NSString *UIApplicationDidFinishLaunchingNotification;
extern NSString *UIApplicationWillTerminateNotification;

@protocol UIApplicationDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application;
@end

@interface UIApplication : UIResponder
{
  id _delegate;
  NSMutableArray *_windows;
}
+ (UIApplication *)sharedApplication;
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (NSArray *)windows;
- (void)addWindow:(UIWindow *)window;
- (void)sendEvent:(NSEvent *)event;
- (void)terminate:(id)sender;
@end

int UIApplicationMain(int argc, char **argv, NSString *principalClassName, NSString *delegateClassName);

#endif
