#ifndef GNUSTEP_UIKIT_UICOLLECTIONVIEWFLOWLAYOUT_H
#define GNUSTEP_UIKIT_UICOLLECTIONVIEWFLOWLAYOUT_H

#import <UIKit/UICollectionViewLayout.h>

@interface UICollectionViewFlowLayout : UICollectionViewLayout
{
  CGSize _itemSize;
  CGFloat _minimumLineSpacing;
  CGFloat _minimumInteritemSpacing;
  UIEdgeInsets _sectionInset;
  UICollectionViewScrollDirection _scrollDirection;
  NSMutableArray *_layoutAttributes;
  CGSize _contentSize;
}
- (CGSize)itemSize;
- (void)setItemSize:(CGSize)itemSize;
- (CGFloat)minimumLineSpacing;
- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing;
- (CGFloat)minimumInteritemSpacing;
- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing;
- (UIEdgeInsets)sectionInset;
- (void)setSectionInset:(UIEdgeInsets)sectionInset;
- (UICollectionViewScrollDirection)scrollDirection;
- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection;
@end

#endif
