#import "UIKitPrivate.h"
@implementation UINavigationItem
- (id)initWithTitle:(NSString *)title { self = [super init]; if (self) _title = [title copy]; return self; }
- (void)dealloc { [_title release]; [_titleView release]; [_leftBarButtonItem release]; [_rightBarButtonItem release]; [_searchController release]; [super dealloc]; }
- (void)_changed { [[NSNotificationCenter defaultCenter] postNotificationName:@"UIKitNavigationItemChanged" object:self]; }
- (NSString *)title { return _title; }
- (void)setTitle:(NSString *)title { ASSIGNCOPY(_title,title); [self _changed]; }
@synthesize hidesSearchBarWhenScrolling = _hidesSearchBarWhenScrolling;
- (UIView *)titleView { return _titleView; }
- (void)setTitleView:(UIView *)value { ASSIGN(_titleView,value); [self _changed]; }
- (UIBarButtonItem *)leftBarButtonItem { return _leftBarButtonItem; }
- (void)setLeftBarButtonItem:(UIBarButtonItem *)value { ASSIGN(_leftBarButtonItem,value); [self _changed]; }
- (UIBarButtonItem *)rightBarButtonItem { return _rightBarButtonItem; }
- (void)setRightBarButtonItem:(UIBarButtonItem *)value { ASSIGN(_rightBarButtonItem,value); [self _changed]; }
- (UISearchController *)searchController { return _searchController; }
- (void)setSearchController:(UISearchController *)value { ASSIGN(_searchController,value); [self _changed]; }
@end
