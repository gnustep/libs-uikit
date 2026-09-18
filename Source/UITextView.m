#import "UIKitPrivate.h"

@implementation UITextView
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _textView = [[NSTextView alloc] initWithFrame:[self bounds]];
      [_textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
      [[self _nativeContainerView] addSubview:_textView];
    }
  return self;
}
- (void)dealloc
{
  [_textView release];
  [_font release];
  [_textColor release];
  [super dealloc];
}
- (BOOL)canBecomeFirstResponder { return YES; }
- (NSResponder *)_nativeResponder { return _textView; }
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
