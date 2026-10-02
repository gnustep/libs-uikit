#ifndef GNUSTEP_UIKIT_UITABLEVIEW_H
#define GNUSTEP_UIKIT_UITABLEVIEW_H

#import <UIKit/UIScrollView.h>
#import <UIKit/UITableViewCell.h>

@class UITableView;

@protocol UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
@end

@protocol UITableViewDelegate
@optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface UITableView : UIScrollView
{
  id _dataSource;
  id _delegate;
  NSMutableArray *_visibleCells;
  NSMutableDictionary *_reusableCells;
  CGFloat _rowHeight;
  NSIndexPath *_selectedIndexPath;
  NSMutableDictionary *_cellsByIndexPath;
  NSMutableDictionary *_registeredCellClasses;
  NSArray *_sectionRows;
  BOOL _reloading;
  UIView *_tableFooterView;
}
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
- (id)dataSource;
- (void)setDataSource:(id)dataSource;
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (CGFloat)rowHeight;
- (void)setRowHeight:(CGFloat)rowHeight;
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSArray *)visibleCells;
- (NSArray *)indexPathsForVisibleRows;
- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell;
- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;
@property(nonatomic, retain) UIView *tableFooterView;
- (void)deleteRowsAtIndexPaths:(NSArray *)paths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)scrollToRowAtIndexPath:(NSIndexPath *)path atScrollPosition:(UITableViewScrollPosition)position animated:(BOOL)animated;
- (void)reloadData;
- (NSIndexPath *)indexPathForSelectedRow;
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(int)scrollPosition;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
@end

#endif
