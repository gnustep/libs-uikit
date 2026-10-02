#ifndef GNUSTEP_UIKIT_UICOLLECTIONVIEW_H
#define GNUSTEP_UIKIT_UICOLLECTIONVIEW_H

#import <UIKit/UIScrollView.h>
#import <UIKit/UICollectionViewCell.h>
#import <UIKit/UICollectionViewLayout.h>
#import <UIKit/UICollectionViewFlowLayout.h>

@class UICollectionView;

@protocol UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
@end

@protocol UICollectionViewDelegate
@optional
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface UICollectionView : UIScrollView
{
  id _dataSource;
  id _delegate;
  UICollectionViewLayout *_collectionViewLayout;
  NSMutableArray *_visibleCells;
  NSMutableDictionary *_reusableCells;
  NSMutableDictionary *_registeredCellClasses;
  NSIndexPath *_selectedIndexPath;
  NSMutableDictionary *_cellsByIndexPath;
  BOOL _reloading, _dataDirty;
  CGSize _layoutSize;
}
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout;
- (id)dataSource;
- (void)setDataSource:(id)dataSource;
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (UICollectionViewLayout *)collectionViewLayout;
- (void)setCollectionViewLayout:(UICollectionViewLayout *)layout;
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSArray *)indexPathsForSelectedItems;
- (void)reloadData;
- (NSIndexPath *)indexPathForCell:(UICollectionViewCell *)cell;
- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)visibleCells;
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(int)scrollPosition;
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
@end

#endif
