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
      _cellsByIndexPath = [[NSMutableDictionary alloc] init];
      _visibleCells = [[NSMutableArray alloc] init];
      _reusableCells = [[NSMutableDictionary alloc] init];
      _registeredCellClasses = [[NSMutableDictionary alloc] init];
      [self setCollectionViewLayout:layout];
    }
  return self;
}
- (void)dealloc
{
  [_collectionViewLayout setCollectionView:nil];
  [_cellsByIndexPath release];
  [_selectedIndexPath release];
  [_registeredCellClasses release];
  [_reusableCells release];
  [_visibleCells release];
  [_collectionViewLayout release];
  [super dealloc];
}
- (id)dataSource { return _dataSource; }
- (void)setDataSource:(id)dataSource { _dataSource = dataSource; _dataDirty = YES; [self setNeedsLayout]; }
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
    [NSException raise:NSInternalInconsistencyException format:@"Register cell identifier %@ before dequeuing", identifier];
  cell = [[cellClass alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
  [cell _setReuseIdentifier:identifier];

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
- (NSInteger)numberOfSections
{
  return !_dataSource ? 0 : ([_dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)] ? [_dataSource numberOfSectionsInCollectionView:self] : 1);
}
- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
  return section >= 0 && section < [self numberOfSections] ? MAX(0, [_dataSource collectionView:self numberOfItemsInSection:section]) : 0;
}
- (BOOL)_validIndexPath:(NSIndexPath *)path
{
  return path && [path length] == 2 && [path section] >= 0 && [path section] < [self numberOfSections] && [path item] >= 0 && [path item] < [self numberOfItemsInSection:[path section]];
}
- (void)reloadData
{
  if (_reloading) return;
  _reloading = YES;
  @try {
    for (UICollectionViewCell *cell in [_cellsByIndexPath allValues]) { [self _enqueueReusableCell:cell]; [cell removeFromSuperview]; }
    [_cellsByIndexPath removeAllObjects]; [_visibleCells removeAllObjects];
    if (![self _validIndexPath:_selectedIndexPath]) DESTROY(_selectedIndexPath);
    _layoutSize = [self bounds].size;
    [_collectionViewLayout prepareLayout];
    [self setContentSize:_collectionViewLayout ? [_collectionViewLayout collectionViewContentSize] : CGSizeZero];
    [self setContentOffset:[self contentOffset]];
  } @finally { _reloading = NO; }
  [self _updateVisibleContent];
}
- (void)_updateVisibleContent
{
  if (_reloading || !_cellsByIndexPath) return;
  NSArray *attributes = [_collectionViewLayout layoutAttributesForElementsInRect:[self visibleContentRect]];
  NSMutableSet *wanted = [NSMutableSet set];
  for (UICollectionViewLayoutAttributes *attribute in attributes) [wanted addObject:[attribute indexPath]];
  for (NSIndexPath *path in [_cellsByIndexPath allKeys])
    if (![wanted containsObject:path]) {
      UICollectionViewCell *cell = [_cellsByIndexPath objectForKey:path];
      [self _enqueueReusableCell:cell]; [cell removeFromSuperview]; [_cellsByIndexPath removeObjectForKey:path];
    }
  [_visibleCells removeAllObjects];
  for (UICollectionViewLayoutAttributes *attribute in attributes) {
    NSIndexPath *path = [attribute indexPath];
    UICollectionViewCell *cell = [_cellsByIndexPath objectForKey:path];
    if (!cell) {
      cell = [_dataSource collectionView:self cellForItemAtIndexPath:path];
      if (!cell) [NSException raise:NSInternalInconsistencyException format:@"Data source returned nil cell"];
      [_cellsByIndexPath setObject:cell forKey:path]; [self addSubview:cell];
    }
    [cell setFrame:[attribute frame]]; [cell setSelected:[path isEqual:_selectedIndexPath]];
    [_visibleCells addObject:cell];
  }
}
- (void)layoutSubviews
{
  if (_dataDirty) { _dataDirty = NO; [self reloadData]; }
  if (_cellsByIndexPath && !NSEqualSizes(_layoutSize, [self bounds].size)) [self reloadData];
  [super layoutSubviews];
}
- (NSIndexPath *)indexPathForCell:(UICollectionViewCell *)cell
{
  for (NSIndexPath *path in _cellsByIndexPath) if ([_cellsByIndexPath objectForKey:path] == cell) return path;
  return nil;
}
- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)path { return path ? [_cellsByIndexPath objectForKey:path] : nil; }
- (NSArray *)visibleCells { return [[_visibleCells copy] autorelease]; }
- (NSArray *)indexPathsForSelectedItems { return _selectedIndexPath ? [NSArray arrayWithObject:_selectedIndexPath] : [NSArray array]; }
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(int)scrollPosition
{
  UICollectionViewCell *oldCell;
  UICollectionViewCell *newCell;

  if (indexPath && ![self _validIndexPath:indexPath]) [NSException raise:NSRangeException format:@"Invalid item"];

  oldCell = [self cellForItemAtIndexPath:_selectedIndexPath];
  [oldCell setSelected:NO];
  ASSIGN(_selectedIndexPath, indexPath);
  newCell = [self cellForItemAtIndexPath:indexPath];
  [newCell setSelected:YES];

  if (indexPath && scrollPosition) {
    CGRect frame = [[_collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath] frame];
    CGPoint offset = [self contentOffset]; CGSize viewport = [self visibleContentRect].size;
    if (scrollPosition & 1) offset.y = NSMinY(frame);
    if (scrollPosition & 2) offset.y = NSMidY(frame) - viewport.height / 2;
    if (scrollPosition & 4) offset.y = NSMaxY(frame) - viewport.height;
    if (scrollPosition & 8) offset.x = NSMinX(frame);
    if (scrollPosition & 16) offset.x = NSMidX(frame) - viewport.width / 2;
    if (scrollPosition & 32) offset.x = NSMaxX(frame) - viewport.width;
    [self setContentOffset:offset];
  }
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
  NSPoint point = [_documentView convertPoint:[event locationInWindow] fromView:nil];
  NSEnumerator *enumerator = [_visibleCells objectEnumerator];
  UICollectionViewCell *cell;

  while ((cell = [enumerator nextObject]) != nil)
    {
      if (NSPointInRect(point, [cell frame]))
        {
          NSIndexPath *path = [self indexPathForCell:cell];
          [self selectItemAtIndexPath:path animated:NO scrollPosition:0];
          if ([_delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)])
            [_delegate collectionView:self didSelectItemAtIndexPath:path];
          return;
        }
    }

  [super mouseDown:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { [self mouseDown:[event NSEvent]]; }
@end
