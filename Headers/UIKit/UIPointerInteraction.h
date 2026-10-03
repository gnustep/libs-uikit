#ifndef GNUSTEP_UIKIT_UIPOINTERINTERACTION_H
#define GNUSTEP_UIKIT_UIPOINTERINTERACTION_H
#import <UIKit/UIInteraction.h>
@protocol UIPointerInteractionDelegate <NSObject> @end
@interface UIPointerInteraction : NSObject <UIInteraction> { UIView *_view; id<UIPointerInteractionDelegate> _delegate; BOOL _enabled, _inside; }
- (id)initWithDelegate:(id<UIPointerInteractionDelegate>)delegate;
@property(nonatomic, getter=isEnabled) BOOL enabled;
@property(nonatomic, readonly, assign) id<UIPointerInteractionDelegate> delegate;
@end
#endif
