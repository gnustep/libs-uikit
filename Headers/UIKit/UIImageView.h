#ifndef GNUSTEP_UIKIT_UIIMAGEVIEW_H
#define GNUSTEP_UIKIT_UIIMAGEVIEW_H

#import <UIKit/UIView.h>

@class UIImage;

@interface UIImageView : UIView
{
  UIImage *_image;
}
- (id)initWithImage:(UIImage *)image;
- (UIImage *)image;
- (void)setImage:(UIImage *)image;
@end

#endif
