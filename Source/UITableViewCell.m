#import "UIKitPrivate.h"
#import <UIKit/UILabel.h>
#import <UIKit/UITableViewCell.h>
#import <UIKit/UIColor.h>

@implementation UITableViewCell
- (id)initWithStyle:(int)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithFrame:NSMakeRect(0, 0, 320, 44)];
  if (self != nil)
    {
      _reuseIdentifier = [reuseIdentifier copy];
      _selectionStyle = UITableViewCellSelectionStyleDefault;
      _textLabel = [[UILabel alloc] initWithFrame:NSMakeRect(12, 8, 296, 28)];
      [_textLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
      [self addSubview:_textLabel];
      if (style != UITableViewCellStyleDefault) {
        _detailTextLabel = [UILabel new]; _detailTextLabel.font = [UIFont systemFontOfSize:13];
        _detailTextLabel.textColor = [UIColor secondaryLabelColor]; [self addSubview:_detailTextLabel];
      }
      _imageView = [UIImageView new]; _imageView.contentMode = UIViewContentModeScaleAspectFit;
      [self addSubview:_imageView];
    }
  return self;
}
- (id)initWithFrame:(CGRect)frame
{
  self = [self initWithStyle:0 reuseIdentifier:nil];
  if (self != nil)
    [self setFrame:frame];
  return self;
}
- (void)dealloc
{
  [_detailTextLabel release]; [_imageView release];
  [_accessoryLabel release];
  [_textLabel release];
  [_reuseIdentifier release];
  [super dealloc];
}
- (UITableViewCellAccessoryType)accessoryType { return _accessoryType; }
- (void)setAccessoryType:(UITableViewCellAccessoryType)type
{
  _accessoryType = type;
  if (!_accessoryLabel) { _accessoryLabel = [[UILabel alloc] initWithFrame:CGRectZero]; [self addSubview:_accessoryLabel]; }
  _accessoryLabel.text = type == UITableViewCellAccessoryCheckmark ? @"✓" : type == UITableViewCellAccessoryNone ? @"" : @"›";
  [self setNeedsLayout];
}
- (void)layoutSubviews
{
  [super layoutSubviews];
  CGFloat reserve = _accessoryType == UITableViewCellAccessoryNone ? 0 : 24;
  CGFloat left = _imageView.image ? 52 : 12;
  CGFloat width = MAX(0,self.bounds.size.width-left-12-reserve);
  CGFloat detailHeight = _detailTextLabel.text.length ? [_detailTextLabel sizeThatFits:CGSizeMake(width,1000000)].height : 0;
  CGFloat textHeight = [_textLabel sizeThatFits:CGSizeMake(width,1000000)].height;
  CGFloat top = MAX(8,(self.bounds.size.height-textHeight-detailHeight)/2);
  _textLabel.frame = CGRectMake(left,top,width,textHeight);
  _detailTextLabel.frame = CGRectMake(left,top+textHeight,width,detailHeight);
  _imageView.frame = CGRectMake(12,MAX(0,(self.bounds.size.height-32)/2),32,32);
  _accessoryLabel.frame = CGRectMake(self.bounds.size.width-28,8,20,MAX(0,self.bounds.size.height-16));
}
- (UILabel *)detailTextLabel { return _detailTextLabel; }
- (UIImageView *)imageView { return _imageView; }
- (CGSize)sizeThatFits:(CGSize)size {
  CGFloat width = MAX(1,size.width-24-(_imageView.image ? 40 : 0)-(_accessoryType ? 24 : 0));
  CGFloat height = [_textLabel sizeThatFits:CGSizeMake(width,1000000)].height;
  if (_detailTextLabel.text.length) height += [_detailTextLabel sizeThatFits:CGSizeMake(width,1000000)].height;
  return CGSizeMake(size.width,MAX(44,height+16));
}
- (UILabel *)textLabel { return _textLabel; }
- (NSString *)reuseIdentifier { return _reuseIdentifier; }
- (UITableViewCellSelectionStyle)selectionStyle { return _selectionStyle; }
- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle { _selectionStyle = selectionStyle; [self setNeedsDisplay]; }
- (BOOL)isSelected { return _selected; }
- (void)setSelected:(BOOL)selected { [self setSelected:selected animated:NO]; }
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  _selected = selected; [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  if (_selected && _selectionStyle != UITableViewCellSelectionStyleNone) {
    [[NSColor colorWithCalibratedWhite:0.82 alpha:1] set]; NSRectFill(rect);
  }
}
- (void)prepareForReuse
{
  [self setSelected:NO animated:NO];
}
@end
