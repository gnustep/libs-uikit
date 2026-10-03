#ifndef GNUSTEP_UIKIT_UIEDITMENUINTERACTION_H
#define GNUSTEP_UIKIT_UIEDITMENUINTERACTION_H
#import <UIKit/UIInteraction.h>
#import <UIKit/UIMenu.h>
@class UIEditMenuInteraction;
@interface UIEditMenuConfiguration : NSObject { CGPoint _sourcePoint; id<NSCopying> _identifier; }
+ (instancetype)configurationWithIdentifier:(id<NSCopying>)identifier sourcePoint:(CGPoint)point;
@property(nonatomic, readonly) CGPoint sourcePoint;
@property(nonatomic, readonly, copy) id<NSCopying> identifier;
@end
@protocol UIEditMenuInteractionDelegate <NSObject>
@optional
- (UIMenu *)editMenuInteraction:(UIEditMenuInteraction *)interaction menuForConfiguration:(UIEditMenuConfiguration *)configuration suggestedActions:(NSArray *)suggestedActions;
@end
@interface UIEditMenuInteraction : NSObject <UIInteraction> { UIView *_view; id<UIEditMenuInteractionDelegate> _delegate; id _nativeMenu; }
- (id)initWithDelegate:(id<UIEditMenuInteractionDelegate>)delegate;
@property(nonatomic, readonly, assign) id<UIEditMenuInteractionDelegate> delegate;
- (void)presentEditMenuWithConfiguration:(UIEditMenuConfiguration *)configuration;
- (void)dismissMenu;
@end
#endif
