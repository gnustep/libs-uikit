#ifndef GNUSTEP_UIKIT_UINAVIGATIONCONTROLLER_H
#define GNUSTEP_UIKIT_UINAVIGATIONCONTROLLER_H

#import <UIKit/UIViewController.h>

@interface UINavigationController : UIViewController
{
  NSMutableArray *_viewControllers;
}
- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (NSArray *)viewControllers;
- (UIViewController *)topViewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
@end

#endif
