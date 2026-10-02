#ifndef GNUSTEP_UIKIT_UIVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UIVIEWCONTROLLER_H

#import <UIKit/UIResponder.h>

@class UIView, UIWindow, UINavigationController;
DEFINE_BLOCK_TYPE_NO_ARGS(UIViewControllerCompletion, void);

@interface UIViewController : UIResponder
{
  UIViewController *_presentedViewController, *_presentingViewController;
  UIWindow *_presentationWindow;
  UIView *_view;
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
