#import <UIKit/UIScrollView.h>

@implementation UIScrollView
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _scrollView = [[NSScrollView alloc] initWithFrame:[self bounds]];
      [_scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      [_scrollView setHasVerticalScroller:YES];
      [_scrollView setHasHorizontalScroller:YES];
      _documentView = [[UIView alloc] initWithFrame:[self bounds]];
      [_scrollView setDocumentView:_documentView];
      [(NSView *)self addSubview:_scrollView];
      _contentSize = frame.size;
    }
  return self;
}
- (void)dealloc
{
  [_scrollView release];
  [_documentView release];
  [super dealloc];
}
- (void)addSubview:(UIView *)view { [_documentView addSubview:view]; }
- (NSArray *)subviews { return [_documentView subviews]; }
- (CGSize)contentSize { return _contentSize; }
- (void)setContentSize:(CGSize)contentSize
{
  _contentSize = contentSize;
  [_documentView setFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
}
- (CGPoint)contentOffset { return [[_scrollView contentView] bounds].origin; }
- (void)setContentOffset:(CGPoint)contentOffset { [[_scrollView contentView] scrollToPoint:contentOffset]; }
@end
