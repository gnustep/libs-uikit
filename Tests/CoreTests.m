#import "../Source/UIKitPrivate.h"
#include <stdio.h>

extern void UIKitRunPublicContract(void);
static int checks;
#define CHECK(condition) do { checks++; if (!(condition)) { fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #condition); exit(1); } } while (0)

@interface ProbeController : UIViewController { @public NSMutableArray *events; }
@end
@implementation ProbeController
- (id)init { self = [super init]; if (self) events = [NSMutableArray new]; return self; }
- (void)dealloc { [events release]; [super dealloc]; }
- (void)viewDidLoad { [events addObject:@"load"]; }
- (void)viewWillAppear:(BOOL)animated { [events addObject:@"willAppear"]; }
- (void)viewDidAppear:(BOOL)animated { [events addObject:@"didAppear"]; }
- (void)viewWillDisappear:(BOOL)animated { [events addObject:@"willDisappear"]; }
- (void)viewDidDisappear:(BOOL)animated { [events addObject:@"didDisappear"]; }
@end

@interface Target : NSObject { @public NSUInteger calls; id sender; }
- (void)zero;
- (void)one:(id)value;
- (void)two:(id)value event:(id)event;
- (void)removeSelf:(UIControl *)control;
@end
@implementation Target
- (void)zero { calls++; }
- (void)one:(id)value { calls++; sender = value; }
- (void)two:(id)value event:(id)event { calls++; sender = value; CHECK(event == nil); }
- (void)removeSelf:(UIControl *)control { calls++; [control removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents]; }
@end

