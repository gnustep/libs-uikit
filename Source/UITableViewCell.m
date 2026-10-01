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
  [_textLabel release];
  [_reuseIdentifier release];
  [super dealloc];
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
