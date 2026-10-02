#import "UIKitPrivate.h"
@implementation UIBarButtonItem
- (id)init { self = [super init]; if (self) { _enabled = YES; _systemItem = -1; } return self; }
- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
  self = [self init]; if (self) { _title = [title copy]; _target = target; _action = action; } return self;
}
- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)item target:(id)target action:(SEL)action {
  NSArray *titles = @[@"Done", @"Cancel", @"Edit", @"Save", @"+", @"", @""];
  self = [self initWithTitle:item >= 0 && item < titles.count ? [titles objectAtIndex:item] : @"Action" style:0 target:target action:action];
  if (self) _systemItem = item; return self;
}
- (void)dealloc { [_title release]; [_customView release]; [super dealloc]; }
@synthesize title = _title, target = _target, action = _action, enabled = _enabled, customView = _customView;
- (BOOL)_isSpace { return _systemItem == UIBarButtonSystemItemFlexibleSpace || _systemItem == UIBarButtonSystemItemFixedSpace; }
- (void)_invoke:(id)sender { if (_enabled && _action) [[UIApplication sharedApplication] sendAction:_action to:_target from:self forEvent:nil]; }
- (UIView *)_view {
  if (_customView) return _customView;
  UIButton *button = [UIButton buttonWithType:0]; [button setTitle:_title forState:0]; button.enabled = _enabled;
  [button addTarget:self action:@selector(_invoke:) forControlEvents:UIControlEventTouchUpInside]; return button;
}
@end
@implementation UIToolbar
- (void)dealloc { [_items release]; [super dealloc]; }
- (NSArray *)items { return _items; }
- (void)setItems:(NSArray *)items { if ([_items isEqualToArray:items]) return; ASSIGNCOPY(_items,items); [self _rebuildItems]; [self setNeedsLayout]; }
- (void)setItems:(NSArray *)items animated:(BOOL)animated { self.items = items; }
- (CGSize)intrinsicContentSize { return CGSizeMake(UIViewNoIntrinsicMetric,44); }
- (void)_rebuildItems {
  for (UIView *view in [[self.subviews copy] autorelease]) [view removeFromSuperview];
  NSUInteger index=0;
  for (UIBarButtonItem *item in _items) {
    if (![item _isSpace]) { UIView *view = [item _view]; view.tag = index; [self addSubview:view]; }
    index++;
  }
}
- (void)layoutSubviews {
  [super layoutSubviews]; CGFloat width = self.bounds.size.width / MAX(1,_items.count);
  for (UIView *view in self.subviews) view.frame = CGRectMake(view.tag*width+4,4,MAX(0,width-8),MAX(0,self.bounds.size.height-8));
}
@end
@implementation UINavigationBar
- (id)initWithFrame:(CGRect)frame { self = [super initWithFrame:frame]; if (self) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changed:) name:@"UIKitNavigationItemChanged" object:nil]; return self; }
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; [_items release]; [super dealloc]; }
- (void)_changed:(NSNotification *)note { if ([_items containsObject:note.object]) { [self _rebuildItems]; [self setNeedsLayout]; } }
- (NSArray *)items { return _items; }
- (void)setItems:(NSArray *)items { if ([_items isEqualToArray:items]) return; ASSIGNCOPY(_items,items); [self _rebuildItems]; [self setNeedsLayout]; }
- (void)setItems:(NSArray *)items animated:(BOOL)animated { self.items = items; }
- (UINavigationItem *)topItem { return [_items lastObject]; }
- (CGSize)intrinsicContentSize { return CGSizeMake(UIViewNoIntrinsicMetric,self.topItem.searchController ? 84 : 44); }
- (void)_rebuildItems {
  for (UIView *view in [[self.subviews copy] autorelease]) [view removeFromSuperview];
  UINavigationItem *item = self.topItem;
  _leftView = [item.leftBarButtonItem _view]; _rightView = [item.rightBarButtonItem _view];
  _titleView = item.titleView;
  if (!_titleView) { UILabel *label = [[[UILabel alloc] init] autorelease]; label.text = item.title; label.textAlignment = NSTextAlignmentCenter; _titleView = label; }
  _searchView = item.searchController.searchBar;
  if (_leftView) [self addSubview:_leftView];
  if (_rightView) [self addSubview:_rightView];
  [self addSubview:_titleView];
  if (_searchView) [self addSubview:_searchView];
}
- (void)layoutSubviews {
  [super layoutSubviews]; CGFloat width = self.bounds.size.width;
  _leftView.frame = CGRectMake(4,4,76,36);
  _rightView.frame = CGRectMake(MAX(0,width-84),4,80,36);
  /* Reserve space for a navigation controller's default Back button. */
  CGFloat right = _rightView ? 84 : 8;
  _titleView.frame = CGRectMake(84,4,MAX(0,width-84-right),36);
  _searchView.frame = CGRectMake(8,46,MAX(0,width-16),32);
}
@end
@implementation UITabBarItem
- (id)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag { self=[super init]; if(self) { _title=[title copy]; _image=[image retain]; _tag=tag; } return self; }
- (id)initWithTabBarSystemItem:(UITabBarSystemItem)item tag:(NSInteger)tag {
  NSArray *titles = @[@"More",@"Favorites",@"Featured",@"Top Rated",@"Recents",@"Contacts",@"History"];
  return [self initWithTitle:item>=0 && item<titles.count ? [titles objectAtIndex:item] : @"Tab" image:nil tag:tag];
}
- (void)dealloc { [_title release]; [_image release]; [super dealloc]; }
@synthesize title=_title, image=_image, tag=_tag;
@end
@implementation UITabBar
- (void)dealloc { [_items release]; [_selectedItem release]; [super dealloc]; }
@synthesize delegate=_delegate;
- (NSArray *)items { return _items; }
- (void)setItems:(NSArray *)items { ASSIGNCOPY(_items,items); if (![_items containsObject:_selectedItem]) self.selectedItem = nil; [self _rebuildItems]; [self setNeedsLayout]; }
- (UITabBarItem *)selectedItem { return _selectedItem; }
- (void)setSelectedItem:(UITabBarItem *)item { if(item && ![_items containsObject:item]) [NSException raise:NSInvalidArgumentException format:@"Item is not in tab bar"]; ASSIGN(_selectedItem,item); [self setNeedsLayout]; }
- (void)_select:(UIButton *)button { self.selectedItem = [_items objectAtIndex:button.tag]; if ([_delegate respondsToSelector:@selector(tabBar:didSelectItem:)]) [_delegate tabBar:self didSelectItem:_selectedItem]; }
- (CGSize)intrinsicContentSize { return CGSizeMake(UIViewNoIntrinsicMetric,49); }
- (void)_rebuildItems {
  for (UIView *view in [[self.subviews copy] autorelease]) [view removeFromSuperview];
  NSInteger index=0;
  for (UITabBarItem *item in _items) { UIButton *button=[UIButton buttonWithType:0]; [button setTitle:item.title forState:0]; button.tag=index++; [button addTarget:self action:@selector(_select:) forControlEvents:UIControlEventTouchUpInside]; [self addSubview:button]; }
}
- (void)layoutSubviews {
  [super layoutSubviews]; CGFloat width=self.bounds.size.width/MAX(1,_items.count);
  for (UIButton *button in self.subviews) { button.selected=[_items objectAtIndex:button.tag]==_selectedItem; button.frame=CGRectMake(button.tag*width,0,width,self.bounds.size.height); }
}
@end
