#import "UIKitPrivate.h"

@implementation UITextField
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _textField = [[NSTextField alloc] initWithFrame:[self bounds]];
      [_textField setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      [_textField setDelegate:(id)self];
      [_textField setTarget:self];
      [_textField setAction:@selector(_uiTextFieldAction:)];
      [self _addNativeSubview:_textField];
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
- (void)_uiTextFieldAction:(id)sender { [self sendActionsForControlEvents:UIControlEventEditingDidEndOnExit]; }
- (void)controlTextDidBeginEditing:(NSNotification *)note { [self sendActionsForControlEvents:UIControlEventEditingDidBegin]; }
- (void)controlTextDidChange:(NSNotification *)note { [self sendActionsForControlEvents:UIControlEventEditingChanged]; }
- (void)controlTextDidEndEditing:(NSNotification *)note { [self sendActionsForControlEvents:UIControlEventEditingDidEnd]; }
- (BOOL)canBecomeFirstResponder { return [self isEnabled]; }
- (NSResponder *)_nativeResponder { return _textField; }
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
- (void)setSecureTextEntry:(BOOL)secureTextEntry
{
  if (_secureTextEntry == secureTextEntry) return;
  NSTextField *replacement = [[secureTextEntry ? [NSSecureTextField class] : [NSTextField class] alloc] initWithFrame:[_textField frame]];
  [replacement setStringValue:[_textField stringValue]];
  [replacement setFont:[_textField font]]; [replacement setTextColor:[_textField textColor]];
  [replacement setAlignment:[_textField alignment]]; [replacement setEnabled:[_textField isEnabled]];
  [replacement setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [replacement setTarget:self]; [replacement setAction:@selector(_uiTextFieldAction:)];
  [replacement setDelegate:(id)self];
  if ([replacement respondsToSelector:@selector(setPlaceholderString:)]) [replacement setPlaceholderString:_placeholder];
  BOOL editing = [_textField currentEditor] != nil;
  if (editing) [[self window] _makeFirstResponder:nil];
  [_textField setDelegate:nil]; [_textField removeFromSuperview]; [_textField release];
  _textField = replacement; _secureTextEntry = secureTextEntry;
  [self _addNativeSubview:_textField];
  if (editing) [self becomeFirstResponder];
}
- (NSTextAlignment)textAlignment { return _textAlignment; }
- (void)setTextAlignment:(NSTextAlignment)alignment
{
  _textAlignment = alignment;
  [_textField setAlignment:UIKitNativeTextAlignment(alignment)];
}
- (void)setEnabled:(BOOL)enabled
{
  [super setEnabled:enabled];
  [_textField setEnabled:enabled];
}
@end
