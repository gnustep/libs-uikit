#ifndef GNUSTEP_UIKIT_UIMENU_H
#define GNUSTEP_UIKIT_UIMENU_H
#import <UIKit/UIKitTypes.h>
@class UIImage, UIView;
typedef NSUInteger UIMenuElementAttributes;
enum { UIMenuElementAttributesDisabled=1, UIMenuElementAttributesDestructive=2, UIMenuElementAttributesHidden=4 };
typedef NSInteger UIMenuElementState;
enum { UIMenuElementStateOff, UIMenuElementStateOn, UIMenuElementStateMixed };
@interface UIMenuElement : NSObject <NSCopying> { NSString *_title; UIImage *_image; UIMenuElementAttributes _attributes; UIMenuElementState _state; }
@property(nonatomic, copy) NSString *title;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic) UIMenuElementAttributes attributes;
@property(nonatomic) UIMenuElementState state;
@end
@class UIAction;
DEFINE_BLOCK_TYPE(UIActionHandler, void, UIAction *);
@interface UIAction : UIMenuElement { UIActionHandler _handler; }
+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image identifier:(NSString *)identifier handler:(UIActionHandler)handler;
@end
@interface UICommand : UIMenuElement { SEL _action; id _propertyList; }
+ (instancetype)commandWithTitle:(NSString *)title image:(UIImage *)image action:(SEL)action propertyList:(id)propertyList;
@property(nonatomic, readonly) SEL action;
@property(nonatomic, readonly) id propertyList;
@end
@interface UIMenu : UIMenuElement { NSArray *_children; }
+ (instancetype)menuWithTitle:(NSString *)title children:(NSArray *)children;
@property(nonatomic, readonly, copy) NSArray *children;
@end
#endif
