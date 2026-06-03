#ifndef GNUSTEP_UIKIT_UISCROLLVIEW_H
#define GNUSTEP_UIKIT_UISCROLLVIEW_H

#import <UIKit/UIView.h>

@interface UIScrollView : UIView
{
  NSScrollView *_scrollView;
  UIView *_documentView;
  CGSize _contentSize;
}
- (CGSize)contentSize;
- (void)setContentSize:(CGSize)contentSize;
- (CGPoint)contentOffset;
- (void)setContentOffset:(CGPoint)contentOffset;
@end

#endif
