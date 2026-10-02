#ifndef GNUSTEP_UIKIT_UISEARCHBAR_H
#define GNUSTEP_UIKIT_UISEARCHBAR_H
#import <UIKit/UIView.h>
@class UISearchBar;
@protocol UISearchBarDelegate <NSObject>
@optional
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
@end
@interface UISearchBar : UIView { id _searchField; NSString *_lastNotifiedText; id<UISearchBarDelegate> _delegate; }
@property(nonatomic, assign) id<UISearchBarDelegate> delegate;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *placeholder;
@end
#endif
