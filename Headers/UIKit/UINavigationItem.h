#ifndef GNUSTEP_UIKIT_UINavigationITEM_H
#define GNUSTEP_UIKIT_UINavigationITEM_H

#import <UIKit/UIKitTypes.h>

@class UIView, UIBarButtonItem, UISearchController;
@interface UINavigationItem : NSObject
{
  NSString *_title;
  UIView *_titleView;
  UIBarButtonItem *_leftBarButtonItem, *_rightBarButtonItem;
  UISearchController *_searchController;
  BOOL _hidesSearchBarWhenScrolling;
}
- (id)initWithTitle:(NSString *)title;
@property(nonatomic, retain) UIView *titleView;
@property(nonatomic, retain) UIBarButtonItem *leftBarButtonItem;
@property(nonatomic, retain) UIBarButtonItem *rightBarButtonItem;
@property(nonatomic, retain) UISearchController *searchController;
@property(nonatomic) BOOL hidesSearchBarWhenScrolling;
- (NSString *)title;
- (void)setTitle:(NSString *)title;
@end

#endif
