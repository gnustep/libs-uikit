#ifndef GNUSTEP_UIKIT_UITABLEVIEWHEADERFOOTERVIEW_H
#define GNUSTEP_UIKIT_UITABLEVIEWHEADERFOOTERVIEW_H
#import <UIKit/UIView.h>
@class UILabel;
@interface UITableViewHeaderFooterView : UIView
{ UIView *_contentView; UILabel *_textLabel, *_detailTextLabel; NSString *_reuseIdentifier; }
- (id)initWithReuseIdentifier:(NSString *)identifier;
@property(nonatomic, readonly) UIView *contentView;
@property(nonatomic, readonly) UILabel *textLabel;
@property(nonatomic, readonly) UILabel *detailTextLabel;
@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
- (void)prepareForReuse;
@end
#endif
