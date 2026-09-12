#ifndef GNUSTEP_UIKIT_UITABBARCONTROLLER_H
#define GNUSTEP_UIKIT_UITABBARCONTROLLER_H

#import <UIKit/UIViewController.h>

@interface UITabBarController : UIViewController
{
  NSArray *_viewControllers;
  UIViewController *_selectedViewController;
  UIView *_contentHost;
  id _tabControl;
}
- (NSUInteger)selectedIndex;
- (void)setSelectedIndex:(NSUInteger)index;
- (NSArray *)viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers;
- (UIViewController *)selectedViewController;
- (void)setSelectedViewController:(UIViewController *)selectedViewController;
@end

#endif
