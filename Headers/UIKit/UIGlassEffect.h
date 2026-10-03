#ifndef GNUSTEP_UIKIT_UIGLASSEFFECT_H
#define GNUSTEP_UIKIT_UIGLASSEFFECT_H
#import <UIKit/UIVisualEffectView.h>
@class UIColor;
typedef NSInteger UIGlassEffectStyle;
enum { UIGlassEffectStyleRegular, UIGlassEffectStyleClear };
@interface UIGlassEffect : UIVisualEffect { UIGlassEffectStyle _style; UIColor *_tintColor; BOOL _interactive; }
+ (instancetype)effectWithStyle:(UIGlassEffectStyle)style;
@property(nonatomic, retain) UIColor *tintColor;
@property(nonatomic, getter=isInteractive) BOOL interactive;
@end
@interface UIGlassContainerEffect : UIVisualEffect { CGFloat _spacing; }
@property(nonatomic) CGFloat spacing;
@end
#endif
