#import "UIKitPrivate.h"
@implementation UIRefreshControl
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) { _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium]; [self addSubview:_indicator]; self.hidden = YES; }
  return self;
}
- (void)dealloc { [_indicator release]; [super dealloc]; }
- (BOOL)isRefreshing { return _refreshing; }
- (void)beginRefreshing { _refreshing = YES; self.hidden = NO; [_indicator startAnimating]; }
- (void)endRefreshing { _refreshing = NO; self.hidden = YES; [_indicator stopAnimating]; }
- (void)layoutSubviews { [super layoutSubviews]; _indicator.frame = CGRectMake(MAX(0,(self.bounds.size.width-24)/2),4,24,24); }
- (CGSize)intrinsicContentSize { return CGSizeMake(100,32); }
@end