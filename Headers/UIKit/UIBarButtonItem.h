#ifndef GNUSTEP_UIKIT_UIBARBUTTONITEM_H
#define GNUSTEP_UIKIT_UIBARBUTTONITEM_H
#import <UIKit/UIKitTypes.h>
@class UIView;
typedef NSInteger UIBarButtonItemStyle;
enum { UIBarButtonItemStylePlain, UIBarButtonItemStyleBordered, UIBarButtonItemStyleDone };
typedef NSInteger UIBarButtonSystemItem;
enum { UIBarButtonSystemItemDone, UIBarButtonSystemItemCancel, UIBarButtonSystemItemEdit, UIBarButtonSystemItemSave,
  UIBarButtonSystemItemAdd, UIBarButtonSystemItemFlexibleSpace, UIBarButtonSystemItemFixedSpace };
@interface UIBarButtonItem : NSObject
{ NSString *_title; id _target; SEL _action; BOOL _enabled; NSInteger _systemItem; UIView *_customView; }
- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)item target:(id)target action:(SEL)action;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) id target;
@property(nonatomic) SEL action;
@property(nonatomic, getter=isEnabled) BOOL enabled;
@property(nonatomic, retain) UIView *customView;
@end
#endif
