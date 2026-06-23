#ifndef GNUSTEP_UIKIT_UITABLEVIEWCELL_H
#define GNUSTEP_UIKIT_UITABLEVIEWCELL_H

#import <UIKit/UIView.h>

@class UILabel;

@interface UITableViewCell : UIView
{
  UILabel *_textLabel;
  NSString *_reuseIdentifier;
  BOOL _selected;
  UITableViewCellSelectionStyle _selectionStyle;
}
- (id)initWithStyle:(int)style reuseIdentifier:(NSString *)reuseIdentifier;
- (UILabel *)textLabel;
- (NSString *)reuseIdentifier;
- (UITableViewCellSelectionStyle)selectionStyle;
- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle;
- (BOOL)isSelected;
- (void)setSelected:(BOOL)selected;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)prepareForReuse;
@end

#endif
