#import "UIKitPrivate.h"

@implementation UICollectionViewController
- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
  if (!layout) { [self release]; [NSException raise:NSInvalidArgumentException format:@"A collection layout is required"]; return nil; }
  if ((self = [self initWithNibName:nil bundle:nil])) { ASSIGN(_initialCollectionViewLayout, layout); }
  return self;
}
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
  if ((self = [super initWithNibName:name bundle:bundle])) {
    _clearsSelectionOnViewWillAppear = YES;
    _initialCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
  }
  return self;
}
- (void)dealloc
{
  if ([(UICollectionView *)_view dataSource] == self) [(UICollectionView *)_view setDataSource:nil];
  if ([(UICollectionView *)_view delegate] == self) [(UICollectionView *)_view setDelegate:nil];
  [_initialCollectionViewLayout release]; [super dealloc];
}
- (void)loadView
{
  if (_nibName) [super loadView];
  else [self setCollectionView:[[[UICollectionView alloc] initWithFrame:CGRectMake(0,0,320,480) collectionViewLayout:_initialCollectionViewLayout] autorelease]];
}
- (void)setView:(UIView *)view
{
  if (view && ![view isKindOfClass:[UICollectionView class]])
    [NSException raise:NSInvalidArgumentException format:@"UICollectionViewController requires a UICollectionView root"];
  if (_view == view) return;
  if ([(UICollectionView *)_view dataSource] == self) [(UICollectionView *)_view setDataSource:nil];
  if ([(UICollectionView *)_view delegate] == self) [(UICollectionView *)_view setDelegate:nil];
  [super setView:view];
  [(UICollectionView *)view setDataSource:self]; [(UICollectionView *)view setDelegate:self];
}
- (UICollectionView *)collectionView { return (UICollectionView *)[self view]; }
- (void)setCollectionView:(UICollectionView *)view { [self setView:view]; }
- (UICollectionViewLayout *)collectionViewLayout { return _view ? [(UICollectionView *)_view collectionViewLayout] : _initialCollectionViewLayout; }
- (BOOL)clearsSelectionOnViewWillAppear { return _clearsSelectionOnViewWillAppear; }
- (void)setClearsSelectionOnViewWillAppear:(BOOL)value { _clearsSelectionOnViewWillAppear = value; }
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated]; [[self collectionView] reloadData];
  if (_clearsSelectionOnViewWillAppear)
    for (NSIndexPath *path in [[self collectionView] indexPathsForSelectedItems])
      [[self collectionView] deselectItemAtIndexPath:path animated:animated];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)view { return 1; }
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section { return 0; }
- (UICollectionViewCell *)collectionView:(UICollectionView *)view cellForItemAtIndexPath:(NSIndexPath *)path
{
  [NSException raise:NSInternalInconsistencyException format:@"Override collectionView:cellForItemAtIndexPath: in your controller"];
  return nil;
}
@end
