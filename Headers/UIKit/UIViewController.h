#ifndef GNUSTEP_UIKIT_UIVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UIVIEWCONTROLLER_H

#import <UIKit/UIResponder.h>

@class UIView, UIWindow, UINavigationController, UINavigationItem, UITabBarItem, UIPopoverPresentationController;
typedef NSInteger UIModalPresentationStyle;
enum { UIModalPresentationFullScreen = 0, UIModalPresentationPageSheet = 1, UIModalPresentationFormSheet = 2, UIModalPresentationPopover = 7, UIModalPresentationAutomatic = -2 };
DEFINE_BLOCK_TYPE_NO_ARGS(UIViewControllerCompletion, void);

@interface UIViewController : UIResponder
{
  UIViewController *_presentedViewController, *_presentingViewController;
  UIWindow *_presentationWindow;
  UIView *_view;
  UINavigationItem *_navigationItem;
  UITabBarItem *_tabBarItem;
  UIPopoverPresentationController *_popoverPresentationController;
  BOOL _definesPresentationContext;
  UIModalPresentationStyle _modalPresentationStyle;
  NSString *_title;
  NSArray *_nibTopLevelObjects;
  NSString *_nibName;
  NSBundle *_nibBundle;
  NSMutableArray *_childViewControllers;
  UIViewController *_parentViewController;
  BOOL _viewLoaded;
  BOOL _appearing;
  BOOL _appearanceAnimated;
  BOOL _visible;
}
@property(nonatomic, readonly) UINavigationItem *navigationItem;
@property(nonatomic, retain) UITabBarItem *tabBarItem;
@property(nonatomic, readonly) UIPopoverPresentationController *popoverPresentationController;
@property(nonatomic) BOOL definesPresentationContext;
@property(nonatomic) UIModalPresentationStyle modalPresentationStyle;
@property(nonatomic, readonly) UINavigationController *navigationController;
@property(nonatomic, readonly) UIViewController *presentedViewController;
@property(nonatomic, readonly) UIViewController *presentingViewController;
- (void)presentViewController:(UIViewController *)controller animated:(BOOL)animated completion:(UIViewControllerCompletion)completion;
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(UIViewControllerCompletion)completion;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (BOOL)isViewLoaded;
- (void)loadViewIfNeeded;
- (UIViewController *)parentViewController;
- (NSArray *)childViewControllers;
- (void)addChildViewController:(UIViewController *)controller;
- (void)removeFromParentViewController;
- (void)willMoveToParentViewController:(UIViewController *)parent;
- (void)didMoveToParentViewController:(UIViewController *)parent;
- (void)beginAppearanceTransition:(BOOL)appearing animated:(BOOL)animated;
- (void)endAppearanceTransition;
- (BOOL)_isVisible;
- (NSArray *)_appearanceChildren;
- (UIView *)view;
- (void)setView:(UIView *)view;
- (void)loadView;
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;
- (NSString *)title;
- (void)setTitle:(NSString *)title;
@end

#endif
