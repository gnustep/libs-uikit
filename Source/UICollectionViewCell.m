#import "UIKitPrivate.h"
#import <UIKit/UICollectionViewCell.h>
#import <UIKit/UIColor.h>

static NSInteger
UICollectionViewCellSubviewOrdering(id left, id right, void *context)
{
  UICollectionViewCell *cell = (UICollectionViewCell *)context;

  if (left == [cell backgroundView])
    return NSOrderedAscending;
  if (right == [cell backgroundView])
    return NSOrderedDescending;
  if (left == [cell selectedBackgroundView])
    return NSOrderedAscending;
  if (right == [cell selectedBackgroundView])
    return NSOrderedDescending;
  return NSOrderedSame;
}

@implementation UICollectionViewCell
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _reuseIdentifier = [reuseIdentifier copy];
      _contentView = [[UIView alloc] initWithFrame:[self bounds]];
      [_contentView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
      [super addSubview:_contentView];
    }
  return self;
}
- (id)initWithFrame:(CGRect)frame
{
  return [self initWithFrame:frame reuseIdentifier:nil];
}
- (void)dealloc
{
  [_contentView release];
  [_backgroundView release];
  [_selectedBackgroundView release];
  [_reuseIdentifier release];
  [super dealloc];
}
- (UIView *)contentView { return _contentView; }
- (UIView *)backgroundView { return _backgroundView; }
- (void)setBackgroundView:(UIView *)backgroundView
{
  [_backgroundView removeFromSuperview];
  ASSIGN(_backgroundView, backgroundView);
  if (_backgroundView != nil)
    {
      [_backgroundView setFrame:[self bounds]];
      [_backgroundView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
      [super addSubview:_backgroundView];
      [self sortSubviewsUsingFunction:UICollectionViewCellSubviewOrdering context:self];
    }
}
- (UIView *)selectedBackgroundView { return _selectedBackgroundView; }
- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView
{
  [_selectedBackgroundView removeFromSuperview];
  ASSIGN(_selectedBackgroundView, selectedBackgroundView);
  if (_selectedBackgroundView != nil)
    {
      [_selectedBackgroundView setFrame:[self bounds]];
      [_selectedBackgroundView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
      [_selectedBackgroundView setHidden:(_selected == NO)];
      [super addSubview:_selectedBackgroundView];
      [self sortSubviewsUsingFunction:UICollectionViewCellSubviewOrdering context:self];
    }
}
- (void)_setReuseIdentifier:(NSString *)identifier { ASSIGNCOPY(_reuseIdentifier, identifier); }
- (NSString *)reuseIdentifier { return _reuseIdentifier; }
- (BOOL)isSelected { return _selected; }
- (void)setSelected:(BOOL)selected
{
  _selected = selected;
  [_selectedBackgroundView setHidden:(selected == NO)];
  if (_selectedBackgroundView == nil)
    [self setBackgroundColor:(selected ? [UIColor colorWithWhite:0.82 alpha:1.0] : nil)];
}
- (BOOL)isHighlighted { return _highlighted; }
- (void)setHighlighted:(BOOL)highlighted { _highlighted = highlighted; }
- (void)prepareForReuse
{
  [self setSelected:NO];
  [self setHighlighted:NO];
}
@end