@interface DataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource, UITableViewDelegate, UICollectionViewDelegate>
{ @public NSInteger requested, selections, rows; }
@end
@implementation DataSource
- (id)init { self = [super init]; if (self) rows = 10000; return self; }
- (NSInteger)numberOfSectionsInTableView:(id)view { return 3; }
- (NSInteger)tableView:(id)view numberOfRowsInSection:(NSInteger)section { return section == 1 ? 0 : rows; }
- (UITableViewCell *)tableView:(UITableView *)view cellForRowAtIndexPath:(NSIndexPath *)path
{
  requested++;
  UITableViewCell *cell = [view dequeueReusableCellWithIdentifier:@"row" forIndexPath:path];
  [[cell textLabel] setText:[NSString stringWithFormat:@"%ld:%ld", (long)[path section], (long)[path row]]];
  return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(id)view { return 3; }
- (NSInteger)collectionView:(id)view numberOfItemsInSection:(NSInteger)section { return section == 1 ? 0 : rows; }
- (UICollectionViewCell *)collectionView:(UICollectionView *)view cellForItemAtIndexPath:(NSIndexPath *)path
{ requested++; return [view dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:path]; }
- (void)tableView:(id)view didSelectRowAtIndexPath:(NSIndexPath *)path { selections++; }
- (void)collectionView:(id)view didSelectItemAtIndexPath:(NSIndexPath *)path { selections++; }
@end

@interface LayoutProbe : UIView { @public int layouts; }
@end
@implementation LayoutProbe
- (void)layoutSubviews { layouts++; }
@end

@interface NibController : UIViewController { @public UIButton *button; NSUInteger loaded, saves; }
- (void)setButton:(UIButton *)value;
- (void)save:(id)sender;
@end
@implementation NibController
- (void)setButton:(UIButton *)value { button = value; }
- (void)viewDidLoad { loaded++; CHECK(button != nil); }
- (void)save:(id)sender { saves++; }
@end

@interface TouchProbe : UIView { @public UITouch *began; NSUInteger moved, ended, cancelled; CGPoint previous; }
@end
@implementation TouchProbe
- (BOOL)canBecomeFirstResponder { return YES; }
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { began = [touches anyObject]; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { CHECK([touches anyObject] == began); moved++; previous = [began previousLocationInView:nil]; }
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { CHECK([touches anyObject] == began); ended++; }
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event { cancelled++; }
@end

@interface SceneProbe : NSObject <UISceneDelegate> { @public NSMutableArray *events; }
@end
@implementation SceneProbe
- (id)init { self = [super init]; if (self) events = [NSMutableArray new]; return self; }
- (void)dealloc { [events release]; [super dealloc]; }
- (void)sceneWillEnterForeground:(UIScene *)scene { [events addObject:@"foreground"]; }
- (void)sceneDidBecomeActive:(UIScene *)scene { [events addObject:@"active"]; }
- (void)sceneWillResignActive:(UIScene *)scene { [events addObject:@"resign"]; }
- (void)sceneDidEnterBackground:(UIScene *)scene { [events addObject:@"background"]; }
- (void)sceneDidDisconnect:(UIScene *)scene { [events addObject:@"disconnect"]; }
@end

static NSEvent *mouseEvent(NSEventType type, CGPoint point, UIWindow *window, NSTimeInterval time)
{
  return [NSEvent mouseEventWithType:type location:point modifierFlags:0 timestamp:time
    windowNumber:[[window _nativeWindow] windowNumber] context:nil eventNumber:1 clickCount:1 pressure:1];
}
static void testInput(void)
{
  UIWindow *window = [[[UIWindow alloc] initWithFrame:CGRectMake(0,0,320,240)] autorelease];
  TouchProbe *view = [[[TouchProbe alloc] initWithFrame:CGRectMake(0,0,320,240)] autorelease];
  [window addSubview:view]; [window makeKeyAndVisible];
  CHECK([view becomeFirstResponder]); CHECK([window _firstResponder] == view);
  CHECK([view resignFirstResponder]); CHECK([window _firstResponder] != view);
  UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(0,0,100,30)] autorelease];
  [view addSubview:field];
  CHECK([[window _nativeWindow] makeFirstResponder:[field _nativeResponder]]);
  CHECK([field isFirstResponder]);
  CHECK([field resignFirstResponder]);
  [field removeFromSuperview];
  [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [[window _nativeWindow] setContentSize:NSMakeSize(400,300)];
  CHECK([window bounds].size.width == 400 && [view frame].size.width == 400);
  [[window _nativeWindow] setContentSize:NSMakeSize(320,240)];
  [view mouseDown:mouseEvent(NSLeftMouseDown, CGPointMake(20,20), window, 1)];
  [view mouseDragged:mouseEvent(NSLeftMouseDragged, CGPointMake(30,20), window, 2)];
  [view mouseUp:mouseEvent(NSLeftMouseUp, CGPointMake(30,20), window, 3)];
  CHECK(view->moved == 1 && view->ended == 1); CHECK(view->previous.x == 20);
  Target *target = [[[Target alloc] init] autorelease];
  UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(one:)] autorelease];
  [view addGestureRecognizer:tap];
  [view mouseDown:mouseEvent(NSLeftMouseDown, CGPointMake(20,20), window, 4)];
  [view mouseUp:mouseEvent(NSLeftMouseUp, CGPointMake(20,20), window, 5)];
  CHECK(target->calls == 1); CHECK([tap state] == UIGestureRecognizerStateRecognized); CHECK(view->cancelled == 1);
  [view removeGestureRecognizer:tap]; CHECK([tap view] == nil);
  UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(one:)] autorelease];
  [view addGestureRecognizer:pan];
  [view mouseDown:mouseEvent(NSLeftMouseDown, CGPointMake(20,20), window, 6)];
  [view mouseDragged:mouseEvent(NSLeftMouseDragged, CGPointMake(40,20), window, 7)];
  CHECK([pan state] == UIGestureRecognizerStateBegan); CHECK([pan translationInView:nil].x == 20);
  [view mouseUp:mouseEvent(NSLeftMouseUp, CGPointMake(40,20), window, 8)];
  CHECK([pan state] == UIGestureRecognizerStateEnded); CHECK(target->calls == 3);
  [view setUserInteractionEnabled:NO]; CHECK([view hitTest:CGPointMake(10,10) withEvent:nil] == nil);
  [window close]; CHECK(![[[UIApplication sharedApplication] windows] containsObject:window]); CHECK([window windowScene] == nil);
}
static void testResourcesAndScenes(void)
{
  NSString *path = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"Tests/Fixtures.bundle"];
  NSBundle *bundle = [NSBundle bundleWithPath:path]; CHECK(bundle != nil);
  NibController *controller = [[[NibController alloc] initWithNibName:@"Form" bundle:bundle] autorelease];
  CHECK(![controller isViewLoaded]); [controller loadViewIfNeeded]; [controller loadViewIfNeeded];
  NibController *bundleOwner = [[[NibController alloc] init] autorelease];
  NSArray *loaded = [bundle loadNibNamed:@"Form" owner:bundleOwner options:nil];
  CHECK([loaded isKindOfClass:[NSArray class]] && [loaded count] > 0);
  CHECK(bundleOwner->button != nil);
  CHECK(controller->loaded == 1); CHECK([controller->button isDescendantOfView:[controller view]]);
  [controller->button sendActionsForControlEvents:UIControlEventValueChanged]; CHECK(controller->saves == 0);
  [controller->button sendActionsForControlEvents:UIControlEventTouchUpInside]; CHECK(controller->saves == 1);
  UISceneConfiguration *configuration = [UISceneConfiguration configurationWithName:@"Test" sessionRole:UISceneSessionRoleApplication];
  UISceneSession *session = [[[UISceneSession alloc] initWithRole:UISceneSessionRoleApplication configuration:configuration] autorelease];
  UIScene *scene = [[[UIScene alloc] initWithSession:session] autorelease];
  SceneProbe *probe = [[[SceneProbe alloc] init] autorelease]; [scene setDelegate:probe];
  [scene setActivationState:UISceneActivationStateForegroundActive];
  [scene setActivationState:UISceneActivationStateForegroundActive];
  [scene setActivationState:UISceneActivationStateBackground];
  [scene setActivationState:UISceneActivationStateUnattached];
  CHECK([[probe->events componentsJoinedByString:@","] isEqual:@"foreground,active,resign,background,disconnect"]);
}

