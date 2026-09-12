#import <UIKit/UIKit.h>

/* A small, runnable application exercising the desktop core without AppKit
   widgets in its screens. Window creation remains a GNUstep backend extension. */
@interface FormController : UIViewController
{
  UITextField *_name;
  UITextField *_password;
  UILabel *_status;
}
@end
@implementation FormController
- (void)viewDidLoad
{
  [self setTitle:@"Edit contact"];
  UIView *view = [self view];
  [view setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1]];
  UILabel *heading = [[[UILabel alloc] initWithFrame:CGRectMake(20,20,300,30)] autorelease];
  [heading setText:@"Contact details"]; [heading setFont:[UIFont boldSystemFontOfSize:20]];
  [view addSubview:heading];
  _name = [[[UITextField alloc] initWithFrame:CGRectMake(20,65,280,30)] autorelease];
  [_name setPlaceholder:@"Name"]; [_name setText:@"Ada Lovelace"]; [view addSubview:_name];
  _password = [[[UITextField alloc] initWithFrame:CGRectMake(20,110,280,30)] autorelease];
  [_password setText:@"password"]; [_password setSecureTextEntry:YES]; [view addSubview:_password];
  UIButton *save = [UIButton buttonWithType:0]; [save setFrame:CGRectMake(20,155,100,32)];
  [save setTitle:@"Save" forState:UIControlStateNormal];
  [save addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside]; [view addSubview:save];
  _status = [[[UILabel alloc] initWithFrame:CGRectMake(20,205,340,60)] autorelease];
  [_status setNumberOfLines:0]; [_status setText:@"The password field uses secure native input."];
  [view addSubview:_status];
}
- (void)save:(id)sender { [_status setText:[NSString stringWithFormat:@"Saved %@", [_name text]]]; }
@end

@interface DirectoryController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@end
@implementation DirectoryController
- (id)init { self = [super init]; if (self) [self setTitle:@"Directory"]; return self; }
- (void)loadView
{
  UITableView *table = [[[UITableView alloc] initWithFrame:CGRectMake(0,0,420,500)] autorelease];
  [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"contact"];
  [table setDataSource:self]; [table setDelegate:self]; [self setView:table]; [table reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(id)table { return 2; }
- (NSInteger)tableView:(id)table numberOfRowsInSection:(NSInteger)section { return 10000; }
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path
{
  UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"contact" forIndexPath:path];
  [[cell textLabel] setText:[NSString stringWithFormat:@"Team %ld · Contact %ld", (long)[path section]+1, (long)[path row]+1]];
  return cell;
}
- (void)tableView:(id)table didSelectRowAtIndexPath:(NSIndexPath *)path
{
  FormController *form = [[[FormController alloc] init] autorelease];
  [form setTitle:@"Edit contact"];
  [(UINavigationController *)[self parentViewController] pushViewController:form animated:NO];
}
@end

@interface GalleryController : UIViewController <UICollectionViewDataSource>
@end
@implementation GalleryController
- (id)init { self = [super init]; if (self) [self setTitle:@"Gallery"]; return self; }
- (void)loadView
{
  UICollectionViewFlowLayout *layout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
  [layout setItemSize:CGSizeMake(80,80)];
  UICollectionView *collection = [[[UICollectionView alloc] initWithFrame:CGRectMake(0,0,420,500) collectionViewLayout:layout] autorelease];
  [collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"tile"];
  [collection setDataSource:self]; [self setView:collection]; [collection reloadData];
}
- (NSInteger)numberOfSectionsInCollectionView:(id)collection { return 2; }
- (NSInteger)collectionView:(id)collection numberOfItemsInSection:(NSInteger)section { return 10000; }
- (UICollectionViewCell *)collectionView:(UICollectionView *)collection cellForItemAtIndexPath:(NSIndexPath *)path
{
  UICollectionViewCell *cell = [collection dequeueReusableCellWithReuseIdentifier:@"tile" forIndexPath:path];
  [[cell contentView] setBackgroundColor:[UIColor colorWithRed:0.2 green:0.3 + ([path item] % 5) * 0.12 blue:0.65 alpha:1]];
  return cell;
}
@end

@interface CanvasController : UIViewController { UIView *_tile; UILabel *_status; }
@end
@implementation CanvasController
- (id)init { self = [super init]; if (self) [self setTitle:@"Canvas"]; return self; }
- (void)viewDidLoad
{
  [[self view] setBackgroundColor:[UIColor whiteColor]];
  _status = [[[UILabel alloc] initWithFrame:CGRectMake(20,20,320,30)] autorelease];
  [_status setText:@"Drag the square. Tap to change its color."]; [[self view] addSubview:_status];
  _tile = [[[UIView alloc] initWithFrame:CGRectMake(90,100,100,100)] autorelease];
  [_tile setBackgroundColor:[UIColor colorWithRed:0.2 green:0.5 blue:0.8 alpha:1]];
  [[self view] addSubview:_tile];
  [_tile addGestureRecognizer:[[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)] autorelease]];
  [_tile addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease]];
}
- (void)pan:(UIPanGestureRecognizer *)gesture
{
  CGPoint delta = [gesture translationInView:[self view]], center = [_tile center];
  [_tile setCenter:CGPointMake(center.x + delta.x, center.y + delta.y)];
  [gesture setTranslation:CGPointZero inView:[self view]];
}
- (void)tap:(UITapGestureRecognizer *)gesture { [_tile setBackgroundColor:[UIColor colorWithRed:0.8 green:0.35 blue:0.2 alpha:1]]; }
@end

