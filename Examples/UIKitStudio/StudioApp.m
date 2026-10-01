#import "StudioApp.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

/* These application files are compiled unchanged for Apple UIKit and GNUstep.
   Use manual reference counting in both build targets. */
static UIColor *StudioColor(CGFloat r, CGFloat g, CGFloat b)
{ return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]; }
static UIColor *StudioInk(void) { return StudioColor(26,39,54); }
static UIColor *StudioMuted(void) { return StudioColor(96,111,125); }
static UIColor *StudioPaper(void) { return StudioColor(245,243,237); }
static UILabel *StudioLabel(UIView *parent, NSString *text, CGFloat size, BOOL bold)
{
  UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
  label.text = text; label.font = bold ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size];
  label.textColor = StudioInk(); label.backgroundColor = [UIColor clearColor];
  [parent addSubview:label]; return label;
}
static UIView *StudioBlock(UIView *parent, UIColor *color)
{
  UIView *view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
  view.backgroundColor = color; [parent addSubview:view]; return view;
}
static NSArray *StudioColorNames(void)
{ return [NSArray arrayWithObjects:@"Cobalt", @"Coral", @"Meadow", @"Plum", @"Ochre", @"Ocean", @"Rose", @"Slate", @"Lilac", @"Forest", @"Clay", @"Midnight", nil]; }
static UIColor *StudioPalette(NSUInteger index)
{
  const CGFloat colors[][3] = {{53,89,224},{230,101,75},{69,150,105},{131,84,145},
    {185,137,37},{30,139,161},{194,81,121},{94,117,145},{132,112,199},{41,111,90},{172,104,75},{36,54,88}};
  return StudioColor(colors[index%12][0],colors[index%12][1],colors[index%12][2]);
}

@interface StudioComposeView : UIScrollView <UITextFieldDelegate>
{
@public
  UILabel *heading, *subtitle, *metric, *nameLabel, *amountLabel, *hint, *result;
  UIView *card, *track, *fill, *divider;
  UITextField *name;
  UISlider *slider;
  UIButton *save;
  NSLayoutConstraint *fillWidth;
}
- (void)updatePreview:(id)sender;
- (void)saveNote:(id)sender;
- (void)useColor:(UIColor *)color;
@end
@implementation StudioComposeView
- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    heading = StudioLabel(self,@"Make it yours.",26,YES);
    subtitle = StudioLabel(self,@"A little input. An instant response.",14,NO); subtitle.textColor = StudioMuted();
    card = StudioBlock(self,[UIColor whiteColor]);
    StudioLabel(card,@"YOUR NEXT GOOD IDEA",11,YES).tag = 1;
    metric = StudioLabel(card,@"Hello, Ada.",30,YES);
    StudioLabel(card,@"Room to grow",12,NO).tag = 2;
    track = StudioBlock(card,StudioColor(232,236,245));
    fill = StudioBlock(track,StudioPalette(0)); fill.translatesAutoresizingMaskIntoConstraints = NO;
    fillWidth = [[fill.widthAnchor constraintEqualToConstant:100] retain];
    [NSLayoutConstraint activateConstraints:[NSArray arrayWithObjects:
      [fill.leftAnchor constraintEqualToAnchor:track.leftAnchor],
      [fill.topAnchor constraintEqualToAnchor:track.topAnchor],
      [fill.bottomAnchor constraintEqualToAnchor:track.bottomAnchor], fillWidth, nil]];
    nameLabel = StudioLabel(self,@"01   YOUR NAME",11,YES);
    name = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
    name.backgroundColor = [UIColor whiteColor]; name.font = [UIFont systemFontOfSize:18];
    name.text = @"Ada"; name.placeholder = @"Your name"; name.delegate = self;
    [name addTarget:self action:@selector(updatePreview:) forControlEvents:UIControlEventEditingChanged]; [self addSubview:name];
    amountLabel = StudioLabel(self,@"02   ROOM TO GROW  /  65%",11,YES);
    slider = [[[UISlider alloc] initWithFrame:CGRectZero] autorelease];
    slider.minimumValue = 0.1; slider.maximumValue = 1; slider.value = 0.65;
    [slider addTarget:self action:@selector(updatePreview:) forControlEvents:UIControlEventValueChanged]; [self addSubview:slider];
    save = [UIButton buttonWithType:UIButtonTypeSystem];
    [save setTitle:@"Save this idea" forState:UIControlStateNormal];
    [save addTarget:self action:@selector(saveNote:) forControlEvents:UIControlEventTouchUpInside]; [self addSubview:save];
    result = StudioLabel(self,@"Ready when you are.",14,NO); result.textColor = StudioMuted();
    divider = StudioBlock(self,StudioColor(220,223,223));
    hint = StudioLabel(self,@"Try a name, move the slider, then choose a color in Palette.",12,NO);
    hint.numberOfLines = 0; hint.textColor = StudioMuted();
  }
  return self;
}
- (void)dealloc { name.delegate = nil; [fillWidth release]; [super dealloc]; }
- (void)layoutSubviews
{
  [super layoutSubviews]; CGFloat w = self.bounds.size.width;
  BOOL compact = self.bounds.size.height < 570;
  CGFloat cardHeight = compact ? 150 : 186;
  heading.frame = CGRectMake(0,0,w,34); subtitle.frame = CGRectMake(0,39,w,24);
  card.frame = CGRectMake(0,80,w,cardHeight);
  [card viewWithTag:1].frame = CGRectMake(20,17,w-40,20);
  metric.frame = CGRectMake(20,43,w-40,44);
  [card viewWithTag:2].frame = CGRectMake(20,cardHeight-57,w-40,20);
  track.frame = CGRectMake(20,cardHeight-29,w-40,9);
  CGFloat y = CGRectGetMaxY(card.frame)+22;
  nameLabel.frame = CGRectMake(0,y,w,18); name.frame = CGRectMake(0,y+27,w,44);
  amountLabel.frame = CGRectMake(0,y+88,w,18); slider.frame = CGRectMake(0,y+114,w,32);
  save.frame = CGRectMake(0,y+160,132,40); result.frame = CGRectMake(144,y+160,MAX(0,w-144),40);
  divider.frame = CGRectMake(0,y+218,w,1); hint.frame = CGRectMake(0,y+233,w,42);
  self.contentSize = CGSizeMake(w,y+280);
  CGFloat width = track.bounds.size.width * slider.value;
  if (fabs(fillWidth.constant-width)>0.01) fillWidth.constant = width;
}
- (void)updatePreview:(id)sender
{
  metric.text = [NSString stringWithFormat:@"Hello, %@.", name.text.length ? name.text : @"you"];
  amountLabel.text = [NSString stringWithFormat:@"02   ROOM TO GROW  /  %.0f%%",slider.value*100];
  fillWidth.constant = track.bounds.size.width * slider.value;
  [self setNeedsLayout];
}
- (void)saveNote:(id)sender { [self endEditing:YES]; result.text = @"Idea saved. Nice work."; }
- (void)useColor:(UIColor *)color { fill.backgroundColor = color; metric.textColor = color; }
- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  return field.text.length-range.length+string.length <= 18;
}
- (BOOL)textFieldShouldReturn:(UITextField *)field { [field resignFirstResponder]; return YES; }
@end

