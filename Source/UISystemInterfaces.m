#import "UIKitPrivate.h"
static UIView *UIKitPickerContent(id target, NSString *title) {
  UIView *view=[[[UIView alloc] initWithFrame:CGRectMake(0,0,500,300)] autorelease]; view.backgroundColor=[UIColor systemBackgroundColor];
  UILabel *label=[[[UILabel alloc] initWithFrame:CGRectMake(24,24,452,70)] autorelease]; label.text=title; label.numberOfLines=0; label.autoresizingMask=UIViewAutoresizingFlexibleWidth; [view addSubview:label];
  UIButton *browse=[UIButton buttonWithType:UIButtonTypeSystem]; browse.frame=CGRectMake(24,112,452,44); browse.autoresizingMask=UIViewAutoresizingFlexibleWidth; [browse setTitle:@"Browse files…" forState:0]; [browse addTarget:target action:@selector(_choose:) forControlEvents:UIControlEventTouchUpInside]; [view addSubview:browse];
  UIButton *cancel=[UIButton buttonWithType:UIButtonTypeSystem]; cancel.frame=CGRectMake(24,176,452,44); cancel.autoresizingMask=UIViewAutoresizingFlexibleWidth; [cancel setTitle:@"Cancel" forState:0]; [cancel addTarget:target action:@selector(_cancel:) forControlEvents:UIControlEventTouchUpInside]; [view addSubview:cancel]; return view;
}
static NSArray *UIKitExtensions(NSArray *types) {
  if ([types containsObject:@"public.image"]) return @[@"png",@"jpg",@"jpeg",@"gif",@"tiff",@"bmp"];
  if ([types containsObject:@"public.plain-text"]) return @[@"txt",@"md",@"text",@"log"];
  return nil;
}
@implementation UIDocumentPickerViewController
- (id)initWithDocumentTypes:(NSArray *)types inMode:(UIDocumentPickerMode)mode {
  self=[super initWithNibName:nil bundle:nil]; if(self) { if(mode != UIDocumentPickerModeOpen && mode != UIDocumentPickerModeImport) { [self release]; [NSException raise:NSInvalidArgumentException format:@"Only opening/importing documents is supported"]; return nil; } _documentTypes=[types copy]; } return self;
}
- (void)dealloc { [_documentTypes release]; [super dealloc]; }
@synthesize delegate=_delegate, allowsMultipleSelection=_allowsMultipleSelection;
- (void)loadView { self.view=UIKitPickerContent(self,@"Choose a document from this computer."); }
- (void)_finishWithURLs:(NSArray *)URLs {
  [[self retain] autorelease]; [self dismissViewControllerAnimated:YES completion:nil];
  if ([_delegate respondsToSelector:@selector(documentPicker:didPickDocumentsAtURLs:)]) [_delegate documentPicker:self didPickDocumentsAtURLs:URLs];
}
- (void)_choose:(id)sender {
  NSOpenPanel *panel=[NSOpenPanel openPanel]; [panel setCanChooseDirectories:NO]; [panel setAllowsMultipleSelection:_allowsMultipleSelection];
  if ([panel runModalForTypes:UIKitExtensions(_documentTypes)] == NSOKButton) [self _finishWithURLs:panel.URLs];
}
- (void)_cancel:(id)sender { [[self retain] autorelease]; [self dismissViewControllerAnimated:YES completion:nil]; if ([_delegate respondsToSelector:@selector(documentPickerWasCancelled:)]) [_delegate documentPickerWasCancelled:self]; }
@end
@implementation UIDocumentBrowserViewController
- (id)initForOpeningFilesWithContentTypes:(NSArray *)types { self=[super initWithNibName:nil bundle:nil]; if(self) _allowedContentTypes=[types copy]; return self; }
- (void)dealloc { [_allowedContentTypes release]; [super dealloc]; }
@synthesize delegate=_delegate, allowsPickingMultipleItems=_allowsPickingMultipleItems;
- (void)loadView { self.view=UIKitPickerContent(self,@"Browse folders and select documents to open."); }
- (void)_finishWithURLs:(NSArray *)URLs { if ([_delegate respondsToSelector:@selector(documentBrowser:didPickDocumentsAtURLs:)]) [_delegate documentBrowser:self didPickDocumentsAtURLs:URLs]; }
- (void)_choose:(id)sender { NSOpenPanel *panel=[NSOpenPanel openPanel]; [panel setCanChooseDirectories:NO]; [panel setAllowsMultipleSelection:_allowsPickingMultipleItems]; if ([panel runModalForTypes:UIKitExtensions(_allowedContentTypes)] == NSOKButton) [self _finishWithURLs:panel.URLs]; }
- (void)_cancel:(id)sender { [self dismissViewControllerAnimated:YES completion:nil]; }
@end
NSString * const UIImagePickerControllerOriginalImage=@"UIImagePickerControllerOriginalImage";
NSString * const UIImagePickerControllerImageURL=@"UIImagePickerControllerImageURL";
@implementation UIImagePickerController
@synthesize delegate=_delegate;
+ (BOOL)isSourceTypeAvailable:(UIImagePickerControllerSourceType)type { return type == UIImagePickerControllerSourceTypePhotoLibrary || type == UIImagePickerControllerSourceTypeSavedPhotosAlbum; }
- (UIImagePickerControllerSourceType)sourceType { return _sourceType; }
- (void)setSourceType:(UIImagePickerControllerSourceType)type { if (![[self class] isSourceTypeAvailable:type]) [NSException raise:NSInvalidArgumentException format:@"Camera capture is not supported"]; _sourceType=type; }
- (void)loadView { self.view=UIKitPickerContent(self,@"Choose an image file to preview."); }
- (void)_finishWithURL:(NSURL *)URL {
  UIImage *image=[UIImage imageWithContentsOfFile:URL.path]; if (!image) return;
  NSDictionary *info=@{UIImagePickerControllerOriginalImage:image,UIImagePickerControllerImageURL:URL};
  if ([_delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) [_delegate imagePickerController:self didFinishPickingMediaWithInfo:info];
}
- (void)_choose:(id)sender { NSOpenPanel *panel=[NSOpenPanel openPanel]; [panel setCanChooseDirectories:NO]; [panel setAllowsMultipleSelection:NO]; if ([panel runModalForTypes:UIKitExtensions(@[@"public.image"])] == NSOKButton) [self _finishWithURL:[panel.URLs firstObject]]; }
- (void)_cancel:(id)sender { [[self retain] autorelease]; if ([_delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) [_delegate imagePickerControllerDidCancel:self]; else [self dismissViewControllerAnimated:YES completion:nil]; }
@end
/* A small built-in technical glossary keeps the live example useful offline.
   Extra definitions can be supplied in UIKitDictionary.plist in the app bundle. */
static NSDictionary *UIKitDictionary(void) {
  NSMutableDictionary *terms=[NSMutableDictionary dictionaryWithDictionary:@{
    @"interface":@"A shared boundary through which people or systems exchange information. In software, an interface defines the operations through which a component can be used.",
    @"widget":@"A small interface component that displays information or accepts input, such as a button, slider, or text field.",
    @"clipboard":@"A temporary storage area used to transfer copied or cut information between documents and applications.",
    @"dictionary":@"A reference collection that associates words with their meanings, usage, or translations."}];
  NSDictionary *extra=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UIKitDictionary" ofType:@"plist"]]; if(extra) [terms addEntriesFromDictionary:extra]; return terms;
}
@implementation UIReferenceLibraryViewController
+ (BOOL)dictionaryHasDefinitionForTerm:(NSString *)term { return [UIKitDictionary() objectForKey:term.lowercaseString] != nil; }
- (id)initWithTerm:(NSString *)term { self=[super initWithNibName:nil bundle:nil]; if(self) _term=[term copy]; return self; }
- (void)dealloc { [_term release]; [super dealloc]; }
- (void)loadView { [super loadView]; UILabel *label=[[[UILabel alloc] initWithFrame:CGRectMake(20,20,280,400)] autorelease]; label.numberOfLines=0; label.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; label.text=[NSString stringWithFormat:@"%@\n\n%@\n\nSource: bundled technical glossary",_term,[UIKitDictionary() objectForKey:_term.lowercaseString] ?: @"No definition is installed for this term."]; [_view addSubview:label]; }
@end
UITextFormattingViewControllerChangeType const UITextFormattingViewControllerFontPointSizeChangeType=@"fontPointSize";
UITextFormattingViewControllerChangeType const UITextFormattingViewControllerFontAttributesChangeType=@"fontAttributes";
@implementation UITextFormattingViewControllerConfiguration
- (id)copyWithZone:(NSZone *)zone { return [[[self class] allocWithZone:zone] init]; }
@end
@interface UITextFormattingViewControllerChangeValue (Value)
- (id)_initWithFont:(UIFont *)font type:(NSString *)type;
@end
@implementation UITextFormattingViewControllerChangeValue
@synthesize changeType=_changeType, font=_font, numberValue=_numberValue;
- (id)_initWithFont:(UIFont *)font type:(NSString *)type { self=[super init]; if(self) { _font=[font retain]; _changeType=[type copy]; _numberValue=[[NSNumber alloc] initWithDouble:font.pointSize]; } return self; }
- (void)dealloc { [_font release]; [_changeType release]; [_numberValue release]; [super dealloc]; }
@end
@implementation UITextFormattingViewController
- (id)init { return [self initWithConfiguration:[[[UITextFormattingViewControllerConfiguration alloc] init] autorelease]]; }
- (id)initWithConfiguration:(UITextFormattingViewControllerConfiguration *)configuration { self=[super initWithNibName:nil bundle:nil]; if(self) { _configuration=[configuration copy]; _pointSize=17; } return self; }
- (void)dealloc { [_configuration release]; [super dealloc]; }
@synthesize configuration=_configuration, delegate=_delegate;
- (void)loadView {
  [super loadView]; UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(20,20,280,40)] autorelease]; title.text=@"Text formatting"; [_view addSubview:title];
  UIStepper *size=[[[UIStepper alloc] initWithFrame:CGRectMake(20,80,120,36)] autorelease]; size.minimumValue=8; size.maximumValue=72; size.value=_pointSize; [size addTarget:self action:@selector(_sizeChanged:) forControlEvents:UIControlEventValueChanged]; [_view addSubview:size];
  UIButton *bold=[UIButton buttonWithType:0]; bold.frame=CGRectMake(20,136,280,44); [bold setTitle:@"Toggle bold" forState:0]; [bold addTarget:self action:@selector(_boldChanged:) forControlEvents:UIControlEventTouchUpInside]; [_view addSubview:bold];
}
- (void)_notify:(NSString *)type { UIFont *font=_bold ? [UIFont boldSystemFontOfSize:_pointSize] : [UIFont systemFontOfSize:_pointSize]; UITextFormattingViewControllerChangeValue *change=[[[UITextFormattingViewControllerChangeValue alloc] _initWithFont:font type:type] autorelease]; [_delegate textFormattingViewController:self didChangeValue:change]; }
- (void)_sizeChanged:(UIStepper *)stepper { _pointSize=stepper.value; [self _notify:UITextFormattingViewControllerFontPointSizeChangeType]; }
- (void)_boldChanged:(id)sender { _bold=!_bold; [self _notify:UITextFormattingViewControllerFontAttributesChangeType]; }
@end