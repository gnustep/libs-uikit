#ifndef GNUSTEP_UIKIT_UITABLEVIEW_H
#define GNUSTEP_UIKIT_UITABLEVIEW_H

#import <UIKit/UIScrollView.h>
#import <UIKit/UITableViewCell.h>

@protocol UITableViewDataSource
- (NSInteger)tableView:(id)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(id)tableView cellForRowAtIndexPath:(id)indexPath;
@end

@protocol UITableViewDelegate
- (void)tableView:(id)tableView didSelectRowAtIndexPath:(id)indexPath;
@end

@interface UITableView : UIScrollView
{
  id _dataSource;
  id _delegate;
  NSMutableArray *_visibleCells;
  NSMutableDictionary *_reusableCells;
  CGFloat _rowHeight;
  NSIndexPath *_selectedIndexPath;
}
- (id)dataSource;
- (void)setDataSource:(id)dataSource;
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (CGFloat)rowHeight;
- (void)setRowHeight:(CGFloat)rowHeight;
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)reloadData;
- (NSIndexPath *)indexPathForSelectedRow;
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(int)scrollPosition;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
@end

#endif
