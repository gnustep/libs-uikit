#import "UIKitPrivate.h"
#import <UIKit/UIKit.h>
#include <math.h>

const CGFloat UITableViewAutomaticDimension = -1;

@implementation UITableView
@synthesize estimatedRowHeight = _estimatedRowHeight;
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style { return [self initWithFrame:frame]; }
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _rowRects = [NSMutableDictionary new]; _sectionViews = [NSMutableArray new]; _rowPaths = [NSMutableArray new]; _estimatedRowHeight = 44;
    _visibleCells = [[NSMutableArray alloc] init];
    _reusableCells = [[NSMutableDictionary alloc] init];
    _cellsByIndexPath = [[NSMutableDictionary alloc] init];
    _registeredCellClasses = [[NSMutableDictionary alloc] init]; _rowHeight = 44;
  }
  return self;
}
- (void)dealloc
{
  [_rowPaths release]; [_rowRects release]; [_sectionViews release]; [_backgroundView release]; [_refreshControl release];
  [_tableFooterView release];
  [_sectionRows release]; [_cellsByIndexPath release]; [_registeredCellClasses release];
  [_selectedIndexPath release]; [_reusableCells release]; [_visibleCells release]; [super dealloc];
}
- (id)dataSource { return _dataSource; }
- (void)setDataSource:(id)dataSource { _dataSource = dataSource; _dataDirty = YES; [self setNeedsLayout]; }
- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }
- (CGFloat)rowHeight { return _rowHeight; }
- (void)setRowHeight:(CGFloat)height
{
  if (!isfinite(height) || (height <= 0 && height != UITableViewAutomaticDimension)) [NSException raise:NSInvalidArgumentException format:@"Invalid rowHeight"];
  _rowHeight = height;
  if (_sectionRows && !_reloading) { _reloading = YES; @try { [self _rebuildGeometry]; } @finally { _reloading = NO; } }
  [self setNeedsLayout];
}
- (UIView *)backgroundView { return _backgroundView; }
- (void)setBackgroundView:(UIView *)view {
  if (view == _backgroundView) return;
  [_backgroundView removeFromSuperview]; ASSIGN(_backgroundView,view);
  if (view) [self insertSubview:view atIndex:0]; [self setNeedsLayout];
}
- (UIRefreshControl *)refreshControl { return _refreshControl; }
- (void)setRefreshControl:(UIRefreshControl *)control {
  if (control == _refreshControl) return;
  [_refreshControl removeFromSuperview]; ASSIGN(_refreshControl,control);
  if (control) [self addSubview:control]; [self setNeedsLayout];
}
- (void)_handleScrollWheel:(NSEvent *)event {
  if (!_refreshControl || _refreshControl.refreshing) return;
  if (self.contentOffset.y <= 0 && [event deltaY] > 0) {
    _pullDistance += [event deltaY];
    if (_pullDistance >= 12) { _pullDistance = 0; [_refreshControl beginRefreshing]; [_refreshControl sendActionsForControlEvents:UIControlEventValueChanged]; }
  } else _pullDistance = 0;
}
- (CGFloat)_appendSectionTitle:(NSString *)text atY:(CGFloat)y {
  if (!text.length) return y;
  UILabel *label = [[[UILabel alloc] init] autorelease];
  label.text = text; label.numberOfLines = 0; label.font = [UIFont systemFontOfSize:13]; label.textColor = [UIColor secondaryLabelColor];
  CGFloat height = [label sizeThatFits:CGSizeMake(MAX(1,self.bounds.size.width-24),1000000)].height;
  label.frame = CGRectMake(12,y+8,MAX(0,self.bounds.size.width-24),height);
  [_sectionViews addObject:label]; [self addSubview:label];
  return y+height+16;
}
- (void)_rebuildGeometry {
  if (!_rowRects) return;
  for (UIView *view in _sectionViews) [view removeFromSuperview]; [_sectionViews removeAllObjects];
  [_rowPaths removeAllObjects]; [_rowRects removeAllObjects]; _geometryWidth = self.bounds.size.width; CGFloat y = 0;
  for (NSInteger section = 0; section < self.numberOfSections; section++) {
    if ([_dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) y = [self _appendSectionTitle:[_dataSource tableView:self titleForHeaderInSection:section] atY:y];
    for (NSInteger row = 0; row < [self numberOfRowsInSection:section]; row++) {
      NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
      CGFloat height = _rowHeight;
      if (height == UITableViewAutomaticDimension) {
        UITableViewCell *cell = [_cellsByIndexPath objectForKey:path]; BOOL temporary = !cell;
        if (!cell) cell = [_dataSource tableView:self cellForRowAtIndexPath:path];
        height = cell ? [cell sizeThatFits:CGSizeMake(_geometryWidth,1000000)].height : MAX(44,_estimatedRowHeight);
        if (temporary && cell) [self _recycleCell:cell];
      }
      height = MAX(1,height);
      [_rowPaths addObject:path];
      [_rowRects setObject:[NSValue valueWithRect:CGRectMake(0,y,_geometryWidth,height)] forKey:path]; y += height;
    }
    if ([_dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) y = [self _appendSectionTitle:[_dataSource tableView:self titleForFooterInSection:section] atY:y];
  }
  _tableFooterView.frame = CGRectMake(0,y,_geometryWidth,_tableFooterView.frame.size.height);
  [self setContentSize:CGSizeMake(_geometryWidth,y+_tableFooterView.frame.size.height)];
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
  return [[_rowRects objectForKey:path] rectValue];
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
- (UIView *)tableFooterView { return _tableFooterView; }
- (void)setTableFooterView:(UIView *)view
{
  if (_tableFooterView == view) return;
  [_tableFooterView removeFromSuperview]; ASSIGN(_tableFooterView, view);
  if (view) [self addSubview:view];
  [self setRowHeight:_rowHeight]; [self setNeedsLayout];
}
- (void)deleteRowsAtIndexPaths:(NSArray *)paths withRowAnimation:(UITableViewRowAnimation)animation
{
  NSSet *unique = [NSSet setWithArray:paths];
  if (unique.count != paths.count) [NSException raise:NSInvalidArgumentException format:@"Duplicate deleted row"];
  for (NSIndexPath *path in paths)
    if (![self _validIndexPath:path]) [NSException raise:NSRangeException format:@"Invalid deleted row"];
  NSIndexPath *selection = [[_selectedIndexPath retain] autorelease];
  if ([unique containsObject:selection]) selection = nil;
  else if (selection) {
    NSInteger row = selection.row;
    for (NSIndexPath *path in paths) if (path.section == selection.section && path.row < selection.row) row--;
    selection = [NSIndexPath indexPathForRow:row inSection:selection.section];
  }
  ASSIGN(_selectedIndexPath, selection);
  [self reloadData];
}
- (void)scrollToRowAtIndexPath:(NSIndexPath *)path atScrollPosition:(UITableViewScrollPosition)position animated:(BOOL)animated
{
  if (![self _validIndexPath:path]) [NSException raise:NSRangeException format:@"Invalid row"];
  CGRect row = [self rectForRowAtIndexPath:path], visible = [self visibleContentRect];
  CGFloat y = row.origin.y;
  if (position == UITableViewScrollPositionMiddle) y -= (visible.size.height-row.size.height)/2;
  else if (position == UITableViewScrollPositionBottom) y -= visible.size.height-row.size.height;
  else if (position == UITableViewScrollPositionNone) {
    if (NSContainsRect(visible,row)) return;
    if (NSMaxY(row) > NSMaxY(visible)) y = NSMaxY(row)-visible.size.height;
  }
  [self setContentOffset:CGPointMake(self.contentOffset.x,y) animated:animated];
}
- (void)reloadData
{
  if (_reloading) return;
  _reloading = YES;
  @try {
    for (UITableViewCell *cell in [_cellsByIndexPath allValues]) [self _recycleCell:cell];
    [_cellsByIndexPath removeAllObjects]; [_visibleCells removeAllObjects];
    NSInteger sections = !_dataSource ? 0 : ([_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)] ? [_dataSource numberOfSectionsInTableView:self] : 1);
    NSMutableArray *counts = [NSMutableArray array];
    for (NSInteger section = 0; section < sections; section++) {
      NSInteger count = MAX(0, [_dataSource tableView:self numberOfRowsInSection:section]);
      [counts addObject:[NSNumber numberWithInteger:count]];
    }
    ASSIGN(_sectionRows, counts);
    if (![self _validIndexPath:_selectedIndexPath]) DESTROY(_selectedIndexPath);
    [self _rebuildGeometry];
    _dataDirty = NO;
    [self setContentOffset:[self contentOffset]];
  } @finally { _reloading = NO; }
  [self _updateVisibleContent];
}
- (void)_updateVisibleContent
{
  if (_reloading || !_cellsByIndexPath) return;
  CGRect visible = [self visibleContentRect];
  NSMutableArray *paths = [NSMutableArray array];
  NSUInteger low = 0, high = _rowPaths.count;
  while (low < high) {
    NSUInteger mid = low+(high-low)/2;
    if (NSMaxY([self rectForRowAtIndexPath:[_rowPaths objectAtIndex:mid]]) <= NSMinY(visible)) low = mid+1;
    else high = mid;
  }
  for (NSUInteger i = low; i < _rowPaths.count; i++) {
    NSIndexPath *path = [_rowPaths objectAtIndex:i]; CGRect rect = [self rectForRowAtIndexPath:path];
    if (NSMinY(rect) >= NSMaxY(visible)) break;
    if (NSIntersectsRect(visible,rect)) [paths addObject:path];
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
- (void)layoutSubviews
{
  [super layoutSubviews];
  if (_dataDirty) [self reloadData];
  if (_geometryWidth != self.bounds.size.width) {
    _reloading = YES; @try { [self _rebuildGeometry]; } @finally { _reloading = NO; }
  }
  _backgroundView.frame = self.visibleContentRect;
  _refreshControl.frame = CGRectMake(0,self.contentOffset.y,self.bounds.size.width,32);
  [self _updateVisibleContent];
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
