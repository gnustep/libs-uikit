#ifndef GNUSTEP_UIKIT_UITEXTFORMATTINGVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UITEXTFORMATTINGVIEWCONTROLLER_H
#import <UIKit/UIViewController.h>
@class UIFont, UIColor, UITextFormattingViewController;
typedef NSString *UITextFormattingViewControllerChangeType;
extern UITextFormattingViewControllerChangeType const UITextFormattingViewControllerFontPointSizeChangeType;
extern UITextFormattingViewControllerChangeType const UITextFormattingViewControllerFontAttributesChangeType;
@interface UITextFormattingViewControllerConfiguration : NSObject <NSCopying> @end
@interface UITextFormattingViewControllerChangeValue : NSObject
{ UITextFormattingViewControllerChangeType _changeType; UIFont *_font; NSNumber *_numberValue; }
@property(nonatomic, readonly) UITextFormattingViewControllerChangeType changeType;
@property(nonatomic, readonly) UIFont *font;
@property(nonatomic, readonly) NSNumber *numberValue;
@end
@protocol UITextFormattingViewControllerDelegate <NSObject>
- (void)textFormattingViewController:(UITextFormattingViewController *)controller didChangeValue:(UITextFormattingViewControllerChangeValue *)change;
@optional
- (void)textFormattingDidFinish:(UITextFormattingViewController *)controller;
@end
@interface UITextFormattingViewController : UIViewController
{ UITextFormattingViewControllerConfiguration *_configuration; id<UITextFormattingViewControllerDelegate> _delegate; CGFloat _pointSize; BOOL _bold; }
- (id)initWithConfiguration:(UITextFormattingViewControllerConfiguration *)configuration;
@property(nonatomic, readonly, copy) UITextFormattingViewControllerConfiguration *configuration;
@property(nonatomic, assign) id<UITextFormattingViewControllerDelegate> delegate;
@end
#endif
