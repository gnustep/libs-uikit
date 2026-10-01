#import "UIKitPrivate.h"

NSString *UITextFieldTextDidBeginEditingNotification = @"UITextFieldTextDidBeginEditingNotification";
NSString *UITextFieldTextDidChangeNotification = @"UITextFieldTextDidChangeNotification";
NSString *UITextFieldTextDidEndEditingNotification = @"UITextFieldTextDidEndEditingNotification";

@interface UITextField (UIKitEditing)
- (BOOL)_shouldChangeRange:(NSRange)range replacement:(NSString *)string;
@end
@interface _UIKitTextFieldPeer : NSTextField @end
@interface _UIKitSecureTextFieldPeer : NSSecureTextField @end
/* The native field is its shared field editor's delegate. Forward edit vetoes
   here so rejected edits never reach the backing string or editing events. */
#define UIKIT_FIELD_EDITS \
- (BOOL)textView:(NSTextView *)view shouldChangeTextInRange:(NSRange)range replacementString:(NSString *)string \
{ return [(UITextField *)[self delegate] _shouldChangeRange:range replacement:string]; }
@implementation _UIKitTextFieldPeer
UIKIT_FIELD_EDITS
@end
@implementation _UIKitSecureTextFieldPeer
UIKIT_FIELD_EDITS
@end

@implementation UITextField
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _textField = [[_UIKitTextFieldPeer alloc] initWithFrame:[self bounds]];
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
  [_textField setDelegate:nil];
  [_textField release];
  [_placeholder release];
  [super dealloc];
}
- (void)_uiTextFieldAction:(id)sender { [self sendActionsForControlEvents:UIControlEventEditingDidEndOnExit]; }
- (id<UITextFieldDelegate>)delegate { return _delegate; }
- (void)setDelegate:(id<UITextFieldDelegate>)delegate { _delegate = delegate; }
- (BOOL)isEditing { return _editing; }
- (BOOL)_shouldChangeRange:(NSRange)range replacement:(NSString *)string
{
  return ![_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] ||
    [_delegate textField:self shouldChangeCharactersInRange:range replacementString:string ?: @""];
}
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)editor
{ return ![_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)] || [_delegate textFieldShouldBeginEditing:self]; }
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)editor
{ return ![_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)] || [_delegate textFieldShouldEndEditing:self]; }
- (BOOL)control:(NSControl *)control textView:(NSTextView *)editor doCommandBySelector:(SEL)command
{
  if ([NSStringFromSelector(command) isEqualToString:@"insertNewline:"] && [_delegate respondsToSelector:@selector(textFieldShouldReturn:)])
    return ![_delegate textFieldShouldReturn:self];
  return NO;
}
- (void)controlTextDidBeginEditing:(NSNotification *)note
{
  _editing = YES;
  if ([_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) [_delegate textFieldDidBeginEditing:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidBeginEditingNotification object:self];
  [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
}
- (void)controlTextDidChange:(NSNotification *)note
{
  [self invalidateIntrinsicContentSize];
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self];
  [self sendActionsForControlEvents:UIControlEventEditingChanged];
}
- (void)controlTextDidEndEditing:(NSNotification *)note
{
  _editing = NO;
  if ([_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) [_delegate textFieldDidEndEditing:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidEndEditingNotification object:self];
  [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}
- (CGSize)intrinsicContentSize { return [[_textField cell] cellSize]; }
- (BOOL)canBecomeFirstResponder { return [self isEnabled]; }
- (NSResponder *)_nativeResponder { return _textField; }
- (NSString *)text { return [_textField stringValue]; }
- (void)setText:(NSString *)text { [_textField setStringValue:(text == nil ? @"" : text)]; [self invalidateIntrinsicContentSize]; }
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
- (void)setFont:(UIFont *)font { [_textField setFont:[font NSFont]]; [self invalidateIntrinsicContentSize]; }
- (BOOL)isSecureTextEntry { return _secureTextEntry; }
- (void)setSecureTextEntry:(BOOL)secureTextEntry
{
  if (_secureTextEntry == secureTextEntry) return;
  NSTextField *replacement = [[secureTextEntry ? [_UIKitSecureTextFieldPeer class] : [_UIKitTextFieldPeer class] alloc] initWithFrame:[_textField frame]];
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
