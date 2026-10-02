#import "UIKitPrivate.h"
@implementation UIActivityViewController
- (id)initWithActivityItems:(NSArray *)items applicationActivities:(NSArray *)activities {
  if (activities.count) { [self release]; [NSException raise:NSInvalidArgumentException format:@"Custom activities are not supported"]; return nil; }
  self = [super initWithNibName:nil bundle:nil]; if (self) _activityItems = [items copy]; return self;
}
- (void)dealloc { [_activityItems release]; [super dealloc]; }
- (void)loadView {
  [super loadView]; _view.backgroundColor = [UIColor systemBackgroundColor];
  UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(20,20,280,100)] autorelease];
  label.text = [_activityItems componentsJoinedByString:@"\n"]; label.numberOfLines = 0; [_view addSubview:label];
  UIButton *copy = [UIButton buttonWithType:0]; copy.frame = CGRectMake(20,130,280,40); [copy setTitle:@"Copy" forState:0];
  [copy addTarget:self action:@selector(_copy:) forControlEvents:UIControlEventTouchUpInside]; [_view addSubview:copy];
  UIButton *cancel = [UIButton buttonWithType:0]; cancel.frame = CGRectMake(20,180,280,40); [cancel setTitle:@"Cancel" forState:0];
  [cancel addTarget:self action:@selector(_cancel:) forControlEvents:UIControlEventTouchUpInside]; [_view addSubview:cancel];
  _view.frame = CGRectMake(0,0,320,240);
}
- (void)_copy:(id)sender {
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard]; [pasteboard declareTypes:@[NSStringPboardType] owner:nil];
  [pasteboard setString:[_activityItems componentsJoinedByString:@"\n"] forType:NSStringPboardType];
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)_cancel:(id)sender { [self dismissViewControllerAnimated:YES completion:nil]; }
@end
@implementation UIColorPickerViewController
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle { self = [super initWithNibName:name bundle:bundle]; if (self) _selectedColor = [[UIColor blueColor] retain]; return self; }
- (void)dealloc { [_colorWell deactivate]; [_colorWell release]; [_selectedColor release]; [super dealloc]; }
@synthesize delegate = _delegate;
- (UIColor *)selectedColor { return _selectedColor; }
- (void)setSelectedColor:(UIColor *)color { ASSIGN(_selectedColor,color); [_colorWell setColor:[color NSColor]]; }
- (void)loadView {
  [super loadView];
  UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(20,20,280,50)] autorelease]; label.text = @"Select a color"; [_view addSubview:label];
  _colorWell = [[NSColorWell alloc] initWithFrame:CGRectMake(20,80,280,100)];
  [_colorWell setColor:[_selectedColor NSColor]]; [_colorWell setTarget:self]; [_colorWell setAction:@selector(_changed:)]; [_view _addNativeSubview:_colorWell];
}
- (void)_changed:(id)sender {
  self.selectedColor = [UIColor _colorWithNSColor:[sender color]];
  if ([_delegate respondsToSelector:@selector(colorPickerViewControllerDidSelectColor:)]) [_delegate colorPickerViewControllerDidSelectColor:self];
}
- (void)viewDidDisappear:(BOOL)animated { [super viewDidDisappear:animated]; [_colorWell deactivate]; if ([_delegate respondsToSelector:@selector(colorPickerViewControllerDidFinish:)]) [_delegate colorPickerViewControllerDidFinish:self]; }
@end
@implementation UIFontDescriptor
+ (UIFontDescriptor *)fontDescriptorWithName:(NSString *)name size:(CGFloat)size { UIFontDescriptor *descriptor = [[[self alloc] init] autorelease]; descriptor->_fontName = [name copy]; descriptor->_pointSize = size; return descriptor; }
- (void)dealloc { [_fontName release]; [super dealloc]; }
- (id)copyWithZone:(NSZone *)zone { return [self retain]; }
- (NSString *)postscriptName { return _fontName; }
- (CGFloat)pointSize { return _pointSize; }
@end
@implementation UIFontPickerViewControllerConfiguration
@synthesize includeFaces = _includeFaces;
- (id)copyWithZone:(NSZone *)zone { UIFontPickerViewControllerConfiguration *copy = [[[self class] allocWithZone:zone] init]; copy.includeFaces = _includeFaces; return copy; }
@end
@implementation UIFontPickerViewController
- (id)init { return [self initWithConfiguration:[[[UIFontPickerViewControllerConfiguration alloc] init] autorelease]]; }
- (id)initWithConfiguration:(UIFontPickerViewControllerConfiguration *)configuration { self = [super initWithNibName:nil bundle:nil]; if (self) _configuration = [configuration copy]; return self; }
- (void)dealloc { [_configuration release]; [_selectedFontDescriptor release]; [_fontMenu release]; [super dealloc]; }
@synthesize delegate = _delegate;
- (UIFontPickerViewControllerConfiguration *)configuration { return _configuration; }
- (UIFontDescriptor *)selectedFontDescriptor { return _selectedFontDescriptor; }
- (void)setSelectedFontDescriptor:(UIFontDescriptor *)descriptor { ASSIGN(_selectedFontDescriptor,descriptor); if (descriptor) [_fontMenu selectItemWithTitle:descriptor.postscriptName]; }
- (void)loadView {
  [super loadView];
  UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(20,20,280,50)] autorelease]; label.text = @"Select a font"; [_view addSubview:label];
  _fontMenu = [[NSPopUpButton alloc] initWithFrame:CGRectMake(20,80,280,36) pullsDown:NO];
  NSArray *fonts = _configuration.includeFaces ? [[NSFontManager sharedFontManager] availableFonts] : [[NSFontManager sharedFontManager] availableFontFamilies];
  [_fontMenu addItemsWithTitles:[fonts sortedArrayUsingSelector:@selector(compare:)]];
  [_fontMenu setTarget:self]; [_fontMenu setAction:@selector(_changed:)]; [_view _addNativeSubview:_fontMenu];
  if (_selectedFontDescriptor) [_fontMenu selectItemWithTitle:_selectedFontDescriptor.postscriptName];
}
- (void)_changed:(id)sender {
  NSString *name = [sender titleOfSelectedItem];
  NSFont *font = _configuration.includeFaces ? [NSFont fontWithName:name size:17] : [[NSFontManager sharedFontManager] fontWithFamily:name traits:0 weight:5 size:17];
  self.selectedFontDescriptor = [UIFontDescriptor fontDescriptorWithName:font.fontName ?: name size:17];
  if ([_delegate respondsToSelector:@selector(fontPickerViewControllerDidPickFont:)]) [_delegate fontPickerViewControllerDidPickFont:self];
}
@end