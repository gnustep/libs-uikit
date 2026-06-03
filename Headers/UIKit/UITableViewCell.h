#ifndef GNUSTEP_UIKIT_UITABLEVIEWCELL_H
#define GNUSTEP_UIKIT_UITABLEVIEWCELL_H

#import <UIKit/UIView.h>

@class UILabel;

@interface UITableViewCell : UIView
{
  UILabel *_textLabel;
  NSString *_reuseIdentifier;
}
- (id)initWithStyle:(int)style reuseIdentifier:(NSString *)reuseIdentifier;
- (UILabel *)textLabel;
- (NSString *)reuseIdentifier;
@end

#endif
