#import <UIKit/NSIndexPath+UIKit.h>
#import <UIKit/UITableView.h>

@implementation UITableView
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _visibleCells = [[NSMutableArray alloc] init];
      _reusableCells = [[NSMutableDictionary alloc] init];
      _rowHeight = 44.0;
    }
  return self;
}
- (void)dealloc
{
  [_selectedIndexPath release];
  [_reusableCells release];
  [_visibleCells release];
  [super dealloc];
}
- (id)dataSource { return _dataSource; }
- (void)setDataSource:(id)dataSource { _dataSource = dataSource; }
- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }
- (CGFloat)rowHeight { return _rowHeight; }
- (void)setRowHeight:(CGFloat)rowHeight { _rowHeight = rowHeight; }
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
  NSMutableArray *cells;
  UITableViewCell *cell;

  if (identifier == nil)
    return nil;

  cells = [_reusableCells objectForKey:identifier];
  cell = [cells lastObject];
  if (cell != nil)
    {
      [[cell retain] autorelease];
      [cells removeLastObject];
      [cell prepareForReuse];
    }
  return cell;
}
- (void)_enqueueReusableCell:(UITableViewCell *)cell
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
  NSInteger row;
  NSInteger rows = 0;
  NSArray *oldCells = [[_visibleCells copy] autorelease];
  NSEnumerator *enumerator = [oldCells objectEnumerator];
  UIView *cell;

  while ((cell = [enumerator nextObject]) != nil)
    {
      if ([cell isKindOfClass:[UITableViewCell class]])
        [self _enqueueReusableCell:(UITableViewCell *)cell];
      [cell removeFromSuperview];
    }
  [_visibleCells removeAllObjects];

  if ([_dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
    rows = [_dataSource tableView:self numberOfRowsInSection:0];

  [self setContentSize:NSMakeSize(NSWidth([self bounds]), rows * _rowHeight)];
  for (row = 0; row < rows; row++)
    {
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
      UITableViewCell *newCell = [_dataSource tableView:self cellForRowAtIndexPath:indexPath];
      if (newCell != nil)
        {
          [newCell setFrame:NSMakeRect(0, row * _rowHeight, NSWidth([self bounds]), _rowHeight)];
          [newCell setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
          [self addSubview:newCell];
          [_visibleCells addObject:newCell];
          if (_selectedIndexPath != nil && [_selectedIndexPath row] == row)
            [newCell setSelected:YES animated:NO];
        }
    }
}
- (NSIndexPath *)indexPathForSelectedRow { return _selectedIndexPath; }
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger row = [indexPath row];
  if (row < 0 || row >= [_visibleCells count])
    return nil;
  return [_visibleCells objectAtIndex:row];
}
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(int)scrollPosition
{
  UITableViewCell *oldCell;
  UITableViewCell *newCell;

  if (indexPath == nil)
    return;

  oldCell = [self cellForRowAtIndexPath:_selectedIndexPath];
  [oldCell setSelected:NO animated:animated];
  ASSIGN(_selectedIndexPath, indexPath);
  newCell = [self cellForRowAtIndexPath:indexPath];
  [newCell setSelected:YES animated:animated];

  if ([_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
    [_delegate tableView:self didSelectRowAtIndexPath:indexPath];
}
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
  UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
  if (_selectedIndexPath != nil && [_selectedIndexPath row] == [indexPath row])
    DESTROY(_selectedIndexPath);
  [cell setSelected:NO animated:animated];
}
- (void)mouseDown:(NSEvent *)event
{
  NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
  NSInteger row = (NSInteger)(point.y / _rowHeight);
  if (row >= 0 && row < [_visibleCells count])
    [self selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:0];
  else
    [super mouseDown:event];
}
@end
