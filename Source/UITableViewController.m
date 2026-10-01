#import "UIKitPrivate.h"

@implementation UITableViewController
- (id)initWithStyle:(UITableViewStyle)style
{
  if ((self = [self initWithNibName:nil bundle:nil])) _tableViewStyle = style;
  return self;
}
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
  if ((self = [super initWithNibName:name bundle:bundle])) _clearsSelectionOnViewWillAppear = YES;
  return self;
}
- (void)dealloc
{
  if ([(UITableView *)_view dataSource] == self) [(UITableView *)_view setDataSource:nil];
  if ([(UITableView *)_view delegate] == self) [(UITableView *)_view setDelegate:nil];
  [super dealloc];
}
- (void)loadView
{
  if (_nibName) [super loadView];
  else [self setTableView:[[[UITableView alloc] initWithFrame:CGRectMake(0,0,320,480) style:_tableViewStyle] autorelease]];
}
- (void)setView:(UIView *)view
{
  if (view && ![view isKindOfClass:[UITableView class]])
    [NSException raise:NSInvalidArgumentException format:@"UITableViewController requires a UITableView root"];
  if (_view == view) return;
  if ([(UITableView *)_view dataSource] == self) [(UITableView *)_view setDataSource:nil];
  if ([(UITableView *)_view delegate] == self) [(UITableView *)_view setDelegate:nil];
  [super setView:view];
  [(UITableView *)view setDataSource:self]; [(UITableView *)view setDelegate:self];
}
- (UITableView *)tableView { return (UITableView *)[self view]; }
- (void)setTableView:(UITableView *)view { [self setView:view]; }
- (BOOL)clearsSelectionOnViewWillAppear { return _clearsSelectionOnViewWillAppear; }
- (void)setClearsSelectionOnViewWillAppear:(BOOL)value { _clearsSelectionOnViewWillAppear = value; }
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated]; [[self tableView] reloadData];
  if (_clearsSelectionOnViewWillAppear)
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:animated];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 0; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)path
{
  [NSException raise:NSInternalInconsistencyException format:@"Override tableView:cellForRowAtIndexPath: in your controller"];
  return nil;
}
@end
