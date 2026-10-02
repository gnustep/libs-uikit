#import "UIKitPrivate.h"

NSString *UITextViewTextDidBeginEditingNotification = @"UITextViewTextDidBeginEditingNotification";
NSString *UITextViewTextDidChangeNotification = @"UITextViewTextDidChangeNotification";
NSString *UITextViewTextDidEndEditingNotification = @"UITextViewTextDidEndEditingNotification";

@implementation UITextView
@synthesize adjustsFontForContentSizeCategory = _adjustsFontForContentSizeCategory;
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _textView = [[NSTextView alloc] initWithFrame:[self bounds]];
      [_textView setDelegate:(id)self];
      [_textView setRichText:NO];
      [_textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
      [[self _nativeContainerView] addSubview:_textView];
    }
  return self;
}
- (void)dealloc
{
  [_textView setDelegate:nil];
  [_textView release];
  [_font release];
  [_textColor release];
  [super dealloc];
}
- (BOOL)canBecomeFirstResponder { return [self isEditable] || [self isSelectable]; }
- (NSResponder *)_nativeResponder { return _textView; }
- (NSString *)text { return [_textView string]; }
- (void)setText:(NSString *)text
{
  _uiSettingText = YES;
  @try { [_textView setString:text ?: @""]; }
  @finally { _uiSettingText = NO; }
}
- (id<UITextViewDelegate>)delegate { return _scrollDelegate; }
- (void)setDelegate:(id<UITextViewDelegate>)delegate { _scrollDelegate = delegate; }
- (BOOL)isEditable { return [_textView isEditable]; }
- (void)setEditable:(BOOL)value { [_textView setEditable:value]; }
- (BOOL)isSelectable { return [_textView isSelectable]; }
- (void)setSelectable:(BOOL)value { [_textView setSelectable:value]; }
- (NSRange)selectedRange { return [_textView selectedRange]; }
- (void)setSelectedRange:(NSRange)range
{
  NSUInteger length = [[self text] length];
  if (range.location > length || range.length > length-range.location)
    [NSException raise:NSRangeException format:@"Text selection is outside the string"];
  [_textView setSelectedRange:range];
}
- (NSAttributedString *)attributedText { return [[[_textView textStorage] copy] autorelease]; }
- (void)setAttributedText:(NSAttributedString *)value
{
  _uiSettingText = YES;
  @try { [[_textView textStorage] setAttributedString:value ?: [[[NSAttributedString alloc] initWithString:@""] autorelease]]; }
  @finally { _uiSettingText = NO; }
}
- (NSTextAlignment)textAlignment { return _textAlignment; }
- (void)setTextAlignment:(NSTextAlignment)value { _textAlignment = value; [_textView setAlignment:UIKitNativeTextAlignment(value)]; }
- (BOOL)textShouldBeginEditing:(NSText *)editor
{ return ![_scrollDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)] || [_scrollDelegate textViewShouldBeginEditing:self]; }
- (BOOL)textShouldEndEditing:(NSText *)editor
{ return ![_scrollDelegate respondsToSelector:@selector(textViewShouldEndEditing:)] || [_scrollDelegate textViewShouldEndEditing:self]; }
- (BOOL)textView:(NSTextView *)editor shouldChangeTextInRange:(NSRange)range replacementString:(NSString *)string
{
  return _uiSettingText || ![_scrollDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)] ||
    [_scrollDelegate textView:self shouldChangeTextInRange:range replacementText:string ?: @""];
}
- (void)textDidBeginEditing:(NSNotification *)note
{
  if ([_scrollDelegate respondsToSelector:@selector(textViewDidBeginEditing:)]) [_scrollDelegate textViewDidBeginEditing:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidBeginEditingNotification object:self];
}
- (void)textDidEndEditing:(NSNotification *)note
{
  if ([_scrollDelegate respondsToSelector:@selector(textViewDidEndEditing:)]) [_scrollDelegate textViewDidEndEditing:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidEndEditingNotification object:self];
}
- (void)textDidChange:(NSNotification *)note
{
  if (_uiSettingText) return;
  if ([_scrollDelegate respondsToSelector:@selector(textViewDidChange:)]) [_scrollDelegate textViewDidChange:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
}
- (void)textViewDidChangeSelection:(NSNotification *)note
{
  if (!_uiSettingText && [_scrollDelegate respondsToSelector:@selector(textViewDidChangeSelection:)])
    [_scrollDelegate textViewDidChangeSelection:self];
}
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
