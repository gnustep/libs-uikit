#ifndef GNUSTEP_UIKIT_UIACTIVITYINDICATORVIEW_H
#define GNUSTEP_UIKIT_UIACTIVITYINDICATORVIEW_H

#import <UIKit/UIView.h>

@interface UIActivityIndicatorView : UIView
{
  id _progressIndicator;
  CGFloat _indicatorSize;
  BOOL _animating, _hidesWhenStopped;
}
- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;
@property(nonatomic) BOOL hidesWhenStopped;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
@end

#endif