@interface CatalogDelegate : NSObject <UIApplicationDelegate>
{
  UIWindow *_window;
  UITabBarController *_tabs;
  UINavigationController *_navigation;
  DirectoryController *_directory;
}
@end
@implementation CatalogDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
  _window = [[UIWindow alloc] initWithFrame:CGRectMake(40,40,480,600)];
  [_window setTitle:@"GNUstep UIKit Core Catalog"];
  _directory = [[DirectoryController alloc] init];
  _navigation = [[UINavigationController alloc] initWithRootViewController:_directory]; [_navigation setTitle:@"Directory"];
  _tabs = [[UITabBarController alloc] init];
  [_tabs setViewControllers:[NSArray arrayWithObjects:_navigation, [[[GalleryController alloc] init] autorelease], [[[CanvasController alloc] init] autorelease], nil]];
  [_window setRootViewController:_tabs]; [_window makeKeyAndVisible];
  if ([[[NSProcessInfo processInfo] arguments] containsObject:@"--smoke"])
    [self performSelector:@selector(smoke) withObject:nil afterDelay:0.1];
}
- (void)snapshot:(NSString *)name
{
  NSString *directory = [[[NSProcessInfo processInfo] environment] objectForKey:@"UIKIT_SCREENSHOT_DIR"];
  if (!directory) return;
  [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
  NSView *view = [_window contentView];
  [(UIView *)view layoutIfNeeded]; [_window display];
  NSBitmapImageRep *bitmap = [view bitmapImageRepForCachingDisplayInRect:[view bounds]];
  [view cacheDisplayInRect:[view bounds] toBitmapImageRep:bitmap];
  [[bitmap representationUsingType:NSPNGFileType properties:[NSDictionary dictionary]] writeToFile:[directory stringByAppendingPathComponent:[name stringByAppendingString:@".png"]] atomically:YES];
}
- (void)smoke
{
  @try {
    [self snapshot:@"directory"];
    [_directory tableView:[_directory view] didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [(FormController *)[_navigation topViewController] save:nil]; [self snapshot:@"form"];
    [_navigation popViewControllerAnimated:NO];
    [_tabs setSelectedIndex:1]; [self snapshot:@"gallery"];
    [_tabs setSelectedIndex:2]; [self snapshot:@"canvas"];
    NSLog(@"PASS: catalog directory, form, gallery and canvas smoke");
    [_window close]; [NSApp terminate:nil];
  } @catch (NSException *exception) { NSLog(@"FAIL: catalog %@", exception); exit(1); }
}
- (void)dealloc { [_window release]; [_tabs release]; [_navigation release]; [_directory release]; [super dealloc]; }
@end
int main(int argc, char **argv) { return UIApplicationMain(argc, argv, nil, @"CatalogDelegate"); }
