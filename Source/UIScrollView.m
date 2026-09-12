#import <UIKit/UIScrollView.h>

@implementation UIScrollView
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _scrollView = [[NSScrollView alloc] initWithFrame:[self bounds]];
    [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:YES];
    _documentView = [[UIView alloc] initWithFrame:[self bounds]];
    [_scrollView setDocumentView:_documentView];
    [super addSubview:(UIView *)_scrollView];
    _contentSize = frame.size;
    [[_scrollView contentView] setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(_clipBoundsChanged:) name:NSViewBoundsDidChangeNotification
      object:[_scrollView contentView]];
  }
  return self;
}
- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_scrollView release]; [_documentView release];
  [super dealloc];
}
- (id)delegate { return _scrollDelegate; }
- (void)setDelegate:(id)delegate { _scrollDelegate = delegate; }
- (void)addSubview:(UIView *)view { [_documentView addSubview:view]; }
- (NSArray *)subviews { return [_documentView subviews]; }
- (CGSize)contentSize { return _contentSize; }
- (void)setContentSize:(CGSize)size
{
  _contentSize = NSMakeSize(MAX(0, size.width), MAX(0, size.height));
  [_documentView setFrame:NSMakeRect(0, 0, _contentSize.width, _contentSize.height)];
  [_scrollView reflectScrolledClipView:[_scrollView contentView]];
}
- (CGRect)visibleContentRect { return [_scrollView documentVisibleRect]; }
- (CGPoint)contentOffset { return [[_scrollView contentView] bounds].origin; }
- (void)setContentOffset:(CGPoint)offset
{
  NSSize viewport = [[_scrollView contentView] bounds].size;
  offset.x = MAX(0, MIN(offset.x, MAX(0, _contentSize.width - viewport.width)));
  offset.y = MAX(0, MIN(offset.y, MAX(0, _contentSize.height - viewport.height)));
  [[_scrollView contentView] scrollToPoint:offset];
  [_scrollView reflectScrolledClipView:[_scrollView contentView]];
  [self _clipBoundsChanged:nil];
}
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated { [self setContentOffset:offset]; }
- (void)_updateVisibleContent {}
- (void)_clipBoundsChanged:(NSNotification *)notification
{
  if (_updatingVisibleContent) return;
  _updatingVisibleContent = YES;
  @try { [self _updateVisibleContent]; }
  @finally { _updatingVisibleContent = NO; }
  id delegate = [self delegate];
  if ([delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    [delegate performSelector:@selector(scrollViewDidScroll:) withObject:self];
}
- (void)layoutSubviews
{
  [super layoutSubviews];
  [_scrollView setFrame:[self bounds]];
  [self _clipBoundsChanged:nil];
}
@end
