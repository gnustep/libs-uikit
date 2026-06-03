#import <UIKit/UILabel.h>
#import <UIKit/UITableViewCell.h>

@implementation UITableViewCell
- (id)initWithStyle:(int)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithFrame:NSMakeRect(0, 0, 320, 44)];
  if (self != nil)
    {
      _reuseIdentifier = [reuseIdentifier copy];
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
@end
