#ifndef GNUSTEP_UIKIT_UISEARCHCONTROLLER_H
#define GNUSTEP_UIKIT_UISEARCHCONTROLLER_H
#import <UIKit/UIViewController.h>
#import <UIKit/UISearchBar.h>
@class UISearchController;
@protocol UISearchResultsUpdating <NSObject>
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController;
@end
@interface UISearchController : UIViewController <UISearchBarDelegate>
{
  UISearchBar *_searchBar;
  UIViewController *_searchResultsController;
  id<UISearchResultsUpdating> _searchResultsUpdater;
  BOOL _active, _obscuresBackgroundDuringPresentation;
}
- (id)initWithSearchResultsController:(UIViewController *)controller;
@property(nonatomic, readonly) UISearchBar *searchBar;
@property(nonatomic, readonly) UIViewController *searchResultsController;
@property(nonatomic, assign) id<UISearchResultsUpdating> searchResultsUpdater;
@property(nonatomic, getter=isActive) BOOL active;
@property(nonatomic) BOOL obscuresBackgroundDuringPresentation;
@end
#endif
