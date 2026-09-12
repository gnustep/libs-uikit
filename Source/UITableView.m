#import <UIKit/UIKit.h>
#include <math.h>

@implementation UITableView
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style { return [self initWithFrame:frame]; }
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _visibleCells = [[NSMutableArray alloc] init];
    _reusableCells = [[NSMutableDictionary alloc] init];
    _cellsByIndexPath = [[NSMutableDictionary alloc] init];
    _registeredCellClasses = [[NSMutableDictionary alloc] init]; _rowHeight = 44;
  }
  return self;
}
- (void)dealloc
{
  [_sectionRows release]; [_cellsByIndexPath release]; [_registeredCellClasses release];
  [_selectedIndexPath release]; [_reusableCells release]; [_visibleCells release]; [super dealloc];
}
- (id)dataSource { return _dataSource; }
- (void)setDataSource:(id)dataSource { _dataSource = dataSource; }
- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }
- (CGFloat)rowHeight { return _rowHeight; }
- (void)setRowHeight:(CGFloat)height
{
  if (!isfinite(height) || height <= 0) [NSException raise:NSInvalidArgumentException format:@"rowHeight must be positive"];
  _rowHeight = height; [self reloadData];
}
- (NSInteger)numberOfSections { return [_sectionRows count]; }
- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
  return section >= 0 && section < [_sectionRows count] ? [[_sectionRows objectAtIndex:section] integerValue] : 0;
}
- (BOOL)_validIndexPath:(NSIndexPath *)path
{
  return path && [path length] == 2 && [path section] >= 0 && [path section] < [self numberOfSections] && [path row] >= 0 && [path row] < [self numberOfRowsInSection:[path section]];
}
- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)path
{
  if (![self _validIndexPath:path]) return CGRectZero;
  NSInteger row = [path row];
  for (NSInteger section = 0; section < [path section]; section++) row += [self numberOfRowsInSection:section];
  return CGRectMake(0, row * _rowHeight, [self bounds].size.width, _rowHeight);
}
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
  if (!identifier) [NSException raise:NSInvalidArgumentException format:@"Missing reuse identifier"];
  if (cellClass) [_registeredCellClasses setObject:cellClass forKey:identifier]; else [_registeredCellClasses removeObjectForKey:identifier];
  [_reusableCells removeObjectForKey:identifier];
}
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
  NSMutableArray *queue = [_reusableCells objectForKey:identifier];
  UITableViewCell *cell = [[[queue lastObject] retain] autorelease];
  if (cell) { [queue removeLastObject]; [cell prepareForReuse]; }
  else {
    Class cellClass = [_registeredCellClasses objectForKey:identifier];
    if (cellClass) cell = [[[cellClass alloc] initWithStyle:0 reuseIdentifier:identifier] autorelease];
  }
  return cell;
}
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)path
{
  UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:identifier];
  if (!cell) [NSException raise:NSInternalInconsistencyException format:@"Register cell identifier %@ before dequeuing", identifier];
  return cell;
}
- (void)_recycleCell:(UITableViewCell *)cell
{
  NSString *identifier = [cell reuseIdentifier];
  if (identifier) {
    NSMutableArray *queue = [_reusableCells objectForKey:identifier];
    if (!queue) { queue = [NSMutableArray array]; [_reusableCells setObject:queue forKey:identifier]; }
    [queue addObject:cell];
  }
  [cell removeFromSuperview];
}
- (void)reloadData
{
  if (_reloading) return;
  _reloading = YES;
  @try {
    for (UITableViewCell *cell in [_cellsByIndexPath allValues]) [self _recycleCell:cell];
    [_cellsByIndexPath removeAllObjects]; [_visibleCells removeAllObjects];
    NSInteger sections = !_dataSource ? 0 : ([_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)] ? [_dataSource numberOfSectionsInTableView:self] : 1);
    NSMutableArray *counts = [NSMutableArray array]; NSInteger total = 0;
    for (NSInteger section = 0; section < sections; section++) {
      NSInteger count = MAX(0, [_dataSource tableView:self numberOfRowsInSection:section]);
      [counts addObject:[NSNumber numberWithInteger:count]]; total += count;
    }
    ASSIGN(_sectionRows, counts);
    if (![self _validIndexPath:_selectedIndexPath]) DESTROY(_selectedIndexPath);
    [self setContentSize:CGSizeMake([self bounds].size.width, total * _rowHeight)];
    [self setContentOffset:[self contentOffset]];
  } @finally { _reloading = NO; }
  [self _updateVisibleContent];
}
- (void)_updateVisibleContent
{
  if (_reloading || !_cellsByIndexPath) return;
  CGRect visible = [self visibleContentRect];
  NSMutableArray *paths = [NSMutableArray array]; NSInteger base = 0;
  for (NSInteger section = 0; section < [self numberOfSections]; section++) {
    NSInteger count = [self numberOfRowsInSection:section];
    NSInteger first = MAX(0, (NSInteger)floor(NSMinY(visible) / _rowHeight) - base);
    NSInteger last = MIN(count, (NSInteger)ceil(NSMaxY(visible) / _rowHeight) - base);
    for (NSInteger row = first; row < last; row++) [paths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    base += count;
  }
  NSSet *wanted = [NSSet setWithArray:paths];
  for (NSIndexPath *path in [_cellsByIndexPath allKeys])
    if (![wanted containsObject:path]) { [self _recycleCell:[_cellsByIndexPath objectForKey:path]]; [_cellsByIndexPath removeObjectForKey:path]; }
  [_visibleCells removeAllObjects];
  for (NSIndexPath *path in paths) {
    UITableViewCell *cell = [_cellsByIndexPath objectForKey:path];
    if (!cell) {
      cell = [_dataSource tableView:self cellForRowAtIndexPath:path];
      if (!cell) [NSException raise:NSInternalInconsistencyException format:@"Data source returned nil cell"];
      [_cellsByIndexPath setObject:cell forKey:path]; [self addSubview:cell];
    }
    [cell setFrame:[self rectForRowAtIndexPath:path]];
    [cell setSelected:[path isEqual:_selectedIndexPath] animated:NO];
    [_visibleCells addObject:cell];
  }
}
- (NSArray *)visibleCells { return [[_visibleCells copy] autorelease]; }
- (NSArray *)indexPathsForVisibleRows { return [[_cellsByIndexPath allKeys] sortedArrayUsingSelector:@selector(compare:)]; }
- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell
{
  for (NSIndexPath *path in _cellsByIndexPath) if ([_cellsByIndexPath objectForKey:path] == cell) return path;
  return nil;
}
- (NSIndexPath *)indexPathForSelectedRow { return _selectedIndexPath; }
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)path { return path ? [_cellsByIndexPath objectForKey:path] : nil; }
- (void)selectRowAtIndexPath:(NSIndexPath *)path animated:(BOOL)animated scrollPosition:(int)position
{
  if (path && ![self _validIndexPath:path]) [NSException raise:NSRangeException format:@"Invalid row"];
  [[self cellForRowAtIndexPath:_selectedIndexPath] setSelected:NO animated:animated];
  ASSIGN(_selectedIndexPath, path);
  if (path && position) {
    CGRect row = [self rectForRowAtIndexPath:path]; CGFloat y = row.origin.y;
    if (position == 2) y -= ([self visibleContentRect].size.height - row.size.height) / 2;
    if (position == 3) y -= [self visibleContentRect].size.height - row.size.height;
    [self setContentOffset:CGPointMake(0, y)];
  }
  [[self cellForRowAtIndexPath:path] setSelected:YES animated:animated];
}
- (void)deselectRowAtIndexPath:(NSIndexPath *)path animated:(BOOL)animated
{
  [[self cellForRowAtIndexPath:path] setSelected:NO animated:animated];
  if ([path isEqual:_selectedIndexPath]) DESTROY(_selectedIndexPath);
}
- (void)mouseDown:(NSEvent *)event
{
  CGPoint point = [_documentView convertPoint:[event locationInWindow] fromView:nil];
  for (NSIndexPath *path in [self indexPathsForVisibleRows])
    if (NSPointInRect(point, [self rectForRowAtIndexPath:path])) {
      [self selectRowAtIndexPath:path animated:NO scrollPosition:0];
      if ([_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) [_delegate tableView:self didSelectRowAtIndexPath:path];
      return;
    }
  [super mouseDown:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { [self mouseDown:[event NSEvent]]; }
@end