@interface StudioComposeController : UIViewController @end
@implementation StudioComposeController
- (void)loadView { self.view = [[[StudioComposeView alloc] initWithFrame:CGRectMake(0,0,350,570)] autorelease]; }
@end

@interface StudioController : UIViewController
{
  NSArray *_screens;
  UIViewController *_selected;
  BOOL _onScreen;
}
- (void)selectScreen:(NSInteger)index;
- (void)chooseColor:(NSUInteger)index;
- (void)showMessage:(NSString *)message;
- (void)runSmokeTests;
@end
@interface StudioLibraryController : UITableViewController @end
@implementation StudioLibraryController
- (void)viewDidLoad
{
  [super viewDidLoad]; self.tableView.rowHeight = 70;
  self.tableView.backgroundColor = [UIColor whiteColor];
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"idea"];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 30; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)path
{
  NSArray *titles = [NSArray arrayWithObjects:@"A fresh start",@"Room for a little color",@"Something worth keeping",@"A better everyday",@"The next small adventure",@"Less, but better",nil];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idea" forIndexPath:path];
  cell.textLabel.text = [NSString stringWithFormat:@"%02ld    %@",(long)path.row+1,[titles objectAtIndex:path.row%6]];
  cell.textLabel.font = [UIFont systemFontOfSize:16]; cell.textLabel.textColor = StudioInk();
  cell.backgroundColor = path.row%2 ? StudioColor(248,249,250) : [UIColor whiteColor];
  return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path
{
  [(StudioController *)self.parentViewController showMessage:[NSString stringWithFormat:@"Idea %02ld selected. Keep exploring.",(long)path.row+1]];
}
@end

@interface StudioColorCell : UICollectionViewCell { UILabel *_name; UILabel *_number; }
- (void)configure:(NSUInteger)index;
@end
@implementation StudioColorCell
- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    _name = StudioLabel(self.contentView,@"",16,YES); _name.textColor = [UIColor whiteColor];
    _number = StudioLabel(self.contentView,@"",11,NO); _number.textColor = [UIColor whiteColor];
  }
  return self;
}
- (void)configure:(NSUInteger)index
{
  self.contentView.backgroundColor = StudioPalette(index);
  _name.text = [StudioColorNames() objectAtIndex:index]; _number.text = [NSString stringWithFormat:@"%02lu",(unsigned long)index+1];
}
- (void)layoutSubviews
{
  [super layoutSubviews]; CGFloat w = self.contentView.bounds.size.width, h = self.contentView.bounds.size.height;
  _number.frame = CGRectMake(12,10,w-24,18); _name.frame = CGRectMake(12,h-36,w-24,24);
}
@end
@interface StudioPaletteController : UICollectionViewController @end
@implementation StudioPaletteController
- (id)init
{
  UICollectionViewFlowLayout *layout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
  layout.itemSize = CGSizeMake(145,110); layout.minimumInteritemSpacing = 12; layout.minimumLineSpacing = 12;
  return [super initWithCollectionViewLayout:layout];
}
- (void)viewDidLoad
{
  [super viewDidLoad]; self.collectionView.backgroundColor = StudioPaper();
  [self.collectionView registerClass:[StudioColorCell class] forCellWithReuseIdentifier:@"color"];
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section { return 12; }
- (UICollectionViewCell *)collectionView:(UICollectionView *)view cellForItemAtIndexPath:(NSIndexPath *)path
{
  StudioColorCell *cell = (StudioColorCell *)[view dequeueReusableCellWithReuseIdentifier:@"color" forIndexPath:path];
  [cell configure:path.item]; return cell;
}
- (void)collectionView:(UICollectionView *)view didSelectItemAtIndexPath:(NSIndexPath *)path
{ [(StudioController *)self.parentViewController chooseColor:path.item]; }
@end

@interface StudioCanvas : UIView
{
@public
  UILabel *eyebrow, *title, *footer;
  UISegmentedControl *sections;
  UIView *body, *rule;
}
@end
@implementation StudioCanvas
- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = StudioPaper();
    eyebrow = StudioLabel(self,@"ONE SOURCE. TWO RUNTIMES.",11,YES); eyebrow.textColor = StudioMuted();
    title = StudioLabel(self,@"UIKit Studio",34,YES);
    sections = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Compose",@"Library",@"Palette",nil]] autorelease];
    sections.selectedSegmentIndex = 0; [self addSubview:sections];
    body = StudioBlock(self,StudioPaper()); body.clipsToBounds = YES;
    rule = StudioBlock(self,StudioColor(220,223,223));
    footer = StudioLabel(self,@"Built with UIKit. Made to explore.",12,NO); footer.textColor = StudioMuted();
  }
  return self;
}
- (void)layoutSubviews
{
  [super layoutSubviews]; UIEdgeInsets safe = self.safeAreaInsets;
  CGFloat w = MIN(760,self.bounds.size.width-safe.left-safe.right-40);
  CGFloat x = (self.bounds.size.width-w)/2, y = safe.top+18;
  eyebrow.frame = CGRectMake(x,y,w,18); title.frame = CGRectMake(x,y+25,w,44);
  sections.frame = CGRectMake(x,y+88,w,34);
  CGFloat bottom = self.bounds.size.height-safe.bottom;
  body.frame = CGRectMake(x,y+146,w,MAX(0,bottom-y-198));
  rule.frame = CGRectMake(x,bottom-40,w,1); footer.frame = CGRectMake(x,bottom-31,w,23);
  for (UIView *child in body.subviews) child.frame = body.bounds;
}
@end
@implementation StudioController
- (void)loadView { self.view = [[[StudioCanvas alloc] initWithFrame:CGRectZero] autorelease]; }
- (void)viewDidLoad
{
  [super viewDidLoad];
  _screens = [[NSArray alloc] initWithObjects:[[[StudioComposeController alloc] init] autorelease],
    [[[StudioLibraryController alloc] initWithStyle:UITableViewStylePlain] autorelease],
    [[[StudioPaletteController alloc] init] autorelease],nil];
  [((StudioCanvas *)self.view)->sections addTarget:self action:@selector(changeScreen:) forControlEvents:UIControlEventValueChanged];
  [self selectScreen:0];
}
- (void)dealloc { [_screens release]; [super dealloc]; }
- (void)viewDidAppear:(BOOL)animated { [super viewDidAppear:animated]; _onScreen = YES; }
- (void)viewWillDisappear:(BOOL)animated { _onScreen = NO; [super viewWillDisappear:animated]; }
- (void)changeScreen:(UISegmentedControl *)sender { [self selectScreen:sender.selectedSegmentIndex]; }
- (void)selectScreen:(NSInteger)index
{
  [self loadViewIfNeeded]; if (index < 0 || index >= (NSInteger)_screens.count) return;
  UIViewController *next = [_screens objectAtIndex:index]; if (next == _selected) return;
  [self.view endEditing:YES];
  if (_selected) {
    if (_onScreen) [_selected beginAppearanceTransition:NO animated:NO];
    [_selected willMoveToParentViewController:nil]; [_selected.view removeFromSuperview];
    [_selected removeFromParentViewController];
    if (_onScreen) [_selected endAppearanceTransition];
  }
  _selected = next; [self addChildViewController:next];
  if (_onScreen) [next beginAppearanceTransition:YES animated:NO];
  StudioCanvas *canvas = (StudioCanvas *)self.view;
  next.view.frame = canvas->body.bounds;
  next.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [canvas->body addSubview:next.view]; [next didMoveToParentViewController:self];
  if (_onScreen) [next endAppearanceTransition];
  canvas->sections.selectedSegmentIndex = index;
  [self showMessage:index == 0 ? @"Built with UIKit. Made to explore." : index == 1 ? @"30 ideas. Pick one that speaks to you." : @"Pick a color. Make the preview your own."];
  [self.view setNeedsLayout];
}
- (void)showMessage:(NSString *)message { ((StudioCanvas *)self.view)->footer.text = message; }
- (void)chooseColor:(NSUInteger)index
{
  StudioComposeView *compose = (StudioComposeView *)[[_screens objectAtIndex:0] view];
  [compose useColor:StudioPalette(index)]; [self selectScreen:0];
  [self showMessage:[NSString stringWithFormat:@"%@ selected. A fresh perspective.",[StudioColorNames() objectAtIndex:index%12]]];
}
- (void)runSmokeTests
{
  [self selectScreen:0]; [self.view layoutIfNeeded]; [self.view layoutIfNeeded];
  StudioComposeView *compose = (StudioComposeView *)_selected.view;
  compose->name.text = @"Grace"; compose->slider.value = 0.4;
  [compose->name sendActionsForControlEvents:UIControlEventEditingChanged]; [self.view layoutIfNeeded];
  if (![compose->metric.text isEqual:@"Hello, Grace."] || fabs(compose->fill.frame.size.width-compose->track.bounds.size.width*0.4)>1)
    [NSException raise:NSInternalInconsistencyException format:@"Live preview did not update"];
  if ([compose textField:compose->name shouldChangeCharactersInRange:NSMakeRange(5,0) replacementString:@"this name is much too long"])
    [NSException raise:NSInternalInconsistencyException format:@"Text delegate did not enforce the limit"];
  [compose->save sendActionsForControlEvents:UIControlEventTouchUpInside];
  if (![compose->result.text isEqual:@"Idea saved. Nice work."])
    [NSException raise:NSInternalInconsistencyException format:@"Save action was not delivered"];
  [self selectScreen:1]; [self.view layoutIfNeeded];
  UITableView *table = [(UITableViewController *)_selected tableView]; [table reloadData];
  if ([table numberOfRowsInSection:0] != 30) [NSException raise:NSInternalInconsistencyException format:@"Library did not load"];
  [(StudioLibraryController *)_selected tableView:table didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
  [self selectScreen:2]; [self.view layoutIfNeeded];
  UICollectionView *collection = [(UICollectionViewController *)_selected collectionView]; [collection reloadData];
  if ([collection numberOfItemsInSection:0] != 12) [NSException raise:NSInternalInconsistencyException format:@"Palette did not load"];
  [(StudioPaletteController *)_selected collectionView:collection didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
  if (_selected != [_screens objectAtIndex:0]) [NSException raise:NSInternalInconsistencyException format:@"Palette did not return to Compose"];
  fprintf(stderr,"PASS: UIKit Studio shared-source interaction scenarios\n");
}
@end

@implementation StudioAppDelegate
@synthesize window = _window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options
{
  self.window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
  self.window.rootViewController = [[[StudioController alloc] init] autorelease];
  [self.window makeKeyAndVisible];
  NSArray *arguments = [[NSProcessInfo processInfo] arguments];
  for (NSString *argument in arguments)
    if ([argument hasPrefix:@"--screen="]) [(StudioController *)self.window.rootViewController selectScreen:[[argument substringFromIndex:9] integerValue]];
  if ([arguments containsObject:@"--smoke"]) [self performSelector:@selector(smoke) withObject:nil afterDelay:0.5];
  return YES;
}
- (void)smoke
{
  @try { [(StudioController *)self.window.rootViewController runSmokeTests]; fflush(stderr); exit(0); }
  @catch (NSException *exception) { fprintf(stderr,"FAIL: %s\n",exception.description.UTF8String); exit(1); }
}
- (void)dealloc { [_window release]; [super dealloc]; }
@end
