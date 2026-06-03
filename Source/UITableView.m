#import <UIKit/NSIndexPath+UIKit.h>
#import <UIKit/UITableView.h>

@implementation UITableView
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _visibleCells = [[NSMutableArray alloc] init];
      _rowHeight = 44.0;
    }
  return self;
}
- (void)dealloc
{
  [_visibleCells release];
  [super dealloc];
}
- (id)dataSource { return _dataSource; }
- (void)setDataSource:(id)dataSource { _dataSource = dataSource; }
- (CGFloat)rowHeight { return _rowHeight; }
- (void)setRowHeight:(CGFloat)rowHeight { _rowHeight = rowHeight; }
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier { return nil; }
- (void)reloadData
{
  NSInteger row;
  NSInteger rows = 0;
  NSArray *oldCells = [[_visibleCells copy] autorelease];
  NSEnumerator *enumerator = [oldCells objectEnumerator];
  UIView *cell;

  while ((cell = [enumerator nextObject]) != nil)
    [cell removeFromSuperview];
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
        }
    }
}
@end
