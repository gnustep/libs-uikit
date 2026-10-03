#ifndef GNUSTEP_UIKIT_UICOLLECTIONVIEWLISTCELL_H
#define GNUSTEP_UIKIT_UICOLLECTIONVIEWLISTCELL_H
#import <UIKit/UICollectionViewCell.h>
#import <UIKit/UIListContentConfiguration.h>
@interface UICollectionViewListCell : UICollectionViewCell
{ id<UIContentConfiguration> _contentConfiguration; UIView *_configuredView; }
@property(nonatomic, copy) id<UIContentConfiguration> contentConfiguration;
- (UIListContentConfiguration *)defaultContentConfiguration;
@end
#endif
