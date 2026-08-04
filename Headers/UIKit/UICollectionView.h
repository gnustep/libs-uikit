#ifndef GNUSTEP_UIKIT_UICOLLECTIONVIEW_H
#define GNUSTEP_UIKIT_UICOLLECTIONVIEW_H

#import <UIKit/UIScrollView.h>
#import <UIKit/UICollectionViewCell.h>
#import <UIKit/UICollectionViewLayout.h>
#import <UIKit/UICollectionViewFlowLayout.h>

@protocol UICollectionViewDataSource
- (NSInteger)collectionView:(id)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)collectionView:(id)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol UICollectionViewDelegate
- (void)collectionView:(id)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
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
- (void)reloadData;
- (NSIndexPath *)indexPathForCell:(UICollectionViewCell *)cell;
- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)visibleCells;
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(int)scrollPosition;
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
@end

#endif
