#import "UIKitPrivate.h"
#import <UIKit/UIStackView.h>

@implementation UIStackView
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _arrangedSubviews = [[NSMutableArray alloc] init];
      _axis = UILayoutConstraintAxisHorizontal;
      _distribution = UIStackViewDistributionFill;
      _alignment = UIStackViewAlignmentFill;
      _spacing = 0;
    }
  return self;
}
- (id)initWithArrangedSubviews:(NSArray *)views
{
  NSEnumerator *enumerator;
  UIView *view;

  self = [self initWithFrame:CGRectZero];
  if (self != nil)
    {
      enumerator = [views objectEnumerator];
      while ((view = [enumerator nextObject]) != nil)
        [self addArrangedSubview:view];
    }
  return self;
}
- (void)dealloc
{
  [_arrangedSubviews release];
  [super dealloc];
}
- (NSArray *)arrangedSubviews { return _arrangedSubviews; }
- (void)addArrangedSubview:(UIView *)view
{
  if (view == nil || [_arrangedSubviews containsObject:view])
    return;
  [_arrangedSubviews addObject:view];
  if ([view superview] != self)
    [self addSubview:view];
  [self setNeedsLayout];
}
- (void)insertArrangedSubview:(UIView *)view atIndex:(NSUInteger)stackIndex
{
  if (view == nil)
    return;
  [_arrangedSubviews removeObjectIdenticalTo:view];
  if (stackIndex > [_arrangedSubviews count])
    stackIndex = [_arrangedSubviews count];
  [_arrangedSubviews insertObject:view atIndex:stackIndex];
  if ([view superview] != self)
    [self addSubview:view];
  [self setNeedsLayout];
}
- (void)removeArrangedSubview:(UIView *)view
{
  [_arrangedSubviews removeObjectIdenticalTo:view];
  [self setNeedsLayout];
}
- (UILayoutConstraintAxis)axis { return _axis; }
- (void)setAxis:(UILayoutConstraintAxis)axis { _axis = axis; [self setNeedsLayout]; }
- (UIStackViewDistribution)distribution { return _distribution; }
- (void)setDistribution:(UIStackViewDistribution)distribution { _distribution = distribution; [self setNeedsLayout]; }
- (UIStackViewAlignment)alignment { return _alignment; }
- (void)setAlignment:(UIStackViewAlignment)alignment { _alignment = alignment; [self setNeedsLayout]; }
- (CGFloat)spacing { return _spacing; }
- (void)setSpacing:(CGFloat)spacing { _spacing = spacing; [self setNeedsLayout]; }
- (NSArray *)_visibleArrangedSubviews
{
  NSMutableArray *views = [NSMutableArray array];
  NSEnumerator *enumerator = [_arrangedSubviews objectEnumerator];
  UIView *view;

  while ((view = [enumerator nextObject]) != nil)
    if ([view isHidden] == NO)
      [views addObject:view];

  return views;
}
- (CGFloat)_totalNaturalLengthForViews:(NSArray *)views
{
  NSEnumerator *enumerator = [views objectEnumerator];
  UIView *view;
  CGFloat total = 0;

  while ((view = [enumerator nextObject]) != nil)
    total += (_axis == UILayoutConstraintAxisHorizontal) ? NSWidth([view frame]) : NSHeight([view frame]);

  return total;
}
- (void)layoutSubviews
{
  NSArray *views = [self _visibleArrangedSubviews];
  NSUInteger count = [views count];
  CGRect bounds = [self bounds];
  CGFloat availableLength;
  CGFloat crossLength;
  CGFloat naturalTotal;
  CGFloat gap;
  CGFloat position;
  NSUInteger index;

  if (count == 0)
    return;

  availableLength = (_axis == UILayoutConstraintAxisHorizontal) ? NSWidth(bounds) : NSHeight(bounds);
  crossLength = (_axis == UILayoutConstraintAxisHorizontal) ? NSHeight(bounds) : NSWidth(bounds);
  naturalTotal = [self _totalNaturalLengthForViews:views];
  gap = _spacing;

  if (_distribution == UIStackViewDistributionEqualSpacing && count > 1)
    gap = MAX(_spacing, (availableLength - naturalTotal) / (CGFloat)(count - 1));

  position = 0;
  for (index = 0; index < count; index++)
    {
      UIView *view = [views objectAtIndex:index];
      CGRect frame = [view frame];
      CGFloat length;
      CGFloat breadth;
      CGFloat crossOrigin = 0;

      if (_distribution == UIStackViewDistributionFillEqually)
        length = (availableLength - (gap * (count - 1))) / (CGFloat)count;
      else if (_distribution == UIStackViewDistributionFill && index == count - 1)
        length = MAX(0, availableLength - position);
      else
        length = (_axis == UILayoutConstraintAxisHorizontal) ? NSWidth(frame) : NSHeight(frame);

      breadth = (_axis == UILayoutConstraintAxisHorizontal) ? NSHeight(frame) : NSWidth(frame);
      if (_alignment == UIStackViewAlignmentFill)
        breadth = crossLength;
      else if (_alignment == UIStackViewAlignmentCenter)
        crossOrigin = (crossLength - breadth) / 2.0;
      else if (_alignment == UIStackViewAlignmentTrailing || _alignment == UIStackViewAlignmentBottom)
        crossOrigin = crossLength - breadth;

      if (_axis == UILayoutConstraintAxisHorizontal)
        frame = NSMakeRect(position, crossOrigin, length, breadth);
      else
        frame = NSMakeRect(crossOrigin, position, breadth, length);

      [view setFrame:frame];
      position += length + gap;
    }
}
@end
