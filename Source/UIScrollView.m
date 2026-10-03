#import "UIKitPrivate.h"
#import <UIKit/UIScrollView.h>

/* UIKit indicators overlay the content; AppKit scrollers normally consume
   viewport space (and can appear on the left under a theme). */
@interface _UIKitScrollPeer : NSScrollView { @public UIScrollView *owner; }
@end
@implementation _UIKitScrollPeer
- (void)scrollWheel:(NSEvent *)event
{
  if (owner.keyboardDismissMode != UIScrollViewKeyboardDismissModeNone) [[owner window] endEditing:YES];
  if ([owner respondsToSelector:@selector(_handleScrollWheel:)]) [owner performSelector:@selector(_handleScrollWheel:) withObject:event];
  [super scrollWheel:event];
}
- (void)tile
{
  [super tile];
  NSRect bounds = [self bounds];
  [[self contentView] setFrame:bounds];
  CGFloat width = [NSScroller scrollerWidth];
  [[self verticalScroller] setFrame:NSMakeRect(NSMaxX(bounds)-width, 0, width, NSHeight(bounds))];
  [[self horizontalScroller] setFrame:NSMakeRect(0, NSMaxY(bounds)-width, NSWidth(bounds)-width, width)];
}
@end

@interface _UIKitScrollDocumentView : NSView { @public UIScrollView *owner; }
@end
@implementation _UIKitScrollDocumentView
- (BOOL)isFlipped { return YES; }
- (void)mouseDown:(NSEvent *)event { [owner mouseDown:event]; }
- (void)mouseDragged:(NSEvent *)event { [owner mouseDragged:event]; }
- (void)mouseUp:(NSEvent *)event { [owner mouseUp:event]; }
@end
@implementation UIScrollView
@synthesize keyboardDismissMode = _keyboardDismissMode;
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _scrollView = [[_UIKitScrollPeer alloc] initWithFrame:[self bounds]];
    ((_UIKitScrollPeer *)_scrollView)->owner = self;
    [_scrollView setDrawsBackground:NO];
    [[_scrollView contentView] setDrawsBackground:NO];
    [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:YES];
    _documentView = [[_UIKitScrollDocumentView alloc] initWithFrame:[self bounds]];
    ((_UIKitScrollDocumentView *)_documentView)->owner = self;
    [_scrollView setDocumentView:_documentView];
    [self _addNativeSubview:_scrollView];
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
  ((_UIKitScrollDocumentView *)_documentView)->owner = nil;
  ((_UIKitScrollPeer *)_scrollView)->owner = nil;
  [_scrollView release]; [_documentView release];
  [super dealloc];
}
- (UILayoutGuide *)contentLayoutGuide
{
  if (!_contentLayoutGuide) {
    _contentLayoutGuide = [[[UILayoutGuide alloc] init] autorelease]; [self addLayoutGuide:_contentLayoutGuide];
    [NSLayoutConstraint activateConstraints:@[[_contentLayoutGuide.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:-self.contentOffset.x],
      [_contentLayoutGuide.topAnchor constraintEqualToAnchor:self.topAnchor constant:-self.contentOffset.y]]];
  }
  return _contentLayoutGuide;
}
- (UILayoutGuide *)frameLayoutGuide
{
  if (!_frameLayoutGuide) {
    _frameLayoutGuide = [[[UILayoutGuide alloc] init] autorelease]; [self addLayoutGuide:_frameLayoutGuide];
    [NSLayoutConstraint activateConstraints:@[[_frameLayoutGuide.widthAnchor constraintEqualToAnchor:self.widthAnchor],
      [_frameLayoutGuide.heightAnchor constraintEqualToAnchor:self.heightAnchor],
      [_frameLayoutGuide.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
      [_frameLayoutGuide.topAnchor constraintEqualToAnchor:self.topAnchor]]];
  }
  return _frameLayoutGuide;
}
- (id)delegate { return _scrollDelegate; }
- (void)setDelegate:(id)delegate { _scrollDelegate = delegate; }
- (NSView *)_nativeContainerView { return _documentView ?: [super _nativeContainerView]; }
- (NSView *)_nativeCoordinateView { return _documentView ?: [super _nativeCoordinateView]; }
- (CGRect)bounds { CGRect bounds = [super bounds]; bounds.origin = [self contentOffset]; return bounds; }
- (void)setBounds:(CGRect)bounds { CGRect nativeBounds = bounds; nativeBounds.origin = CGPointZero; [super setBounds:nativeBounds]; [self setContentOffset:bounds.origin]; }
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
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
  CGRect visible = [self bounds];
  CGPoint offset = visible.origin;
  /* Move only enough to reveal the requested rectangle. Oversized rectangles
     already covering the viewport need no movement on that axis. */
  if (CGRectGetMinX(rect) < CGRectGetMinX(visible)) offset.x = CGRectGetMinX(rect);
  else if (CGRectGetMaxX(rect) > CGRectGetMaxX(visible))
    offset.x = MIN(CGRectGetMinX(rect), CGRectGetMaxX(rect)-visible.size.width);
  if (CGRectGetMinY(rect) < CGRectGetMinY(visible)) offset.y = CGRectGetMinY(rect);
  else if (CGRectGetMaxY(rect) > CGRectGetMaxY(visible))
    offset.y = MIN(CGRectGetMinY(rect), CGRectGetMaxY(rect)-visible.size.height);
  if (CGRectGetMinX(rect) <= CGRectGetMinX(visible) && CGRectGetMaxX(rect) >= CGRectGetMaxX(visible)) offset.x = visible.origin.x;
  if (CGRectGetMinY(rect) <= CGRectGetMinY(visible) && CGRectGetMaxY(rect) >= CGRectGetMaxY(visible)) offset.y = visible.origin.y;
  [self setContentOffset:offset animated:animated];
}
- (void)_updateVisibleContent {}
- (void)_clipBoundsChanged:(NSNotification *)notification
{
  if (_contentLayoutGuide) {
    CGPoint offset = [self contentOffset];
    for (NSLayoutConstraint *constraint in [self constraints]) {
      if (constraint.firstItem != _contentLayoutGuide || constraint.secondItem != self) continue;
      CGFloat value = constraint.firstAttribute == NSLayoutAttributeLeading ? -offset.x : -offset.y;
      if (constraint.constant != value) constraint.constant = value;
    }
  }
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
  if (_contentLayoutGuide) [self setContentSize:_contentLayoutGuide.layoutFrame.size];
  [_scrollView setFrame:CGRectMake(0,0,[self bounds].size.width,[self bounds].size.height)];
  [self _clipBoundsChanged:nil];
}
@end
