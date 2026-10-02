#ifndef GNUSTEP_UIKIT_UITABBAR_H
#define GNUSTEP_UIKIT_UITABBAR_H
#import <UIKit/UIView.h>
#import <UIKit/UITabBarItem.h>
@class UITabBar;
@protocol UITabBarDelegate <NSObject>
@optional
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;
@end
@interface UITabBar : UIView { NSArray *_items; UITabBarItem *_selectedItem; id<UITabBarDelegate> _delegate; }
@property(nonatomic, copy) NSArray *items;
@property(nonatomic, retain) UITabBarItem *selectedItem;
@property(nonatomic, assign) id<UITabBarDelegate> delegate;
@end
#endif
