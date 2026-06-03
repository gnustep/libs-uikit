#ifndef GNUSTEP_UIKIT_UIACTIVITYINDICATORVIEW_H
#define GNUSTEP_UIKIT_UIACTIVITYINDICATORVIEW_H

#import <UIKit/UIView.h>

@interface UIActivityIndicatorView : UIView
{
  NSProgressIndicator *_progressIndicator;
}
- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
@end

#endif
