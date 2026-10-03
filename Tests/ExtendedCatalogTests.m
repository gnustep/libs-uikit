#import <UIKit/GNUstepUIKit.h>
#include <stdio.h>
#include <stdlib.h>
#define CHECK(c) do { if (!(c)) { fprintf(stderr,"FAIL extended catalog %d: %s\n",__LINE__,#c); abort(); } } while (0)
@interface UIColor (NativeTest)
- (NSColor *)NSColor;
@end
@interface UIMenu (NativeTest)
- (NSMenu *)_nativeMenu;
@end
@interface UIDocumentPickerViewController (NativeTest)
- (void)_finishWithURLs:(NSArray *)URLs;
@end
@interface UIImagePickerController (NativeTest)
- (void)_finishWithURL:(NSURL *)URL;
@end
@interface ExtendedProbe : NSObject <UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UITextFormattingViewControllerDelegate, UIDropInteractionDelegate>
{ @public NSUInteger changes, hoverEvents; NSArray *documents; UIImage *image; UIFont *font; NSString *dropped; }
@end
@implementation ExtendedProbe
- (void)dealloc { [documents release]; [image release]; [font release]; [dropped release]; [super dealloc]; }
- (void)changed:(id)sender { changes++; }
- (void)hovered:(id)sender { hoverEvents++; }
- (void)documentPicker:(UIDocumentPickerViewController *)picker didPickDocumentsAtURLs:(NSArray *)URLs { documents=[URLs copy]; }
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info { image=[[info objectForKey:UIImagePickerControllerOriginalImage] retain]; }
- (void)textFormattingViewController:(UITextFormattingViewController *)controller didChangeValue:(UITextFormattingViewControllerChangeValue *)change { [font release]; font=[change.font retain]; changes++; }
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session { return [session hasItemsConformingToTypeIdentifiers:@[@"public.text"]]; }
- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session { return [[[UIDropProposal alloc] initWithDropOperation:UIDropOperationCopy] autorelease]; }
- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session { [session loadObjectsOfClass:[NSString class] completion:^(NSArray *objects) { dropped=[[objects firstObject] copy]; }]; }
@end
/* Exercise the AppKit destination boundary with a real text pasteboard. */
@interface TextDropInfo : NSObject
@end
@implementation TextDropInfo
- (NSPasteboard *)draggingPasteboard { return [NSPasteboard generalPasteboard]; }
- (NSPoint)draggingLocation { return NSMakePoint(30,30); }
@end
static UILabel *FindLabel(UIView *view, NSString *text) {
  if ([view isKindOfClass:[UILabel class]] && [[(UILabel *)view text] isEqual:text]) return (UILabel *)view;
  for (UIView *child in view.subviews) { UILabel *label=FindLabel(child,text); if(label) return label; } return nil;
}
void testUIKitExtendedCatalog(void) {
  ExtendedProbe *probe=[[[ExtendedProbe alloc] init] autorelease];
  UIWindow *window=[[[UIWindow alloc] initWithFrame:CGRectMake(0,0,500,500)] autorelease];
  UIViewController *root=[[[UIViewController alloc] init] autorelease]; window.rootViewController=root; [window makeKeyAndVisible];
  UIColorWell *well=[[[UIColorWell alloc] initWithFrame:CGRectMake(0,0,80,40)] autorelease];
  [well addTarget:probe action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
  NSColorWell *nativeWell=[[well _nativeView].subviews firstObject]; [nativeWell setColor:[NSColor redColor]]; [nativeWell sendAction:nativeWell.action to:nativeWell.target];
  CHECK([[[well.selectedColor NSColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace] redComponent]>0.9 && probe->changes==1);
  UISearchTextField *search=[[[UISearchTextField alloc] initWithFrame:CGRectMake(0,50,220,40)] autorelease]; [root.view addSubview:search];
  [search addTarget:probe action:@selector(changed:) forControlEvents:UIControlEventEditingChanged];
  NSSearchField *nativeSearch=[[search _nativeView].subviews firstObject]; [nativeSearch setStringValue:@"Standalone"];
  [[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidChangeNotification object:nativeSearch]; CHECK([search.text isEqual:@"Standalone"] && probe->changes==2);
  UITextView *text=[[[UITextView alloc] initWithFrame:CGRectMake(0,100,300,70)] autorelease]; [root.view addSubview:text]; text.text=@"before after"; text.selectedRange=NSMakeRange(7,0);
  [UIPasteboard generalPasteboard].string=@"inserted ";
  UIPasteControl *paste=[[[UIPasteControl alloc] init] autorelease]; paste.target=text; NSButton *nativePaste=[[paste _nativeView].subviews firstObject];
  [nativePaste performClick:nil]; CHECK([text.text isEqual:@"before inserted after"]);
  paste.enabled=NO; CHECK(![nativePaste isEnabled]); [nativePaste performClick:nil]; CHECK([text.text isEqual:@"before inserted after"]);

  UICollectionViewListCell *cell=[[[UICollectionViewListCell alloc] initWithFrame:CGRectMake(0,0,300,100)] autorelease]; UIListContentConfiguration *config=cell.defaultContentConfiguration; config.text=@"Original"; config.secondaryText=@"Subtitle"; cell.contentConfiguration=config;
  config.text=@"Mutated"; [cell layoutIfNeeded]; CHECK(FindLabel(cell,@"Original") && !FindLabel(cell,@"Mutated"));
  cell.contentConfiguration=config; [cell layoutIfNeeded]; CHECK(FindLabel(cell,@"Mutated") && !FindLabel(cell,@"Original"));
  UITableViewHeaderFooterView *header=[[[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"section"] autorelease]; header.frame=CGRectMake(0,0,300,80); header.textLabel.text=@"Heading"; [header layoutIfNeeded]; CHECK(header.textLabel.superview==header.contentView && header.textLabel.frame.size.width==276);
  UIContentUnavailableView *empty=[[[UIContentUnavailableView alloc] initWithConfiguration:[UIContentUnavailableConfiguration searchConfiguration]] autorelease]; CHECK(FindLabel(empty,@"No Results")); empty.configuration=[UIContentUnavailableConfiguration loadingConfiguration]; CHECK(FindLabel(empty,@"Loading…") && !FindLabel(empty,@"No Results"));

  __block NSUInteger actions=0;
  UIAction *action=[UIAction actionWithTitle:@"Run" image:nil identifier:nil handler:^(UIAction *a){ actions++; }];
  UIAction *disabled=[UIAction actionWithTitle:@"Disabled" image:nil identifier:nil handler:^(UIAction *a){ actions+=100; }]; disabled.attributes=UIMenuElementAttributesDisabled;
  UIAction *hidden=[UIAction actionWithTitle:@"Hidden" image:nil identifier:nil handler:nil]; hidden.attributes=UIMenuElementAttributesHidden;
  NSMenu *menu=[[UIMenu menuWithTitle:@"Test" children:@[action,disabled,hidden]] _nativeMenu]; CHECK(menu.numberOfItems==2 && ![[menu itemAtIndex:1] isEnabled]);
  NSMenuItem *item=[menu itemAtIndex:0]; [item.target performSelector:item.action withObject:item]; CHECK(actions==1);
  item=[menu itemAtIndex:1]; [item.target performSelector:item.action withObject:item]; CHECK(actions==1);

  UIDocumentPickerViewController *picker=[[[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeOpen] autorelease]; picker.delegate=probe;
  UINavigationController *nav=[[[UINavigationController alloc] initWithRootViewController:picker] autorelease]; [root presentViewController:nav animated:NO completion:nil];
  NSURL *document=[NSURL fileURLWithPath:@"/tmp/example.txt"]; [picker _finishWithURLs:@[document]]; CHECK([probe->documents isEqual:@[document]] && root.presentedViewController==nil);
  UIImagePickerController *images=[[[UIImagePickerController alloc] init] autorelease]; images.delegate=probe; CHECK(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]);
  NSString *imagePath=[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo].globallyUniqueString stringByAppendingString:@".tiff"]];
  NSImage *fixture=[[[NSImage alloc] initWithSize:NSMakeSize(8,8)] autorelease]; [fixture lockFocus]; [[NSColor redColor] set]; NSRectFill(NSMakeRect(0,0,8,8)); [fixture unlockFocus]; [[fixture TIFFRepresentation] writeToFile:imagePath atomically:YES];
  [images _finishWithURL:[NSURL fileURLWithPath:imagePath]]; CHECK(probe->image.size.width==8); [[NSFileManager defaultManager] removeItemAtPath:imagePath error:NULL];
  CHECK([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:@"interface"] && ![UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:@"not-in-the-glossary"]);
  UITextFormattingViewController *format=[[[UITextFormattingViewController alloc] init] autorelease]; format.delegate=probe;
  for (UIView *v in format.view.subviews) if ([v isKindOfClass:[UIStepper class]]) { [(UIStepper *)v setValue:29]; [(UIStepper *)v sendActionsForControlEvents:UIControlEventValueChanged]; }
  CHECK(probe->font.pointSize==29 && probe->changes==3);

  UIView *area=[[[UIView alloc] initWithFrame:CGRectMake(0,200,300,100)] autorelease]; [root.view addSubview:area];
  UIToolTipInteraction *tooltip=[[[UIToolTipInteraction alloc] initWithDefaultToolTip:@"Hover tip"] autorelease]; [area addInteraction:tooltip]; CHECK([[[area _nativeView] toolTip] isEqual:@"Hover tip"]);
  UIHoverGestureRecognizer *hover=[[[UIHoverGestureRecognizer alloc] initWithTarget:probe action:@selector(hovered:)] autorelease]; [area addGestureRecognizer:hover];
  NSEvent *event=[NSEvent enterExitEventWithType:NSMouseEntered location:NSMakePoint(30,250) modifierFlags:0 timestamp:0 windowNumber:[window _nativeWindow].windowNumber context:nil eventNumber:1 trackingNumber:1 userData:NULL];
  [[area _nativeView] mouseEntered:event]; CHECK(hover.state==UIGestureRecognizerStateBegan && probe->hoverEvents==1);
  [[area _nativeView] mouseExited:event]; CHECK(hover.state==UIGestureRecognizerStateEnded && probe->hoverEvents==2);
  [root.view addInteraction:tooltip]; CHECK(tooltip.view==root.view && ![area.interactions containsObject:tooltip] && [[area _nativeView] toolTip]==nil);
  UIDropInteraction *drop=[[[UIDropInteraction alloc] initWithDelegate:probe] autorelease]; [area addInteraction:drop]; [UIPasteboard generalPasteboard].string=@"Dropped text";
  TextDropInfo *info=[[[TextDropInfo alloc] init] autorelease]; CHECK([[area _nativeView] draggingEntered:(id)info]==NSDragOperationCopy); CHECK([[area _nativeView] performDragOperation:(id)info]); CHECK([probe->dropped isEqual:@"Dropped text"]);
  [window close]; window.rootViewController=nil;
  fprintf(stderr,"PASS: extended controls, content, menus, picker results, formatting, hover, tooltips and text drops\n");
}
