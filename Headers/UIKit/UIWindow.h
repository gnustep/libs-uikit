#ifndef GNUSTEP_UIKIT_UIWINDOW_H
#define GNUSTEP_UIKIT_UIWINDOW_H

#import <UIKit/UIKitTypes.h>

@class UIView, UIViewController;

@interface UIWindow : NSWindow
{
  UIViewController *_rootViewController;
}
- (id)initWithFrame:(CGRect)frame;
- (UIViewController *)rootViewController;
- (void)setRootViewController:(UIViewController *)controller;
- (void)makeKeyAndVisible;
- (void)addSubview:(UIView *)view;
@end

#endif
