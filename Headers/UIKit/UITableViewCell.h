#ifndef GNUSTEP_UIKIT_UITABLEVIEWCELL_H
#define GNUSTEP_UIKIT_UITABLEVIEWCELL_H

#import <UIKit/UIView.h>

@class UILabel, UIImageView;

@interface UITableViewCell : UIView
{
  UITableViewCellAccessoryType _accessoryType;
  UILabel *_accessoryLabel;
  UILabel *_textLabel, *_detailTextLabel;
  UIImageView *_imageView;
  NSString *_reuseIdentifier;
  BOOL _selected;
  UITableViewCellSelectionStyle _selectionStyle;
}
- (id)initWithStyle:(int)style reuseIdentifier:(NSString *)reuseIdentifier;
@property(nonatomic) UITableViewCellAccessoryType accessoryType;
- (UILabel *)textLabel;
@property(nonatomic, readonly) UILabel *detailTextLabel;
@property(nonatomic, readonly) UIImageView *imageView;
- (NSString *)reuseIdentifier;
- (UITableViewCellSelectionStyle)selectionStyle;
- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle;
- (BOOL)isSelected;
- (void)setSelected:(BOOL)selected;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)prepareForReuse;
@end

#endif
