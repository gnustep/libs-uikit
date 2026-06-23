#import <UIKit/UINib.h>
#import <UIKit/UIView.h>
#import <UIKit/UIViewController.h>

@implementation UIViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super init];
  if (self != nil && nibNameOrNil != nil)
    {
      UINib *nib = [[UINib alloc] initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
      _nibTopLevelObjects = [[nib instantiateWithOwner:self options:nil] retain];
      [nib release];
    }
  return self;
}
- (void)dealloc
{
  [_view release];
  [_title release];
  [_nibTopLevelObjects release];
  [super dealloc];
}
- (UIView *)view
{
  if (_view == nil)
    {
      [self loadView];
      [self viewDidLoad];
    }
  return _view;
}
- (void)setView:(UIView *)view { ASSIGN(_view, view); }
- (void)loadView { [self setView:[[[UIView alloc] initWithFrame:NSMakeRect(0, 0, 320, 480)] autorelease]]; }
- (void)viewDidLoad {}
- (void)viewWillAppear:(BOOL)animated {}
- (void)viewDidAppear:(BOOL)animated {}
- (void)viewWillDisappear:(BOOL)animated {}
- (void)viewDidDisappear:(BOOL)animated {}
- (NSString *)title { return _title; }
- (void)setTitle:(NSString *)title { ASSIGNCOPY(_title, title); }
@end
