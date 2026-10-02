#ifndef GNUSTEP_UIKIT_UIPAGEVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UIPAGEVIEWCONTROLLER_H
#import <UIKit/UIViewController.h>
typedef NSInteger UIPageViewControllerTransitionStyle;
enum { UIPageViewControllerTransitionStylePageCurl, UIPageViewControllerTransitionStyleScroll };
typedef NSInteger UIPageViewControllerNavigationOrientation;
enum { UIPageViewControllerNavigationOrientationHorizontal, UIPageViewControllerNavigationOrientationVertical };
typedef NSInteger UIPageViewControllerNavigationDirection;
enum { UIPageViewControllerNavigationDirectionForward, UIPageViewControllerNavigationDirectionReverse };
DEFINE_BLOCK_TYPE(UIPageViewControllerCompletion, void, BOOL);
@interface UIPageViewController : UIViewController
{ NSArray *_viewControllers; UIPageViewControllerTransitionStyle _transitionStyle; UIPageViewControllerNavigationOrientation _navigationOrientation; }
- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)orientation options:(NSDictionary *)options;
@property(nonatomic, readonly, copy) NSArray *viewControllers;
@property(nonatomic, readonly) UIPageViewControllerTransitionStyle transitionStyle;
@property(nonatomic, readonly) UIPageViewControllerNavigationOrientation navigationOrientation;
- (void)setViewControllers:(NSArray *)controllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(UIPageViewControllerCompletion)completion;
@end
#endif
