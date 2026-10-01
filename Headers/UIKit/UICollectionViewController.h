#ifndef GNUSTEP_UIKIT_UICOLLECTIONVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UICOLLECTIONVIEWCONTROLLER_H
#import <UIKit/UIViewController.h>
#import <UIKit/UICollectionView.h>
@interface UICollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
  UICollectionViewLayout *_initialCollectionViewLayout;
  BOOL _clearsSelectionOnViewWillAppear;
}
- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout;
@property(nonatomic, retain) UICollectionView *collectionView;
@property(nonatomic, readonly) UICollectionViewLayout *collectionViewLayout;
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;
@end
#endif
