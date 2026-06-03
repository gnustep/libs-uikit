#import "UIKitPrivate.h"

@implementation UILabel
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _textField = [[NSTextField alloc] initWithFrame:[self bounds]];
      [_textField setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      [_textField setBordered:NO];
      [_textField setEditable:NO];
      [_textField setDrawsBackground:NO];
      [_textField setSelectable:NO];
      [(NSView *)self addSubview:_textField];
      _textAlignment = NSTextAlignmentLeft;
      _numberOfLines = 1;
    }
  return self;
}
- (void)dealloc
{
  [_textField release];
  [super dealloc];
}
- (NSString *)text { return [_textField stringValue]; }
- (void)setText:(NSString *)text { [_textField setStringValue:(text == nil ? @"" : text)]; }
- (UIColor *)textColor { return [UIColor _colorWithNSColor:[_textField textColor]]; }
- (void)setTextColor:(UIColor *)color { [_textField setTextColor:[color NSColor]]; }
- (UIFont *)font { return [UIFont _fontWithNSFont:[_textField font]]; }
- (void)setFont:(UIFont *)font { [_textField setFont:[font NSFont]]; }
- (NSTextAlignment)textAlignment { return _textAlignment; }
- (void)setTextAlignment:(NSTextAlignment)alignment
{
  _textAlignment = alignment;
  [_textField setAlignment:(NSTextAlignment)alignment];
}
- (NSInteger)numberOfLines { return _numberOfLines; }
- (void)setNumberOfLines:(NSInteger)numberOfLines { _numberOfLines = numberOfLines; }
@end
