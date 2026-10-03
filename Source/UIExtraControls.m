#import "UIKitPrivate.h"
@implementation UIColorWell
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) { _supportsAlpha = YES; _colorWell = [[NSColorWell alloc] initWithFrame:self.bounds];
    [_colorWell setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable]; [_colorWell setTarget:self]; [_colorWell setAction:@selector(_changed:)]; [self _addNativeSubview:_colorWell]; }
  return self;
}
- (void)dealloc { [_colorWell deactivate]; [_colorWell release]; [_title release]; [super dealloc]; }
@synthesize title = _title, supportsAlpha = _supportsAlpha;
- (UIColor *)selectedColor { return [UIColor _colorWithNSColor:[_colorWell color]]; }
- (void)setSelectedColor:(UIColor *)color { [_colorWell setColor:[color NSColor] ?: [NSColor clearColor]]; }
- (void)_changed:(id)sender { [self sendActionsForControlEvents:UIControlEventValueChanged]; }
- (void)setEnabled:(BOOL)enabled { [super setEnabled:enabled]; [_colorWell setEnabled:enabled]; }
- (CGSize)intrinsicContentSize { return CGSizeMake(44,32); }
@end
@implementation UISearchTextField
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [_textField setDelegate:nil]; [_textField removeFromSuperview]; [_textField release];
    _textField = [[NSSearchField alloc] initWithFrame:self.bounds];
    [_textField setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable]; [_textField setDelegate:self];
    [[_textField cell] setSendsWholeSearchString:YES];
    [_textField setTarget:self]; [_textField setAction:@selector(_uiTextFieldAction:)]; [self _addNativeSubview:_textField];
  } return self;
}
@end
@implementation UIPasteboard
+ (UIPasteboard *)generalPasteboard { static UIPasteboard *board; if (!board) { board=[self new]; board->_pasteboard=[[NSPasteboard generalPasteboard] retain]; } return board; }
- (void)dealloc { [_pasteboard release]; [super dealloc]; }
- (NSString *)string { return [_pasteboard stringForType:NSStringPboardType]; }
- (void)setString:(NSString *)string { [_pasteboard declareTypes:@[NSStringPboardType] owner:nil]; if (string) [_pasteboard setString:string forType:NSStringPboardType]; }
- (BOOL)hasStrings { return self.string != nil; }
@end
@implementation UIPasteControlConfiguration
- (id)copyWithZone:(NSZone *)zone { return [[[self class] allocWithZone:zone] init]; }
@end
@implementation UIPasteControl
- (id)initWithConfiguration:(UIPasteControlConfiguration *)configuration { return [self initWithFrame:CGRectZero]; }
- (id)initWithFrame:(CGRect)frame {
  self=[super initWithFrame:frame]; if (self) { _pasteButton=[[NSButton alloc] initWithFrame:self.bounds];
    [_pasteButton setTitle:@"Paste"]; [_pasteButton setBezelStyle:NSRoundedBezelStyle]; [_pasteButton setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_pasteButton setEnabled:NO]; [_pasteButton setTarget:self]; [_pasteButton setAction:@selector(_paste:)]; [self _addNativeSubview:_pasteButton]; }
  return self;
}
- (void)dealloc { [_pasteButton release]; [super dealloc]; }
- (UIResponder *)target { return _target; }
- (void)setTarget:(UIResponder *)target { _target=target; [_pasteButton setEnabled:target != nil && [self isEnabled]]; }
- (void)setEnabled:(BOOL)enabled { [super setEnabled:enabled]; [_pasteButton setEnabled:enabled && _target != nil]; }
- (void)_paste:(id)sender { if ([self isEnabled] && [[UIPasteboard generalPasteboard] hasStrings]) [_target paste:self]; }
- (CGSize)intrinsicContentSize { return CGSizeMake(100,36); }
@end