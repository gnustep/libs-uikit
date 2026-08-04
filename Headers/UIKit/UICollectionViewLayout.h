#ifndef GNUSTEP_UIKIT_UICOLLECTIONVIEWLAYOUT_H
#define GNUSTEP_UIKIT_UICOLLECTIONVIEWLAYOUT_H

#import <UIKit/UIKitTypes.h>

@class UICollectionView;

@interface UICollectionViewLayoutAttributes : NSObject
{
  NSIndexPath *_indexPath;
  CGRect _frame;
}
+ (id)layoutAttributesForCellWithIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPath;
- (void)setIndexPath:(NSIndexPath *)indexPath;
- (CGRect)frame;
- (void)setFrame:(CGRect)frame;
@end

@interface UICollectionViewLayout : NSObject
{
  UICollectionView *_collectionView;
}
- (UICollectionView *)collectionView;
- (void)setCollectionView:(UICollectionView *)collectionView;
- (void)prepareLayout;
- (CGSize)collectionViewContentSize;
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateLayout;
@end

#endif
