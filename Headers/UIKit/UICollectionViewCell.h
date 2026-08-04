#ifndef GNUSTEP_UIKIT_UICOLLECTIONVIEWCELL_H
#define GNUSTEP_UIKIT_UICOLLECTIONVIEWCELL_H

#import <UIKit/UIView.h>

@interface UICollectionViewCell : UIView
{
  UIView *_contentView;
  UIView *_backgroundView;
  UIView *_selectedBackgroundView;
  NSString *_reuseIdentifier;
  BOOL _selected;
  BOOL _highlighted;
}
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (UIView *)contentView;
- (UIView *)backgroundView;
- (void)setBackgroundView:(UIView *)backgroundView;
- (UIView *)selectedBackgroundView;
- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView;
- (NSString *)reuseIdentifier;
- (BOOL)isSelected;
- (void)setSelected:(BOOL)selected;
- (BOOL)isHighlighted;
- (void)setHighlighted:(BOOL)highlighted;
- (void)prepareForReuse;
@end

#endif
