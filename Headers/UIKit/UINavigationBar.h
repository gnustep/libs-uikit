#ifndef GNUSTEP_UIKIT_UINAVIGATIONBAR_H
#define GNUSTEP_UIKIT_UINAVIGATIONBAR_H
#import <UIKit/UIView.h>
@class UINavigationItem;
@interface UINavigationBar : UIView { NSArray *_items; UIView *_leftView, *_rightView, *_titleView, *_searchView; }
@property(nonatomic, copy) NSArray *items;
@property(nonatomic, readonly) UINavigationItem *topItem;
- (void)setItems:(NSArray *)items animated:(BOOL)animated;
@end
#endif
