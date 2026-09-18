#ifndef GNUSTEP_UIKIT_UIWINDOW_H
#define GNUSTEP_UIKIT_UIWINDOW_H
#import <UIKit/UIView.h>
@class UIViewController, UIWindowScene;
typedef CGFloat UIWindowLevel;
extern const UIWindowLevel UIWindowLevelNormal;
extern const UIWindowLevel UIWindowLevelAlert;
extern const UIWindowLevel UIWindowLevelStatusBar;
@interface UIWindow : UIView
{
  id _nativeWindow;
  UIViewController *_rootViewController;
  UIWindowScene *_windowScene;
  UIResponder *_firstResponder;
  UIWindowLevel _windowLevel;
}
- (UIWindowScene *)windowScene;
- (void)setWindowScene:(UIWindowScene *)scene;
- (UIViewController *)rootViewController;
- (void)setRootViewController:(UIViewController *)controller;
- (BOOL)isKeyWindow;
- (void)makeKeyWindow;
- (void)makeKeyAndVisible;
- (UIWindowLevel)windowLevel;
- (void)setWindowLevel:(UIWindowLevel)level;
- (void)sendEvent:(UIEvent *)event;
@end
#endif
