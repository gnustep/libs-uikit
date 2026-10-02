#ifndef GNUSTEP_UIKIT_UICOLORPICKERVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UICOLORPICKERVIEWCONTROLLER_H
#import <UIKit/UIViewController.h>
@class UIColor, UIColorPickerViewController;
@protocol UIColorPickerViewControllerDelegate <NSObject>
@optional
- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)controller;
- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)controller;
@end
@interface UIColorPickerViewController : UIViewController
{ UIColor *_selectedColor; id _colorWell; id<UIColorPickerViewControllerDelegate> _delegate; }
@property(nonatomic, retain) UIColor *selectedColor;
@property(nonatomic, assign) id<UIColorPickerViewControllerDelegate> delegate;
@end
#endif
