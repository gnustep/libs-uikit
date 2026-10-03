#ifndef GNUSTEP_UIKIT_UIVISUALEFFECTVIEW_H
#define GNUSTEP_UIKIT_UIVISUALEFFECTVIEW_H
#import <UIKit/UIView.h>
typedef NSInteger UIBlurEffectStyle;
enum { UIBlurEffectStyleExtraLight = 0, UIBlurEffectStyleLight = 1, UIBlurEffectStyleDark = 2, UIBlurEffectStyleRegular = 4, UIBlurEffectStyleProminent = 5, UIBlurEffectStyleSystemMaterial = 6 };
@interface UIVisualEffect : NSObject @end
@interface UIBlurEffect : UIVisualEffect
{ UIBlurEffectStyle _style; }
+ (UIBlurEffect *)effectWithStyle:(UIBlurEffectStyle)style;
@end
@interface UIVisualEffectView : UIView
{ UIVisualEffect *_effect; UIView *_contentView; BOOL _glassHovered; }
- (id)initWithEffect:(UIVisualEffect *)effect;
@property(nonatomic, retain) UIVisualEffect *effect;
@property(nonatomic, readonly) UIView *contentView;
@end
#endif
