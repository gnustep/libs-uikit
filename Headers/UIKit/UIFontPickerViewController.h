#ifndef GNUSTEP_UIKIT_UIFONTPICKERVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UIFONTPICKERVIEWCONTROLLER_H
#import <UIKit/UIViewController.h>
#import <UIKit/UIFontDescriptor.h>
@class UIFontPickerViewController;
@protocol UIFontPickerViewControllerDelegate <NSObject>
@optional
- (void)fontPickerViewControllerDidPickFont:(UIFontPickerViewController *)controller;
- (void)fontPickerViewControllerDidCancel:(UIFontPickerViewController *)controller;
@end
@interface UIFontPickerViewControllerConfiguration : NSObject <NSCopying>
{ BOOL _includeFaces; }
@property(nonatomic) BOOL includeFaces;
@end
@interface UIFontPickerViewController : UIViewController
{ UIFontPickerViewControllerConfiguration *_configuration; UIFontDescriptor *_selectedFontDescriptor; id _fontMenu; id<UIFontPickerViewControllerDelegate> _delegate; }
- (id)initWithConfiguration:(UIFontPickerViewControllerConfiguration *)configuration;
@property(nonatomic, readonly, copy) UIFontPickerViewControllerConfiguration *configuration;
@property(nonatomic, retain) UIFontDescriptor *selectedFontDescriptor;
@property(nonatomic, assign) id<UIFontPickerViewControllerDelegate> delegate;
@end
#endif
