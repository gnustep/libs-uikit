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
      [_textField setBezeled:NO];
      [_textField setEditable:NO];
      [_textField setDrawsBackground:NO];
      [_textField setSelectable:NO];
      [self _addNativeSubview:_textField];
      _textAlignment = NSTextAlignmentLeft;
      [self setNumberOfLines:1];
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
  [_textField setAlignment:UIKitNativeTextAlignment(alignment)];
}
- (NSInteger)numberOfLines { return _numberOfLines; }
- (void)setNumberOfLines:(NSInteger)numberOfLines
{
  _numberOfLines = MAX(0, numberOfLines);
  [[_textField cell] setWraps:_numberOfLines != 1];
  [[_textField cell] setUsesSingleLineMode:_numberOfLines == 1];
  if ([_textField respondsToSelector:@selector(setMaximumNumberOfLines:)])
    [(id)_textField setMaximumNumberOfLines:_numberOfLines];
  [self setNeedsLayout];
}
- (CGSize)sizeThatFits:(CGSize)size
{
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:[_textField font] forKey:NSFontAttributeName];
  CGFloat width = _numberOfLines == 1 ? 1000000 : MAX(1, size.width);
  CGRect measured = [[self text] boundingRectWithSize:CGSizeMake(width, 1000000)
    options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes];
  CGFloat height = ceil(measured.size.height);
  if (_numberOfLines > 0) height = MIN(height, _numberOfLines * ceil([[self font] lineHeight]));
  return CGSizeMake(ceil(measured.size.width), height);
}
- (void)layoutSubviews
{
  [super layoutSubviews];
  CGRect frame = [self bounds];
  if (_numberOfLines > 0) frame.size.height = MIN(frame.size.height, _numberOfLines * ceil([[self font] lineHeight]) + 2);
  [_textField setFrame:frame];
}
@end