static void testViews(void)
{
  LayoutProbe *parent = [[[LayoutProbe alloc] initWithFrame:CGRectMake(0,0,200,200)] autorelease];
  LayoutProbe *child = [[[LayoutProbe alloc] initWithFrame:CGRectMake(10,20,50,50)] autorelease];
  [parent addSubview:child]; [child setNeedsLayout]; [parent layoutIfNeeded];
  CHECK([[parent _nativeView] isFlipped]); CHECK(child->layouts > 0);
  int layouts = child->layouts; [parent layoutIfNeeded]; CHECK(child->layouts == layouts);
  [child setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
  [parent setFrame:CGRectMake(0,0,200,300)];
  CHECK([child frame].origin.y == 120);
  UIScrollView *scroll = [[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,200,200)] autorelease];
  UIView *content = [[[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)] autorelease];
  [scroll addSubview:content];
  CHECK([[scroll subviews] containsObject:content]);
  CHECK([content isDescendantOfView:scroll]);
  [scroll setContentSize:CGSizeMake(200,2000)]; [scroll setContentOffset:CGPointMake(0,500)];
  CHECK([scroll contentOffset].y == 500);
  [scroll setContentOffset:CGPointMake(-50,100000)];
  CHECK([scroll contentOffset].x == 0); CHECK([scroll contentOffset].y < 2000);
}

