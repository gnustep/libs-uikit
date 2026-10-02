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
  [_arrangementConstraints release];
  [_arrangedSubviews release];
  [super dealloc];
}
- (NSArray *)arrangedSubviews { return [[_arrangedSubviews copy] autorelease]; }
- (void)willRemoveSubview:(UIView *)view
{
  [self removeArrangedSubview:view]; [super willRemoveSubview:view];
}
- (void)setTranslatesAutoresizingMaskIntoConstraints:(BOOL)value
{
  [super setTranslatesAutoresizingMaskIntoConstraints:value]; [self setNeedsUpdateConstraints];
}
- (void)addArrangedSubview:(UIView *)view
{
  if (view == nil || [_arrangedSubviews containsObject:view])
    return;
  [_arrangedSubviews addObject:view];
  if ([view superview] != self)
    [self addSubview:view];
  [self setNeedsUpdateConstraints]; [self setNeedsLayout];
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
  [self setNeedsUpdateConstraints]; [self setNeedsLayout];
}
- (void)removeArrangedSubview:(UIView *)view
{
  [_arrangedSubviews removeObjectIdenticalTo:view];
  [self setNeedsUpdateConstraints]; [self setNeedsLayout];
}
- (UILayoutConstraintAxis)axis { return _axis; }
- (void)setAxis:(UILayoutConstraintAxis)axis { _axis = axis; [self setNeedsUpdateConstraints]; [self setNeedsLayout]; }
- (UIStackViewDistribution)distribution { return _distribution; }
- (void)setDistribution:(UIStackViewDistribution)distribution { _distribution = distribution; [self setNeedsUpdateConstraints]; [self setNeedsLayout]; }
- (UIStackViewAlignment)alignment { return _alignment; }
- (void)setAlignment:(UIStackViewAlignment)alignment { _alignment = alignment; [self setNeedsUpdateConstraints]; [self setNeedsLayout]; }
- (CGFloat)spacing { return _spacing; }
- (void)setSpacing:(CGFloat)spacing { _spacing = spacing; [self setNeedsUpdateConstraints]; [self setNeedsLayout]; }
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
- (void)updateConstraints
{
  [super updateConstraints];
  [NSLayoutConstraint deactivateConstraints:_arrangementConstraints];
  DESTROY(_arrangementConstraints);
  if (self.translatesAutoresizingMaskIntoConstraints || (_distribution != UIStackViewDistributionFill && _distribution != UIStackViewDistributionFillEqually)) return;
  NSMutableArray *constraints = [NSMutableArray array];
  NSArray *views = [self _visibleArrangedSubviews];
  BOOL vertical = _axis == UILayoutConstraintAxisVertical;
  NSLayoutAttribute start = vertical ? NSLayoutAttributeTop : NSLayoutAttributeLeading;
  NSLayoutAttribute end = vertical ? NSLayoutAttributeBottom : NSLayoutAttributeTrailing;
  NSLayoutAttribute crossStart = vertical ? NSLayoutAttributeLeading : NSLayoutAttributeTop;
  NSLayoutAttribute crossEnd = vertical ? NSLayoutAttributeTrailing : NSLayoutAttributeBottom;
  NSLayoutAttribute crossCenter = vertical ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY;
  UIView *previous = nil;
  for (UIView *view in views) {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:start relatedBy:NSLayoutRelationEqual
      toItem:previous ?: self attribute:previous ? end : start multiplier:1 constant:previous ? _spacing : 0]];
    NSLayoutAttribute alignment = _alignment == UIStackViewAlignmentCenter ? crossCenter :
      _alignment == UIStackViewAlignmentTrailing ? crossEnd : crossStart;
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:alignment relatedBy:NSLayoutRelationEqual
      toItem:self attribute:alignment multiplier:1 constant:0]];
    if (_alignment == UIStackViewAlignmentFill)
      [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:crossEnd relatedBy:NSLayoutRelationEqual
        toItem:self attribute:crossEnd multiplier:1 constant:0]];
    else {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:crossStart relatedBy:NSLayoutRelationGreaterThanOrEqual
        toItem:self attribute:crossStart multiplier:1 constant:0]];
      [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:crossEnd relatedBy:NSLayoutRelationLessThanOrEqual
        toItem:self attribute:crossEnd multiplier:1 constant:0]];
    }
    if (previous && _distribution == UIStackViewDistributionFillEqually)
      [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:vertical ? NSLayoutAttributeHeight : NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:previous attribute:vertical ? NSLayoutAttributeHeight : NSLayoutAttributeWidth multiplier:1 constant:0]];
    previous = view;
  }
  if (previous) [constraints addObject:[NSLayoutConstraint constraintWithItem:previous attribute:end relatedBy:NSLayoutRelationEqual
    toItem:self attribute:end multiplier:1 constant:0]];
  _arrangementConstraints = [constraints copy];
  [NSLayoutConstraint activateConstraints:_arrangementConstraints];
}
- (CGSize)intrinsicContentSize
{
  if (self.translatesAutoresizingMaskIntoConstraints) return [super intrinsicContentSize];
  CGFloat length = 0, breadth = 0, longest = 0;
  NSArray *views = [self _visibleArrangedSubviews];
  for (UIView *view in views) {
    CGSize size = view.intrinsicContentSize;
    for (NSLayoutConstraint *constraint in view.constraints)
      if (constraint.firstItem == view && !constraint.secondItem && constraint.relation == NSLayoutRelationEqual) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) size.height = constraint.constant;
        if (constraint.firstAttribute == NSLayoutAttributeWidth) size.width = constraint.constant;
      }
    CGFloat naturalLength = MAX(0, _axis == UILayoutConstraintAxisVertical ? size.height : size.width);
    length += naturalLength; longest = MAX(longest, naturalLength);
    breadth = MAX(breadth, _axis == UILayoutConstraintAxisVertical ? size.width : size.height);
  }
  if (_distribution == UIStackViewDistributionFillEqually) length = longest * views.count;
  if (views.count > 1) length += _spacing * (views.count-1);
  return _axis == UILayoutConstraintAxisVertical ? CGSizeMake(breadth,length) : CGSizeMake(length,breadth);
}
- (void)layoutSubviews
{
  if (_arrangementConstraints) return;
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
