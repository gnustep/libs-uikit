#import "UIKitPrivate.h"
#import <UIKit/UICollectionView.h>
#import <UIKit/UICollectionViewFlowLayout.h>
#import <UIKit/NSIndexPath+UIKit.h>

static UIEdgeInsets
UIKitEdgeInsetsZero(void)
{
  UIEdgeInsets insets;
  insets.top = 0;
  insets.left = 0;
  insets.bottom = 0;
  insets.right = 0;
  return insets;
}

@implementation UICollectionViewFlowLayout
- (id)init
{
  self = [super init];
  if (self != nil)
    {
      _itemSize = NSMakeSize(50, 50);
      _minimumLineSpacing = 10.0;
      _minimumInteritemSpacing = 10.0;
      _sectionInset = UIKitEdgeInsetsZero();
      _scrollDirection = UICollectionViewScrollDirectionVertical;
      _layoutAttributes = [[NSMutableArray alloc] init];
    }
  return self;
}
- (void)dealloc
{
  [_layoutAttributes release];
  [super dealloc];
}
- (CGSize)itemSize { return _itemSize; }
- (void)setItemSize:(CGSize)itemSize { _itemSize = itemSize; [self invalidateLayout]; }
- (CGFloat)minimumLineSpacing { return _minimumLineSpacing; }
- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing { _minimumLineSpacing = minimumLineSpacing; [self invalidateLayout]; }
- (CGFloat)minimumInteritemSpacing { return _minimumInteritemSpacing; }
- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing { _minimumInteritemSpacing = minimumInteritemSpacing; [self invalidateLayout]; }
- (UIEdgeInsets)sectionInset { return _sectionInset; }
- (void)setSectionInset:(UIEdgeInsets)sectionInset { _sectionInset = sectionInset; [self invalidateLayout]; }
- (UICollectionViewScrollDirection)scrollDirection { return _scrollDirection; }
- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection { _scrollDirection = scrollDirection; [self invalidateLayout]; }
- (void)prepareLayout
{
  UICollectionView *collection = [self collectionView];
  [_layoutAttributes removeAllObjects];
  BOOL vertical = _scrollDirection == UICollectionViewScrollDirectionVertical;
  CGFloat crossLimit = vertical ? [collection bounds].size.width : [collection bounds].size.height;
  CGFloat main = 0, maxCross = crossLimit;
  for (NSInteger section = 0; section < [collection numberOfSections]; section++) {
    CGFloat leading = vertical ? _sectionInset.left : _sectionInset.top;
    CGFloat trailing = vertical ? _sectionInset.right : _sectionInset.bottom;
    CGFloat itemCross = vertical ? _itemSize.width : _itemSize.height;
    CGFloat itemMain = vertical ? _itemSize.height : _itemSize.width;
    CGFloat cross = leading;
    main += vertical ? _sectionInset.top : _sectionInset.left;
    NSInteger count = [collection numberOfItemsInSection:section];
    for (NSInteger item = 0; item < count; item++) {
      if (item > 0 && cross > leading && cross + itemCross + trailing > crossLimit) {
        cross = leading; main += itemMain + _minimumLineSpacing;
      }
      NSIndexPath *path = [NSIndexPath indexPathForItem:item inSection:section];
      UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
      [attribute setFrame:vertical ? CGRectMake(cross, main, _itemSize.width, _itemSize.height) : CGRectMake(main, cross, _itemSize.width, _itemSize.height)];
      [_layoutAttributes addObject:attribute];
      maxCross = MAX(maxCross, cross + itemCross + trailing);
      cross += itemCross + _minimumInteritemSpacing;
    }
    if (count) main += itemMain;
    main += vertical ? _sectionInset.bottom : _sectionInset.right;
  }
  _contentSize = vertical ? CGSizeMake(maxCross, main) : CGSizeMake(main, maxCross);
}
- (CGSize)collectionViewContentSize { return _contentSize; }
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
  NSMutableArray *result = [NSMutableArray array];
  for (UICollectionViewLayoutAttributes *attribute in _layoutAttributes)
    if (NSIntersectsRect(rect, [attribute frame])) [result addObject:attribute];
  return result;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
  for (UICollectionViewLayoutAttributes *attribute in _layoutAttributes)
    if ([[attribute indexPath] isEqual:path]) return attribute;
  return nil;
}
@end
