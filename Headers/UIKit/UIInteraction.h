#ifndef GNUSTEP_UIKIT_UIINTERACTION_H
#define GNUSTEP_UIKIT_UIINTERACTION_H
#import <UIKit/UIKitTypes.h>
@class UIView;
@protocol UIInteraction <NSObject>
@property(nonatomic, readonly, assign) UIView *view;
- (void)willMoveToView:(UIView *)view;
- (void)didMoveToView:(UIView *)view;
@end
#endif
