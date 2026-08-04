#import "UIKitPrivate.h"
#import <UIKit/UICollectionView.h>
#import <UIKit/UICollectionViewLayout.h>

@implementation UICollectionViewLayoutAttributes
+ (id)layoutAttributesForCellWithIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewLayoutAttributes *attributes = [[[self alloc] init] autorelease];
  [attributes setIndexPath:indexPath];
  return attributes;
}
- (void)dealloc
{
  [_indexPath release];
  [super dealloc];
}
- (NSIndexPath *)indexPath { return _indexPath; }
- (void)setIndexPath:(NSIndexPath *)indexPath { ASSIGN(_indexPath, indexPath); }
- (CGRect)frame { return _frame; }
- (void)setFrame:(CGRect)frame { _frame = frame; }
@end

@implementation UICollectionViewLayout
- (UICollectionView *)collectionView { return _collectionView; }
- (void)setCollectionView:(UICollectionView *)collectionView { _collectionView = collectionView; }
- (void)prepareLayout {}
- (CGSize)collectionViewContentSize { return CGSizeZero; }
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect { return [NSArray array]; }
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath { return nil; }
- (void)invalidateLayout
{
  [_collectionView reloadData];
}
@end