static void testControls(void)
{
  UIControl *control = [[[UIControl alloc] init] autorelease];
  Target *target = [[[Target alloc] init] autorelease];
  [control addTarget:target action:@selector(zero) forControlEvents:UIControlEventValueChanged];
  [control addTarget:target action:@selector(one:) forControlEvents:UIControlEventValueChanged | UIControlEventTouchUpInside];
  [control addTarget:target action:@selector(two:event:) forControlEvents:UIControlEventValueChanged];
  [control sendActionsForControlEvents:UIControlEventValueChanged]; CHECK(target->calls == 3); CHECK(target->sender == control);
  [control removeTarget:target action:@selector(one:) forControlEvents:UIControlEventValueChanged];
  [control sendActionsForControlEvents:UIControlEventTouchUpInside]; CHECK(target->calls == 4);
  [control removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
  [control addTarget:target action:@selector(removeSelf:) forControlEvents:UIControlEventValueChanged];
  [control sendActionsForControlEvents:UIControlEventValueChanged]; CHECK(target->calls == 5);
  [control sendActionsForControlEvents:UIControlEventValueChanged]; CHECK(target->calls == 5);
  UIButton *button = [UIButton buttonWithType:0];
  [button setTitle:@"Normal" forState:UIControlStateNormal]; [button setTitle:@"Disabled" forState:UIControlStateDisabled];
  CHECK([[button titleForState:UIControlStateNormal] isEqual:@"Normal"]);
  [button setEnabled:NO]; CHECK([[[[[button _nativeView] subviews] firstObject] title] isEqual:@"Disabled"]);
  [button setEnabled:YES]; CHECK([[[[[button _nativeView] subviews] firstObject] title] isEqual:@"Normal"]);
  UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(0,0,100,30)] autorelease];
  [field setText:@"secret"]; [field setSecureTextEntry:YES];
  CHECK([[[[field _nativeView] subviews] firstObject] isKindOfClass:[NSSecureTextField class]]);
  CHECK([[field text] isEqual:@"secret"]);
  [field setSecureTextEntry:NO]; CHECK(![[[[field _nativeView] subviews] firstObject] isKindOfClass:[NSSecureTextField class]]);
  CHECK([[field text] isEqual:@"secret"]);
  [field addTarget:target action:@selector(one:) forControlEvents:UIControlEventEditingChanged];
  NSUInteger before = target->calls;
  [field setText:@"programmatic"]; CHECK(target->calls == before);
  [[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidChangeNotification object:[[[field _nativeView] subviews] firstObject]];
  CHECK(target->calls == before + 1);
}

static void testControllers(void)
{
  ProbeController *root = [[[ProbeController alloc] init] autorelease];
  ProbeController *detail = [[[ProbeController alloc] init] autorelease];
  UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:root] autorelease];
  CHECK(![root isViewLoaded]); CHECK([root parentViewController] == nav);
  UIWindow *window = [[[UIWindow alloc] initWithFrame:CGRectMake(0,0,320,480)] autorelease];
  [window setRootViewController:nav]; CHECK([root isViewLoaded]); CHECK([root->events count] == 1);
  [window makeKeyAndVisible]; CHECK([[root->events lastObject] isEqual:@"didAppear"]);
  UIView *host = [nav view];
  [nav pushViewController:detail animated:NO]; CHECK([nav view] == host);
  CHECK([[window subviews] containsObject:host]); CHECK([[detail view] isDescendantOfView:host]);
  CHECK(![[root view] isDescendantOfView:host]); CHECK([detail parentViewController] == nav);
  CHECK([[root->events lastObject] isEqual:@"didDisappear"]);
  CHECK([[detail->events componentsJoinedByString:@","] isEqual:@"load,willAppear,didAppear"]);
  CHECK([nav popViewControllerAnimated:NO] == detail); CHECK([detail parentViewController] == nil);
  CHECK([[root view] isDescendantOfView:host]); CHECK([[detail->events lastObject] isEqual:@"didDisappear"]);
  UITabBarController *tabs = [[[UITabBarController alloc] init] autorelease];
  ProbeController *other = [[[ProbeController alloc] init] autorelease];
  [tabs setViewControllers:[NSArray arrayWithObjects:detail,other,nil]];
  [window setRootViewController:tabs]; [tabs setSelectedIndex:1];
  CHECK([tabs selectedViewController] == other); CHECK([[other view] isDescendantOfView:[tabs view]]);
  CHECK(![[detail view] isDescendantOfView:[tabs view]]);
  [tabs setViewControllers:[NSArray array]]; CHECK([tabs selectedViewController] == nil);
  CHECK([other parentViewController] == nil); CHECK([[tabs childViewControllers] count] == 0);
  [window close];
}

