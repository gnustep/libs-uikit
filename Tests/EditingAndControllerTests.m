#import <UIKit/GNUstepUIKit.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define VERIFY(c) do { if (!(c)) { fprintf(stderr, "FAIL editing/controllers %d: %s\n", __LINE__, #c); abort(); } } while (0)
@interface EditingProbe : NSObject <UITextFieldDelegate, UITextViewDelegate>
{ @public BOOL allow; NSInteger edits, returns, changes, began, ended; }
@end
@implementation EditingProbe
- (BOOL)textFieldShouldBeginEditing:(UITextField *)field { return allow; }
- (BOOL)textFieldShouldEndEditing:(UITextField *)field { return allow; }
- (BOOL)textFieldShouldReturn:(UITextField *)field { returns++; return allow; }
- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{ edits++; return allow; }
- (void)textFieldDidBeginEditing:(UITextField *)field { began++; }
- (void)textFieldDidEndEditing:(UITextField *)field { ended++; }
- (BOOL)textViewShouldBeginEditing:(UITextView *)view { return allow; }
- (BOOL)textViewShouldEndEditing:(UITextView *)view { return allow; }
- (BOOL)textView:(UITextView *)view shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{ edits++; return allow; }
- (void)textViewDidChange:(UITextView *)view { changes++; }
@end
@interface TextFieldEditingBridge : UITextField
- (BOOL)control:(NSControl *)control textView:(NSTextView *)editor doCommandBySelector:(SEL)command;
@end
@interface TableControllerProbe : UITableViewController @end
@implementation TableControllerProbe
- (void)viewDidLoad
{
  [super viewDidLoad]; self.tableView.rowHeight = 70;
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"row"];
}
- (NSInteger)tableView:(UITableView *)view numberOfRowsInSection:(NSInteger)section { return 3; }
- (UITableViewCell *)tableView:(UITableView *)view cellForRowAtIndexPath:(NSIndexPath *)path
{ return [view dequeueReusableCellWithIdentifier:@"row" forIndexPath:path]; }
@end
@interface CollectionControllerProbe : UICollectionViewController @end
@implementation CollectionControllerProbe
- (void)viewDidLoad { [super viewDidLoad]; [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"item"]; }
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section { return 3; }
- (UICollectionViewCell *)collectionView:(UICollectionView *)view cellForItemAtIndexPath:(NSIndexPath *)path
{ return [view dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:path]; }
@end

