#ifndef GNUSTEP_UIKIT_UITABBARITEM_H
#define GNUSTEP_UIKIT_UITABBARITEM_H
#import <UIKit/UIKitTypes.h>
@class UIImage;
typedef NSInteger UITabBarSystemItem;
enum { UITabBarSystemItemMore, UITabBarSystemItemFavorites, UITabBarSystemItemFeatured, UITabBarSystemItemTopRated, UITabBarSystemItemRecents, UITabBarSystemItemContacts, UITabBarSystemItemHistory };
@interface UITabBarItem : NSObject { NSString *_title; UIImage *_image; NSInteger _tag; }
- (id)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag;
- (id)initWithTabBarSystemItem:(UITabBarSystemItem)item tag:(NSInteger)tag;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic) NSInteger tag;
@end
#endif
