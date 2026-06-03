#import "UIKitPrivate.h"

@implementation UITextField
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _textField = [[NSTextField alloc] initWithFrame:[self bounds]];
      [_textField setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      [_textField setTarget:self];
      [_textField setAction:@selector(_uiTextFieldAction:)];
      [(NSView *)self addSubview:_textField];
      _textAlignment = NSTextAlignmentLeft;
    }
  return self;
}
- (void)dealloc
{
  [_textField release];
  [_placeholder release];
  [super dealloc];
}
- (void)_uiTextFieldAction:(id)sender { [self sendActionsForControlEvents:UIControlEventValueChanged]; }
- (NSString *)text { return [_textField stringValue]; }
- (void)setText:(NSString *)text { [_textField setStringValue:(text == nil ? @"" : text)]; }
- (NSString *)placeholder { return _placeholder; }
- (void)setPlaceholder:(NSString *)placeholder
{
  ASSIGNCOPY(_placeholder, placeholder);
  if ([_textField respondsToSelector:@selector(setPlaceholderString:)])
    [_textField setPlaceholderString:_placeholder];
}
- (UIColor *)textColor { return [UIColor _colorWithNSColor:[_textField textColor]]; }
- (void)setTextColor:(UIColor *)color { [_textField setTextColor:[color NSColor]]; }
- (UIFont *)font { return [UIFont _fontWithNSFont:[_textField font]]; }
- (void)setFont:(UIFont *)font { [_textField setFont:[font NSFont]]; }
- (BOOL)isSecureTextEntry { return _secureTextEntry; }
- (void)setSecureTextEntry:(BOOL)secureTextEntry { _secureTextEntry = secureTextEntry; }
- (NSTextAlignment)textAlignment { return _textAlignment; }
- (void)setTextAlignment:(NSTextAlignment)alignment
{
  _textAlignment = alignment;
  [_textField setAlignment:(NSTextAlignment)alignment];
}
- (void)setEnabled:(BOOL)enabled
{
  [super setEnabled:enabled];
  [_textField setEnabled:enabled];
}
@end
