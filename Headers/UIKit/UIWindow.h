#ifndef GNUSTEP_UIKIT_UIWINDOW_H
#define GNUSTEP_UIKIT_UIWINDOW_H

#import <UIKit/UIKitTypes.h>

@class UIView, UIViewController, UIWindowScene;

@interface UIWindow : NSWindow
{
  UIViewController *_rootViewController;
  UIWindowScene *_windowScene;
}
- (id)initWithFrame:(CGRect)frame;
- (UIWindowScene *)windowScene;
- (void)setWindowScene:(UIWindowScene *)windowScene;
- (UIViewController *)rootViewController;
- (void)setRootViewController:(UIViewController *)controller;
- (void)makeKeyAndVisible;
- (void)addSubview:(UIView *)view;
@end

#endif
