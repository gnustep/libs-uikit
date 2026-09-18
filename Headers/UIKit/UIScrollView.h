#ifndef GNUSTEP_UIKIT_UISCROLLVIEW_H
#define GNUSTEP_UIKIT_UISCROLLVIEW_H

#import <UIKit/UIView.h>

@interface UIScrollView : UIView
{
  id _scrollView;
  id _documentView;
  CGSize _contentSize;
  id _scrollDelegate;
  BOOL _updatingVisibleContent;
}
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (CGRect)visibleContentRect;
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;
- (CGSize)contentSize;
- (void)setContentSize:(CGSize)contentSize;
- (CGPoint)contentOffset;
- (void)setContentOffset:(CGPoint)contentOffset;
@end

#endif
