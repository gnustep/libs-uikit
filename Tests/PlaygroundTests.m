#import <UIKit/GNUstepUIKit.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define CHECK(c) do { if (!(c)) { fprintf(stderr,"FAIL playground %d: %s\n",__LINE__,#c); abort(); } } while (0)

@interface PlaygroundProbe : UIViewController <UITableViewDataSource>
{ @public NSMutableDictionary *outlets; NSInteger events, rows; }
@end
@implementation PlaygroundProbe
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
  self = [super initWithNibName:name bundle:bundle];
  if (self) { outlets = [NSMutableDictionary new]; rows = 12; }
  return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key { [outlets setObject:value forKey:key]; }
- (void)dealloc { [outlets release]; [super dealloc]; }
- (void)fontSizeChanged:(id)sender { events++; }
- (void)progressChanged:(id)sender { events++; }
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { return rows; }
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path
{
  UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"row" forIndexPath:path];
  cell.textLabel.text = [NSString stringWithFormat:@"Row %ld", (long)path.row];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}
@end

void testUIKitPlayground(void)
{
  NSBundle *bundle = [NSBundle bundleWithPath:[[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"Tests/Fixtures.bundle"]];
  PlaygroundProbe *owner = [[PlaygroundProbe alloc] initWithNibName:@"Playground" bundle:bundle];
  UIView *root = owner.view;
  UIStepper *stepper = [owner->outlets objectForKey:@"fontSizeStepper"];
  UIProgressView *progress = [owner->outlets objectForKey:@"progressView"];
  UISlider *slider = [owner->outlets objectForKey:@"progressSlider"];
  UISwitch *toggle = [owner->outlets objectForKey:@"personalizationSwitch"];
  UISegmentedControl *segments = [owner->outlets objectForKey:@"greetingStyleControl"];
  UIScrollView *scroll = [owner->outlets objectForKey:@"scrollView"];
  UIStackView *stack = [owner->outlets objectForKey:@"contentStack"];
  UITableView *table = [owner->outlets objectForKey:@"historyTableView"];
  CHECK([stepper isKindOfClass:[UIStepper class]] && [progress isKindOfClass:[UIProgressView class]]);
  CHECK(stepper.minimumValue == 16 && stepper.maximumValue == 32 && stepper.value == 20 && stepper.stepValue == 2);
  CHECK(toggle.on && progress.progress == 0.25 && slider.value == 0.25);
  CHECK(segments.numberOfSegments == 2 && segments.selectedSegmentIndex == 0);
  CHECK([[segments titleForSegmentAtIndex:1] isEqual:@"Welcome"]);
  stepper.value = 100; CHECK(stepper.value == 32 && owner->events == 0);
  stepper.value = -5; CHECK(stepper.value == 16);
  BOOL caught = NO; @try { stepper.stepValue = 0; } @catch (NSException *e) { caught = YES; } CHECK(caught);
  NSStepper *native = [[stepper _nativeView].subviews objectAtIndex:0];
  [native setDoubleValue:22]; [native sendAction:native.action to:native.target];
  CHECK(stepper.value == 22 && owner->events == 1);
  stepper.enabled = NO; CHECK(![native isEnabled]);
  [progress setProgress:2 animated:YES]; CHECK(progress.progress == 1);
  progress.progress = -1; CHECK(progress.progress == 0);
  CHECK([UIFont preferredFontForTextStyle:UIFontTextStyleTitle1].pointSize == 28);
  UILabel *label = [owner->outlets objectForKey:@"greetingLabel"];
  label.adjustsFontForContentSizeCategory = YES; CHECK(label.adjustsFontForContentSizeCategory);
  label.accessibilityIdentifier = @"greeting"; CHECK([label.accessibilityIdentifier isEqual:@"greeting"]);
  [root layoutIfNeeded];
  CHECK(fabs(stack.frame.origin.x-24) < 0.001 && stack.frame.size.height > 400);
  CHECK(fabs(table.frame.size.height-176) < 0.001);
  CHECK(fabs(scroll.contentSize.height-(NSMaxY(stack.frame)+24)) < 0.001);
  root.frame = CGRectMake(0,0,600,400); [root layoutIfNeeded];
  CHECK(fabs(stack.frame.size.width-552) < 0.001);
  CHECK(fabs(scroll.frameLayoutGuide.layoutFrame.size.width-600) < 0.001);
  scroll.contentOffset = CGPointMake(0,50); [root layoutIfNeeded];
  CHECK(fabs(scroll.contentLayoutGuide.layoutFrame.origin.y) < 0.001);
  CHECK(fabs(scroll.frameLayoutGuide.layoutFrame.origin.y-50) < 0.001);
  CHECK(fabs(stack.frame.origin.y-32) < 0.001);
  scroll.contentOffset = CGPointZero; [root layoutIfNeeded];
  CGFloat previousHeight = stack.frame.size.height;
  progress.hidden = YES; [root layoutIfNeeded];
  CHECK(stack.frame.size.height < previousHeight);
  progress.hidden = NO; [root layoutIfNeeded];
  CHECK(fabs(stack.frame.size.height-previousHeight) < 0.001);
  [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"row"];
  [table reloadData];
  NSIndexPath *last = [NSIndexPath indexPathForRow:11 inSection:0];
  [table scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:NO];
  CHECK(table.indexPathForSelectedRow == nil && table.contentOffset.y > 0);
  [table selectRowAtIndexPath:last animated:NO scrollPosition:0];
  owner->rows--;
  [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
  CHECK([table numberOfRowsInSection:0] == 11 && table.indexPathForSelectedRow.row == 10);
  UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0,0,10,25)] autorelease];
  table.tableFooterView = footer; [table layoutIfNeeded];
  CHECK(footer.superview == table && fabs(table.contentSize.height-(11*44+25)) < 0.001);
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:owner];
  CHECK(owner.navigationController == nav);
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Test" message:@"Message" preferredStyle:UIAlertControllerStyleAlert];
#if __has_feature(blocks)
  __block NSInteger callbacks = 0;
  [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { callbacks++; }]];
  [owner presentViewController:alert animated:NO completion:^{ callbacks++; }];
  CHECK(callbacks == 1);
#else
  [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL]];
  [owner presentViewController:alert animated:NO completion:NULL];
#endif
  CHECK(owner.presentedViewController == alert && alert.presentingViewController == owner);
  for (UIView *view in alert.view.subviews)
    if ([view isKindOfClass:[UIButton class]]) [(UIButton *)view sendActionsForControlEvents:UIControlEventTouchUpInside];
  CHECK(owner.presentedViewController == nil && alert.presentingViewController == nil);
#if __has_feature(blocks)
  CHECK(callbacks == 2);
#endif
  [owner presentViewController:alert animated:NO completion:NULL];
  [alert.view.window close];
  CHECK(owner.presentedViewController == nil && alert.presentingViewController == nil);
  [nav release]; [owner release];
  fprintf(stderr,"PASS: playground controls, XIB, scroll/stack layout, table updates and alerts\n");
}
