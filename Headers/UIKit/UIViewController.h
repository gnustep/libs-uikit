#ifndef GNUSTEP_UIKIT_UIVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UIVIEWCONTROLLER_H

#import <UIKit/UIResponder.h>

@class UIView;

@interface UIViewController : UIResponder
{
  UIView *_view;
  NSString *_title;
  NSArray *_nibTopLevelObjects;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (UIView *)view;
- (void)setView:(UIView *)view;
- (void)loadView;
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (NSString *)title;
- (void)setTitle:(NSString *)title;
@end

#endif
