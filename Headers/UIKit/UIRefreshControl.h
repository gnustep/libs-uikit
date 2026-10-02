#ifndef GNUSTEP_UIKIT_UIREFRESHCONTROL_H
#define GNUSTEP_UIKIT_UIREFRESHCONTROL_H
#import <UIKit/UIControl.h>
@class UIActivityIndicatorView;
@interface UIRefreshControl : UIControl
{ BOOL _refreshing; UIActivityIndicatorView *_indicator; }
@property(nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
- (void)beginRefreshing;
- (void)endRefreshing;
@end
#endif
