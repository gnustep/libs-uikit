#import "UIKitPrivate.h"

@implementation UITextView
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _scrollView = [[NSScrollView alloc] initWithFrame:[self bounds]];
      [_scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      [_scrollView setHasVerticalScroller:YES];
      [_scrollView setHasHorizontalScroller:NO];
      _textView = [[NSTextView alloc] initWithFrame:[self bounds]];
      [_scrollView setDocumentView:_textView];
      [(NSView *)self addSubview:_scrollView];
    }
  return self;
}
- (void)dealloc
{
  [_scrollView release];
  [_textView release];
  [_font release];
  [_textColor release];
  [super dealloc];
}
- (NSString *)text { return [_textView string]; }
- (void)setText:(NSString *)text { [_textView setString:(text == nil ? @"" : text)]; }
- (UIFont *)font { return _font; }
- (void)setFont:(UIFont *)font
{
  ASSIGN(_font, font);
  [_textView setFont:[font NSFont]];
}
- (UIColor *)textColor { return _textColor; }
- (void)setTextColor:(UIColor *)color
{
  ASSIGN(_textColor, color);
  [_textView setTextColor:[color NSColor]];
}
@end
