#ifndef GNUSTEP_UIKIT_UISCROLLVIEW_H
#define GNUSTEP_UIKIT_UISCROLLVIEW_H

#import <UIKit/UIView.h>

@class UIScrollView;
@protocol UIScrollViewDelegate <NSObject>
@optional
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
@end

@interface UIScrollView : UIView
{
  UILayoutGuide *_contentLayoutGuide, *_frameLayoutGuide;
  id _scrollView;
  id _documentView;
  CGSize _contentSize;
  id _scrollDelegate;
  BOOL _updatingVisibleContent;
  UIScrollViewKeyboardDismissMode _keyboardDismissMode;
}
@property(nonatomic, readonly) UILayoutGuide *contentLayoutGuide;
@property(nonatomic, readonly) UILayoutGuide *frameLayoutGuide;
@property(nonatomic) UIScrollViewKeyboardDismissMode keyboardDismissMode;
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (CGRect)visibleContentRect;
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated;
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;
- (CGSize)contentSize;
- (void)setContentSize:(CGSize)contentSize;
- (CGPoint)contentOffset;
- (void)setContentOffset:(CGPoint)contentOffset;
@end

#endif
