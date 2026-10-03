#ifndef GNUSTEP_UIKIT_UITOOLTIPINTERACTION_H
#define GNUSTEP_UIKIT_UITOOLTIPINTERACTION_H
#import <UIKit/UIInteraction.h>
@interface UIToolTipInteraction : NSObject <UIInteraction> { UIView *_view; NSString *_defaultToolTip; }
- (id)initWithDefaultToolTip:(NSString *)text;
@property(nonatomic, copy) NSString *defaultToolTip;
@end
#endif
