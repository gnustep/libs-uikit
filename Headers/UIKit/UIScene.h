#ifndef GNUSTEP_UIKIT_UISCENE_H
#define GNUSTEP_UIKIT_UISCENE_H

#import <UIKit/UIResponder.h>

@class UISceneSession;

typedef int UISceneActivationState;
enum {
  UISceneActivationStateUnattached = -1,
  UISceneActivationStateForegroundActive = 0,
  UISceneActivationStateForegroundInactive = 1,
  UISceneActivationStateBackground = 2
};

@protocol UISceneDelegate
@optional
- (void)sceneDidDisconnect:(UIScene *)scene;
- (void)sceneDidBecomeActive:(UIScene *)scene;
- (void)sceneWillResignActive:(UIScene *)scene;
- (void)sceneWillEnterForeground:(UIScene *)scene;
- (void)sceneDidEnterBackground:(UIScene *)scene;
@end

@interface UIScene : UIResponder
{
  UISceneSession *_session;
  id _delegate;
  UISceneActivationState _activationState;
}
- (id)initWithSession:(UISceneSession *)session;
- (UISceneSession *)session;
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (UISceneActivationState)activationState;
- (void)setActivationState:(UISceneActivationState)state;
@end

#endif
