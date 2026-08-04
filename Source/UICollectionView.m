#import "UIKitPrivate.h"
#import <UIKit/NSIndexPath+UIKit.h>
#import <UIKit/UICollectionView.h>

@implementation UICollectionView
- (id)initWithFrame:(CGRect)frame
{
  UICollectionViewFlowLayout *layout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
  return [self initWithFrame:frame collectionViewLayout:layout];
}
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _visibleCells = [[NSMutableArray alloc] init];
      _reusableCells = [[NSMutableDictionary alloc] init];
      _registeredCellClasses = [[NSMutableDictionary alloc] init];
      [self setCollectionViewLayout:layout];
    }
  return self;
}
- (void)dealloc
{
  [_selectedIndexPath release];
  [_registeredCellClasses release];
  [_reusableCells release];
  [_visibleCells release];
  [_collectionViewLayout release];
  [super dealloc];
}
- (id)dataSource { return _dataSource; }
- (void)setDataSource:(id)dataSource { _dataSource = dataSource; }
- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }
- (UICollectionViewLayout *)collectionViewLayout { return _collectionViewLayout; }
- (void)setCollectionViewLayout:(UICollectionViewLayout *)layout
{
  if (_collectionViewLayout == layout)
    return;

  [_collectionViewLayout setCollectionView:nil];
  ASSIGN(_collectionViewLayout, layout);
  [_collectionViewLayout setCollectionView:self];
  [self reloadData];
}
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
  if (cellClass == Nil || identifier == nil)
    return;
  [_registeredCellClasses setObject:cellClass forKey:identifier];
}
- (UICollectionViewCell *)_newRegisteredCellWithReuseIdentifier:(NSString *)identifier
{
  Class cellClass = [_registeredCellClasses objectForKey:identifier];
  UICollectionViewCell *cell;

  if (cellClass == Nil)
    cellClass = [UICollectionViewCell class];

  if ([cellClass instancesRespondToSelector:@selector(initWithFrame:reuseIdentifier:)])
    cell = [[cellClass alloc] initWithFrame:NSMakeRect(0, 0, 50, 50) reuseIdentifier:identifier];
  else
    cell = [[cellClass alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];

  return [cell autorelease];
}
- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
  NSMutableArray *cells;
  UICollectionViewCell *cell;

  if (identifier == nil)
    return nil;

  cells = [_reusableCells objectForKey:identifier];
  cell = [cells lastObject];
  if (cell != nil)
    {
      [[cell retain] autorelease];
      [cells removeLastObject];
      [cell prepareForReuse];
      return cell;
    }

  return [self _newRegisteredCellWithReuseIdentifier:identifier];
}
- (void)_enqueueReusableCell:(UICollectionViewCell *)cell
{
  NSString *identifier = [cell reuseIdentifier];
  NSMutableArray *cells;

  if (identifier == nil)
    return;

  cells = [_reusableCells objectForKey:identifier];
  if (cells == nil)
    {
      cells = [NSMutableArray array];
      [_reusableCells setObject:cells forKey:identifier];
    }
  [cells addObject:cell];
}
- (void)reloadData
{
  NSArray *oldCells = [[_visibleCells copy] autorelease];
  NSEnumerator *enumerator = [oldCells objectEnumerator];
  UICollectionViewCell *cell;
  NSArray *attributes;
  UICollectionViewLayoutAttributes *layoutAttributes;

  while ((cell = [enumerator nextObject]) != nil)
    {
      [self _enqueueReusableCell:cell];
      [cell removeFromSuperview];
    }
  [_visibleCells removeAllObjects];

  if (_collectionViewLayout == nil || _dataSource == nil)
    return;

  [_collectionViewLayout prepareLayout];
  [self setContentSize:[_collectionViewLayout collectionViewContentSize]];

  attributes = [_collectionViewLayout layoutAttributesForElementsInRect:NSMakeRect(0, 0, [self contentSize].width, [self contentSize].height)];
  enumerator = [attributes objectEnumerator];
  while ((layoutAttributes = [enumerator nextObject]) != nil)
    {
      NSIndexPath *indexPath = [layoutAttributes indexPath];
      UICollectionViewCell *newCell = [_dataSource collectionView:self cellForItemAtIndexPath:indexPath];
      if (newCell != nil)
        {
          [newCell setFrame:[layoutAttributes frame]];
          [newCell setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin)];
          [self addSubview:newCell];
          [_visibleCells addObject:newCell];
          if (_selectedIndexPath != nil && [_selectedIndexPath isEqual:indexPath])
            [newCell setSelected:YES];
        }
    }
}
- (NSIndexPath *)indexPathForCell:(UICollectionViewCell *)cell
{
  NSUInteger index = [_visibleCells indexOfObjectIdenticalTo:cell];
  if (index == NSNotFound)
    return nil;
  return [NSIndexPath indexPathForItem:index inSection:0];
}
- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger item = [indexPath item];
  if (item < 0 || item >= [_visibleCells count])
    return nil;
  return [_visibleCells objectAtIndex:item];
}
- (NSArray *)visibleCells { return _visibleCells; }
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(int)scrollPosition
{
  UICollectionViewCell *oldCell;
  UICollectionViewCell *newCell;

  if (indexPath == nil)
    return;

  oldCell = [self cellForItemAtIndexPath:_selectedIndexPath];
  [oldCell setSelected:NO];
  ASSIGN(_selectedIndexPath, indexPath);
  newCell = [self cellForItemAtIndexPath:indexPath];
  [newCell setSelected:YES];

  if ([_delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)])
    [_delegate collectionView:self didSelectItemAtIndexPath:indexPath];
}
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
  UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
  if (_selectedIndexPath != nil && [_selectedIndexPath isEqual:indexPath])
    DESTROY(_selectedIndexPath);
  [cell setSelected:NO];
}
- (void)mouseDown:(NSEvent *)event
{
  NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
  NSEnumerator *enumerator = [_visibleCells objectEnumerator];
  UICollectionViewCell *cell;

  while ((cell = [enumerator nextObject]) != nil)
    {
      if (NSPointInRect(point, [cell frame]))
        {
          [self selectItemAtIndexPath:[self indexPathForCell:cell] animated:NO scrollPosition:0];
          return;
        }
    }

  [super mouseDown:event];
}
@end
