#ifndef GNUSTEP_UIKIT_UIALERTCONTROLLER_H
#define GNUSTEP_UIKIT_UIALERTCONTROLLER_H
#import <UIKit/UIViewController.h>
typedef NSInteger UIAlertControllerStyle;
enum { UIAlertControllerStyleActionSheet, UIAlertControllerStyleAlert };
typedef NSInteger UIAlertActionStyle;
enum { UIAlertActionStyleDefault, UIAlertActionStyleCancel, UIAlertActionStyleDestructive };
@class UIAlertAction;
DEFINE_BLOCK_TYPE(UIAlertActionHandler, void, UIAlertAction *);
@interface UIAlertAction : NSObject <NSCopying>
{
  NSString *_title;
  UIAlertActionStyle _style;
  UIAlertActionHandler _handler;
  BOOL _enabled;
}
+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(UIAlertActionHandler)handler;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) UIAlertActionStyle style;
@property(nonatomic, getter=isEnabled) BOOL enabled;
@end
@interface UIAlertController : UIViewController
{
  NSString *_message;
  UIAlertControllerStyle _preferredStyle;
  NSMutableArray *_actions;
}
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, readonly) UIAlertControllerStyle preferredStyle;
@property(nonatomic, readonly) NSArray<UIAlertAction *> *actions;
- (void)addAction:(UIAlertAction *)action;
@end
#endif
