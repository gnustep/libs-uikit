#ifndef GNUSTEP_UIKIT_UISTACKVIEW_H
#define GNUSTEP_UIKIT_UISTACKVIEW_H

#import <UIKit/UIView.h>

@interface UIStackView : UIView
{
  NSMutableArray *_arrangedSubviews;
  NSArray *_arrangementConstraints;
  UILayoutConstraintAxis _axis;
  UIStackViewDistribution _distribution;
  UIStackViewAlignment _alignment;
  CGFloat _spacing;
}
- (id)initWithArrangedSubviews:(NSArray *)views;
- (NSArray *)arrangedSubviews;
- (void)addArrangedSubview:(UIView *)view;
- (void)insertArrangedSubview:(UIView *)view atIndex:(NSUInteger)stackIndex;
- (void)removeArrangedSubview:(UIView *)view;
- (UILayoutConstraintAxis)axis;
- (void)setAxis:(UILayoutConstraintAxis)axis;
- (UIStackViewDistribution)distribution;
- (void)setDistribution:(UIStackViewDistribution)distribution;
- (UIStackViewAlignment)alignment;
- (void)setAlignment:(UIStackViewAlignment)alignment;
- (CGFloat)spacing;
- (void)setSpacing:(CGFloat)spacing;
@end

#endif
