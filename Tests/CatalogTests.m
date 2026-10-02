#import <UIKit/GNUstepUIKit.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#define CHECK(c) do { if (!(c)) { fprintf(stderr,"FAIL catalog %d: %s\n",__LINE__,#c); abort(); } } while (0)

@interface CatalogProbe : NSObject <UITableViewDataSource, UISearchResultsUpdating, UIPickerViewDataSource, UIPickerViewDelegate, UITabBarDelegate>
{ @public NSInteger actions, searches, selections; NSString *query; }
@end
@implementation CatalogProbe
- (void)dealloc { [query release]; [super dealloc]; }
- (void)action:(id)sender { actions++; }
- (void)updateSearchResultsForSearchController:(UISearchController *)controller { searches++; [query release]; query = [controller.searchBar.text copy]; }
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { return 4; }
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
  UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"catalog"];
  if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"catalog"] autorelease];
  cell.textLabel.text = @"A catalog entry whose title needs to wrap on narrow screens"; cell.textLabel.numberOfLines = 0;
  cell.detailTextLabel.text = @"An explanatory subtitle that must remain below the title"; cell.detailTextLabel.numberOfLines = 0;
  cell.imageView.image = [UIImage systemImageNamed:@"doc.text"]; return cell;
}
- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section { return @"Objects"; }
- (NSString *)tableView:(UITableView *)table titleForFooterInSection:(NSInteger)section { return @"End of catalog"; }
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)picker { return 2; }
- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component { return 3; }
- (NSString *)pickerView:(UIPickerView *)picker titleForRow:(NSInteger)row forComponent:(NSInteger)component { return @"Repeated title"; }
- (void)pickerView:(UIPickerView *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component { selections++; }
- (void)tabBar:(UITabBar *)bar didSelectItem:(UITabBarItem *)item { selections++; }
@end

void testUIKitCatalog(void) {
  CatalogProbe *probe = [[[CatalogProbe alloc] init] autorelease];
  UIViewController *root = [[[UIViewController alloc] init] autorelease]; root.title = @"Catalog";
  UISearchController *search = [[[UISearchController alloc] initWithSearchResultsController:nil] autorelease];
  search.searchResultsUpdater = probe; root.navigationItem.searchController = search;
  root.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Widgets" style:0 target:probe action:@selector(action:)] autorelease];
  UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:root] autorelease];
  UIWindow *window = [[[UIWindow alloc] initWithFrame:CGRectMake(20,20,500,600)] autorelease];
  window.rootViewController = nav; [window makeKeyAndVisible]; [window layoutIfNeeded];
  CHECK(root.view.frame.size.height == 516);
  UINavigationBar *bar = nil;
  for (UIView *view in nav.view.subviews) if ([view isKindOfClass:[UINavigationBar class]]) bar = (UINavigationBar *)view;
  CHECK(bar != nil && search.searchBar.superview == bar);
  NSArray *before = [[bar.subviews copy] autorelease];
  [bar setNeedsLayout]; [bar layoutIfNeeded];
  CHECK([before isEqualToArray:bar.subviews]);
  [[window _nativeWindow] display]; // Layout during drawing must not detach the focused native view.
  for (UIView *view in bar.subviews) if ([view isKindOfClass:[UIButton class]]) [(UIButton *)view sendActionsForControlEvents:UIControlEventTouchUpInside];
  CHECK(probe->actions == 1);
  NSSearchField *nativeSearch = [[search.searchBar _nativeView].subviews firstObject];
  [nativeSearch setStringValue:@"picker"];
  [[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidChangeNotification object:nativeSearch];
  CHECK(probe->searches == 1 && [probe->query isEqual:@"picker"]);
  CHECK([[nativeSearch cell] sendsWholeSearchString]);
  [search.searchBar becomeFirstResponder];
  NSResponder *editor = [window _nativeWindow].firstResponder;
  [nativeSearch sendAction:nativeSearch.action to:nativeSearch.target];
  CHECK([window _nativeWindow].firstResponder == editor && probe->searches == 1);
  UIViewController *detail = [[[UIViewController alloc] init] autorelease]; [nav pushViewController:detail animated:NO];
  [window layoutIfNeeded]; [nav popViewControllerAnimated:NO]; [window layoutIfNeeded];
  CHECK(search.searchBar.superview == bar && [search.searchBar.text isEqual:@"picker"]);

  UITableView *table = [[[UITableView alloc] initWithFrame:CGRectMake(0,0,210,220) style:UITableViewStyleInsetGrouped] autorelease];
  table.rowHeight = UITableViewAutomaticDimension; table.dataSource = probe; [table layoutIfNeeded];
  CHECK(table.numberOfSections == 1 && table.visibleCells.count > 0);
  NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
  CGFloat narrowHeight = [table rectForRowAtIndexPath:first].size.height;
  UITableViewCell *cell = [table cellForRowAtIndexPath:first]; [cell layoutIfNeeded];
  CHECK(cell.detailTextLabel.frame.origin.y >= NSMaxY(cell.textLabel.frame));
  CHECK([table rectForRowAtIndexPath:first].origin.y > 0);
  table.frame = CGRectMake(0,0,500,220); [table layoutIfNeeded];
  CHECK([table rectForRowAtIndexPath:first].size.height < narrowHeight);
  UIView *empty = [[[UIView alloc] init] autorelease]; table.backgroundView = empty; [table layoutIfNeeded];
  CHECK(NSEqualRects(empty.frame,table.visibleContentRect));

  UIPickerView *picker = [[[UIPickerView alloc] init] autorelease]; picker.dataSource = probe; picker.delegate = probe;
  CHECK(picker.numberOfComponents == 2 && [picker numberOfRowsInComponent:0] == 3);
  [picker selectRow:2 inComponent:1 animated:NO]; CHECK(probe->selections == 0 && [picker selectedRowInComponent:1] == 2);
  NSPopUpButton *nativePicker = [[picker _nativeView].subviews lastObject];
  [nativePicker selectItemAtIndex:1]; [nativePicker sendAction:nativePicker.action to:nativePicker.target];
  CHECK(probe->selections == 1 && [picker selectedRowInComponent:1] == 1);
  UIDatePicker *date = [[[UIDatePicker alloc] init] autorelease]; date.datePickerMode = UIDatePickerModeDate;
  [date addTarget:probe action:@selector(action:) forControlEvents:UIControlEventValueChanged];
  NSDatePicker *nativeDate = [[date _nativeView].subviews firstObject];
  NSDate *chosen = [NSDate dateWithTimeIntervalSince1970:1700000000]; date.date = chosen;
  CHECK([date.date isEqual:chosen]); [nativeDate sendAction:nativeDate.action to:nativeDate.target]; CHECK(probe->actions == 2);
  UICalendarView *calendar = [[[UICalendarView alloc] init] autorelease];
  calendar.selectionBehavior = [[[UICalendarSelectionSingleDate alloc] initWithDelegate:nil] autorelease];
  NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease]; components.year = 2026; components.month = 10; components.day = 2;
  calendar.selectionBehavior.selectedDate = components;
  CHECK(calendar.selectionBehavior.selectedDate.day == 2);
  UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge] autorelease];
  spinner.hidesWhenStopped = NO; CHECK(!spinner.isAnimating && ![spinner isHidden]);
  spinner.frame = CGRectMake(0,0,1000,60); [spinner layoutIfNeeded];
  NSView *nativeSpinner = [[spinner _nativeView].subviews firstObject];
  CHECK(nativeSpinner.frame.size.width == 32 && nativeSpinner.frame.size.height == 32);
  [spinner startAnimating]; CHECK(spinner.isAnimating); [spinner stopAnimating]; CHECK(!spinner.isAnimating && ![spinner isHidden]);

  UIPageViewController *pages = [[[UIPageViewController alloc] init] autorelease];
  UIViewController *one = [[[UIViewController alloc] init] autorelease], *two = [[[UIViewController alloc] init] autorelease];
  [pages setViewControllers:@[one] direction:0 animated:NO completion:NULL]; [pages loadViewIfNeeded];
  [pages setViewControllers:@[two] direction:0 animated:YES completion:NULL];
  CHECK(one.parentViewController == nil && two.parentViewController == pages && two.view.superview == pages.view);
  UISplitViewController *split = [[[UISplitViewController alloc] initWithStyle:UISplitViewControllerStyleDoubleColumn] autorelease];
  [split setViewController:one forColumn:UISplitViewControllerColumnPrimary];
  UIViewController *secondary = [[[UIViewController alloc] init] autorelease]; [split setViewController:secondary forColumn:UISplitViewControllerColumnSecondary];
  [split.view layoutIfNeeded]; CHECK(one.view.frame.size.width == 400 && secondary.view.frame.origin.x == 400);
  split.view.frame = CGRectMake(0,0,1000,600); [split.view layoutIfNeeded]; CHECK(secondary.view.frame.origin.x == 500);
  UIRefreshControl *refresh = [[[UIRefreshControl alloc] init] autorelease];
  [refresh addTarget:probe action:@selector(action:) forControlEvents:UIControlEventValueChanged]; [refresh beginRefreshing];
  CHECK(refresh.refreshing && probe->actions == 2); [refresh endRefreshing]; CHECK(!refresh.refreshing);
  [window close]; window.rootViewController = nil;
  fprintf(stderr,"PASS: catalog navigation, native actions, search, automatic rows, pickers and containers\n");
}
