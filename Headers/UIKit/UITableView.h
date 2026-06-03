#ifndef GNUSTEP_UIKIT_UITABLEVIEW_H
#define GNUSTEP_UIKIT_UITABLEVIEW_H

#import <UIKit/UIScrollView.h>
#import <UIKit/UITableViewCell.h>

@protocol UITableViewDataSource
- (NSInteger)tableView:(id)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(id)tableView cellForRowAtIndexPath:(id)indexPath;
@end

@interface UITableView : UIScrollView
{
  id _dataSource;
  NSMutableArray *_visibleCells;
  CGFloat _rowHeight;
}
- (id)dataSource;
- (void)setDataSource:(id)dataSource;
- (CGFloat)rowHeight;
- (void)setRowHeight:(CGFloat)rowHeight;
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)reloadData;
@end

#endif