void testUIKitEditingAndControllers(void)
{
  EditingProbe *probe = [EditingProbe new]; probe->allow = YES;
  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0,0,400,300)];
  UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(10,10,200,30)];
  field.delegate = probe; [window addSubview:field]; [window makeKeyAndVisible];
  VERIFY([field becomeFirstResponder]);
  NSTextField *native = [[field _nativeView].subviews objectAtIndex:0];
  NSTextView *editor = (NSTextView *)[native currentEditor]; VERIFY(editor != nil);
  [editor insertText:@"ok"]; VERIFY([[field text] isEqual:@"ok"] && probe->edits > 0);
  VERIFY(field.isEditing && probe->began == 1);
  probe->allow = NO; [editor insertText:@"rejected"]; VERIFY([[field text] isEqual:@"ok"]);
  VERIFY([(TextFieldEditingBridge *)field control:native textView:editor doCommandBySelector:@selector(insertNewline:)]);
  VERIFY(probe->returns == 1);
  probe->allow = YES; VERIFY([field resignFirstResponder]); VERIFY(!field.isEditing && probe->ended == 1);
  field.secureTextEntry = YES; VERIFY(field.delegate == probe); VERIFY([field becomeFirstResponder]);
  native = [[field _nativeView].subviews objectAtIndex:0]; editor = (NSTextView *)[native currentEditor];
  probe->allow = NO; NSString *before = [[field text] copy]; [editor insertText:@"no"];
  VERIFY([[field text] isEqual:before]); [before release]; probe->allow = YES; [field resignFirstResponder];

  UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(10,60,250,150)];
  text.delegate = probe; [window addSubview:text];
  text.text = @"initial"; VERIFY(probe->changes == 0);
  text.selectedRange = NSMakeRange(1,2); VERIFY(text.selectedRange.location == 1 && text.selectedRange.length == 2);
  NSTextView *nativeText = (NSTextView *)[[[[text _nativeView] subviews] objectAtIndex:0] documentView];
  /* UIScrollView's document contains the editor, never a public UIKit child. */
  nativeText = [[nativeText subviews] objectAtIndex:0];
  VERIFY([text becomeFirstResponder]);
  [nativeText setSelectedRange:NSMakeRange(7,0)]; [nativeText insertText:@"!"];
  VERIFY([[text text] isEqual:@"initial!"] && probe->changes == 1);
  probe->allow = NO; [nativeText insertText:@"no"]; VERIFY([[text text] isEqual:@"initial!"]);
  probe->allow = YES; text.attributedText = [[[NSAttributedString alloc] initWithString:@"rich"] autorelease];
  VERIFY([text.text isEqual:@"rich"] && probe->changes == 1);
  text.editable = NO; VERIFY(!text.isEditable);
  [window close]; field.delegate = nil; text.delegate = nil;
  [field release]; [text release]; [window release]; [probe release];

  TableControllerProbe *table = [[TableControllerProbe alloc] initWithStyle:UITableViewStylePlain];
  VERIFY(!table.isViewLoaded && table.clearsSelectionOnViewWillAppear);
  UITableView *tableView = [table.tableView retain]; VERIFY(tableView.dataSource == table && tableView.delegate == table);
  [table beginAppearanceTransition:YES animated:NO]; [table endAppearanceTransition];
  VERIFY(tableView.numberOfSections == 1 && [tableView numberOfRowsInSection:0] == 3);
  tableView.frame = CGRectMake(0,0,600,480); [tableView layoutIfNeeded];
  VERIFY(tableView.contentSize.width == 600);
  NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
  [tableView selectRowAtIndexPath:first animated:NO scrollPosition:0];
  [table viewWillAppear:NO]; VERIFY(tableView.indexPathForSelectedRow == nil);
  table.clearsSelectionOnViewWillAppear = NO;
  [tableView selectRowAtIndexPath:first animated:NO scrollPosition:0]; [table viewWillAppear:NO];
  VERIFY([tableView.indexPathForSelectedRow isEqual:first]);
  [table release]; VERIFY(tableView.delegate == nil && tableView.dataSource == nil); [tableView release];

  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  CollectionControllerProbe *collection = [[CollectionControllerProbe alloc] initWithCollectionViewLayout:layout];
  VERIFY(collection.collectionViewLayout == layout && !collection.isViewLoaded);
  [collection beginAppearanceTransition:YES animated:NO]; [collection endAppearanceTransition];
  UICollectionView *collectionView = [collection.collectionView retain];
  VERIFY(collectionView.dataSource == collection && [collectionView numberOfItemsInSection:0] == 3);
  [collectionView selectItemAtIndexPath:first animated:NO scrollPosition:0];
  [collection viewWillAppear:NO]; VERIFY(collectionView.indexPathsForSelectedItems.count == 0);
  [collection release]; VERIFY(collectionView.delegate == nil && collectionView.dataSource == nil);
  [collectionView release]; [layout release];

  NSBundle *bundle = [NSBundle bundleWithPath:[[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"Tests/Fixtures.bundle"]];
  UIViewController *controller = [[UIViewController alloc] initWithNibName:@"Layout" bundle:bundle];
  [controller.view layoutIfNeeded]; UIView *content = [controller.view viewWithTag:41];
  VERIFY(fabs(content.frame.origin.x-16)<0.001 && fabs(content.frame.origin.y-12)<0.001 && fabs(content.frame.size.width-144)<0.001 && fabs(content.frame.size.height-40)<0.001);
  controller.view.frame = CGRectMake(0,0,640,400); [controller.view layoutIfNeeded];
  VERIFY(fabs(content.frame.size.width-304)<0.001 && fabs(content.frame.size.height-40)<0.001); [controller release];
  controller = [[UIViewController alloc] initWithNibName:@"StackLayout" bundle:bundle];
  UIView *root = controller.view;
  UIStackView *stack = (UIStackView *)[root viewWithTag:51];
  VERIFY([stack isKindOfClass:[UIStackView class]] && stack.superview == root);
  VERIFY(stack.axis == UILayoutConstraintAxisVertical && stack.spacing == 16);
  VERIFY(stack.distribution == UIStackViewDistributionFill && stack.alignment == UIStackViewAlignmentFill);
  VERIFY(stack.arrangedSubviews.count == 3 && [stack.arrangedSubviews isEqual:stack.subviews]);
  VERIFY([[stack.arrangedSubviews objectAtIndex:0] isKindOfClass:[UILabel class]]);
  VERIFY([[stack.arrangedSubviews objectAtIndex:1] isKindOfClass:[UITextField class]]);
  UIButton *button = [stack.arrangedSubviews objectAtIndex:2];
  VERIFY([button isKindOfClass:[UIButton class]]);
  VERIFY(button.constraints.count == 1 && [[button.constraints objectAtIndex:0] firstItem] == button);
  [root layoutIfNeeded];
  VERIFY(fabs(stack.frame.origin.x-24)<0.001 && fabs(stack.frame.origin.y-32)<0.001 && fabs(stack.frame.size.width-345)<0.001);
  root.frame = CGRectMake(0,0,600,852); [root layoutIfNeeded];
  VERIFY(fabs(stack.frame.size.width-552)<0.001);
  [controller release];
  fprintf(stderr, "UIKit editing, list-controller and XIB layout scenarios passed\n");
}
