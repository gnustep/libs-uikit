#ifndef GNUSTEP_UIKIT_UINAVIGATIONCONTROLLER_H
#define GNUSTEP_UIKIT_UINAVIGATIONCONTROLLER_H

#import <UIKit/UIViewController.h>

@class UINavigationBar;
@interface UINavigationController : UIViewController
{
  NSMutableArray *_viewControllers;
  UIView *_contentHost;
  id _backButton;
  id _titleLabel;
  UINavigationBar *_navigationBar;
}
- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (NSArray *)viewControllers;
- (UIViewController *)topViewController;
- (void)setViewControllers:(NSArray *)controllers animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
@end

#endif
