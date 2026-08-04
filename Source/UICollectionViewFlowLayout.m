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
  UICollectionView *collectionView = [self collectionView];
  NSInteger section = 0;
  NSInteger itemCount = 0;
  CGFloat x;
  CGFloat y;
  CGFloat lineExtent = 0;
  CGFloat maxX = 0;
  CGFloat maxY = 0;
  NSInteger item;

  [_layoutAttributes removeAllObjects];
  if (collectionView == nil || [collectionView dataSource] == nil)
    {
      _contentSize = CGSizeZero;
      return;
    }

  if ([[collectionView dataSource] respondsToSelector:@selector(collectionView:numberOfItemsInSection:)])
    itemCount = [[collectionView dataSource] collectionView:collectionView numberOfItemsInSection:section];

  x = _sectionInset.left;
  y = _sectionInset.top;
  lineExtent = (_scrollDirection == UICollectionViewScrollDirectionVertical) ? _itemSize.height : _itemSize.width;

  for (item = 0; item < itemCount; item++)
    {
      CGRect frame;
      NSIndexPath *indexPath;
      UICollectionViewLayoutAttributes *attributes;

      if (_scrollDirection == UICollectionViewScrollDirectionVertical)
        {
          if (x > _sectionInset.left && x + _itemSize.width + _sectionInset.right > NSWidth([collectionView bounds]))
            {
              x = _sectionInset.left;
              y += lineExtent + _minimumLineSpacing;
              lineExtent = _itemSize.height;
            }
        }
      else
        {
          if (y > _sectionInset.top && y + _itemSize.height + _sectionInset.bottom > NSHeight([collectionView bounds]))
            {
              y = _sectionInset.top;
              x += lineExtent + _minimumLineSpacing;
              lineExtent = _itemSize.width;
            }
        }

      frame = NSMakeRect(x, y, _itemSize.width, _itemSize.height);
      indexPath = [NSIndexPath indexPathForItem:item inSection:section];
      attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
      [attributes setFrame:frame];
      [_layoutAttributes addObject:attributes];

      maxX = MAX(maxX, NSMaxX(frame));
      maxY = MAX(maxY, NSMaxY(frame));

      if (_scrollDirection == UICollectionViewScrollDirectionVertical)
        x += _itemSize.width + _minimumInteritemSpacing;
      else
        y += _itemSize.height + _minimumInteritemSpacing;
    }

  _contentSize = NSMakeSize(maxX + _sectionInset.right, maxY + _sectionInset.bottom);
  _contentSize.width = MAX(_contentSize.width, NSWidth([collectionView bounds]));
  _contentSize.height = MAX(_contentSize.height, NSHeight([collectionView bounds]));
}
- (CGSize)collectionViewContentSize { return _contentSize; }
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
  NSMutableArray *matches = [NSMutableArray array];
  NSEnumerator *enumerator = [_layoutAttributes objectEnumerator];
  UICollectionViewLayoutAttributes *attributes;

  while ((attributes = [enumerator nextObject]) != nil)
    if (NSIntersectsRect([attributes frame], rect))
      [matches addObject:attributes];

  return matches;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSEnumerator *enumerator = [_layoutAttributes objectEnumerator];
  UICollectionViewLayoutAttributes *attributes;

  while ((attributes = [enumerator nextObject]) != nil)
    if ([[attributes indexPath] isEqual:indexPath])
      return attributes;

  return nil;
}
@end
