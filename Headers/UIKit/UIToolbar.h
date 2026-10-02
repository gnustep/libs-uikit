#ifndef GNUSTEP_UIKIT_UITOOLBAR_H
#define GNUSTEP_UIKIT_UITOOLBAR_H
#import <UIKit/UIView.h>
@interface UIToolbar : UIView { NSArray *_items; }
@property(nonatomic, copy) NSArray *items;
- (void)setItems:(NSArray *)items animated:(BOOL)animated;
@end
#endif