static void testLists(void)
{
  UITableViewCell *colored = [[[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:@"color"] autorelease];
  UIColor *color = [UIColor redColor]; [colored setBackgroundColor:color];
  [colored setSelected:YES]; [colored setSelected:NO];
  CHECK([colored backgroundColor] == color);

  DataSource *source = [[[DataSource alloc] init] autorelease];
  UITableView *table = [[[UITableView alloc] initWithFrame:CGRectMake(0,0,320,240)] autorelease];
  [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"row"];
  [table setDataSource:source]; [table setDelegate:source]; [table reloadData];
  CHECK([table numberOfSections] == 3); CHECK([table numberOfRowsInSection:1] == 0);
  CHECK(source->requested > 0 && source->requested < 20);
  CHECK([[table visibleCells] count] < 20);
  NSIndexPath *last = [NSIndexPath indexPathForRow:9999 inSection:2];
  [table selectRowAtIndexPath:last animated:NO scrollPosition:3];
  CHECK([table cellForRowAtIndexPath:last] != nil);
  CHECK([[table indexPathForCell:[table cellForRowAtIndexPath:last]] isEqual:last]);
  CHECK(source->selections == 0);
  CHECK([table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] == nil);
  CHECK([[table visibleCells] count] < 20);
  UIWindow *window = [[[UIWindow alloc] initWithFrame:CGRectMake(0,0,320,240)] autorelease];
  [window addSubview:table]; [window makeKeyAndVisible];
  [table setContentOffset:CGPointZero];
  UITableViewCell *first = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  CGPoint click = [[first _nativeView] convertPoint:CGPointMake(20,20) toView:nil];
  [[window _nativeWindow] sendEvent:mouseEvent(NSLeftMouseDown, click, window, 1)];
  [[window _nativeWindow] sendEvent:mouseEvent(NSLeftMouseUp, click, window, 2)];
  CHECK(source->selections == 1);
  CHECK([[table indexPathForSelectedRow] isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]);
  [window close];
  [table selectRowAtIndexPath:last animated:NO scrollPosition:0];
  source->selections = 0;
  source->rows = 1; [table reloadData]; CHECK([table indexPathForSelectedRow] == nil);
  CHECK([table contentOffset].y == 0); CHECK([[table visibleCells] count] == 2);
  source->rows = 10000; source->requested = 0;
  UICollectionView *collection = [[[UICollectionView alloc] initWithFrame:CGRectMake(0,0,320,240)] autorelease];
  [collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"item"];
  [collection setDataSource:source]; [collection setDelegate:source]; [collection reloadData];
  CHECK(source->requested > 0 && source->requested < 50);
  [collection selectItemAtIndexPath:last animated:NO scrollPosition:4];
  UICollectionViewCell *cell = [collection cellForItemAtIndexPath:last]; CHECK(cell != nil);
  CHECK([[collection indexPathForCell:cell] isEqual:last]); CHECK(source->selections == 0);
  CHECK([[collection visibleCells] count] < 50);
  source->rows = 0; [collection reloadData]; CHECK([[collection visibleCells] count] == 0);
  CHECK([[collection indexPathsForSelectedItems] count] == 0);
}

extern void testUIKitLayout(void);
extern void testUIKitEditingAndControllers(void);

int main(void)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  [NSApplication sharedApplication];
  @try {
    UIKitRunPublicContract();
    testUIKitLayout();
    testUIKitEditingAndControllers();
    fprintf(stderr, "Views\n"); testViews(); fprintf(stderr, "Controls\n"); testControls();
    fprintf(stderr, "Controllers\n"); testControllers(); fprintf(stderr, "Lists\n"); testLists();
    fprintf(stderr, "Input\n"); testInput(); fprintf(stderr, "Resources and scenes\n"); testResourcesAndScenes();
  } @catch (NSException *exception) { fprintf(stderr, "EXCEPTION: %s\n", [[exception description] UTF8String]); return 1; }
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
  printf("PASS: %d UIKit core checks\n", checks);
  [pool drain]; return 0;
}
