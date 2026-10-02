#ifndef GNUSTEP_UIKIT_UIPROGRESSVIEW_H
#define GNUSTEP_UIKIT_UIPROGRESSVIEW_H
#import <UIKit/UIView.h>
typedef NSInteger UIProgressViewStyle;
enum { UIProgressViewStyleDefault, UIProgressViewStyleBar };
@interface UIProgressView : UIView
{
  id _progressIndicator;
  UIProgressViewStyle _progressViewStyle;
}
- (id)initWithProgressViewStyle:(UIProgressViewStyle)style;
@property(nonatomic) float progress;
@property(nonatomic) UIProgressViewStyle progressViewStyle;
- (void)setProgress:(float)progress animated:(BOOL)animated;
@end
#endif
