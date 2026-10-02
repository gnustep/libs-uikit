#import "UIKitPrivate.h"
@implementation UIAlertAction
+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(UIAlertActionHandler)handler
{
  UIAlertAction *action = [[[self alloc] init] autorelease];
  action->_title = [title copy]; action->_style = style; action->_handler = handler ? Block_copy(handler) : NULL; action->_enabled = YES;
  return action;
}
- (void)dealloc { [_title release]; if (_handler) Block_release(_handler); [super dealloc]; }
- (id)copyWithZone:(NSZone *)zone {
  UIAlertAction *copy = [[UIAlertAction actionWithTitle:_title style:_style handler:_handler] retain];
  copy.enabled = _enabled; return copy;
}
- (NSString *)title { return _title; }
- (UIAlertActionStyle)style { return _style; }
@synthesize enabled = _enabled;
- (void)_invoke { if (_enabled && _handler) CALL_BLOCK(_handler, self); }
@end
@implementation UIAlertController
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style
{
  UIAlertController *alert = [[[self alloc] init] autorelease];
  alert.title = title; alert.message = message; alert->_preferredStyle = style;
  return alert;
}
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
  self = [super initWithNibName:name bundle:bundle];
  if (self) _actions = [[NSMutableArray alloc] init];
  return self;
}
- (void)dealloc { [_message release]; [_actions release]; [super dealloc]; }
@synthesize message = _message;
- (UIAlertControllerStyle)preferredStyle { return _preferredStyle; }
- (NSArray *)actions { return [[_actions copy] autorelease]; }
- (void)addAction:(UIAlertAction *)action
{
  if (!action || [_actions containsObject:action]) [NSException raise:NSInvalidArgumentException format:@"Invalid alert action"];
  [_actions addObject:action];
  if (self.isViewLoaded) [self _buildContent];
}
- (void)loadView { [super loadView]; [self _buildContent]; }
- (void)_buildContent
{
  for (UIView *view in [[_view.subviews copy] autorelease]) [view removeFromSuperview];
  _view.backgroundColor = [UIColor systemBackgroundColor];
  UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(20,20,320,110)] autorelease];
  label.text = [NSString stringWithFormat:@"%@\n\n%@", self.title ?: @"", _message ?: @""];
  label.numberOfLines = 0; label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [_view addSubview:label];
  NSInteger index = 0;
  for (UIAlertAction *action in _actions) {
    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(20,140+index*44,320,36)] autorelease];
    [button setTitle:action.title forState:UIControlStateNormal]; button.enabled = action.enabled;
    button.tag = index++; button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button addTarget:self action:@selector(_chooseAction:) forControlEvents:UIControlEventTouchUpInside];
    [_view addSubview:button];
  }
  _view.frame = CGRectMake(0,0,360,MAX(200,150+index*44));
}
- (void)_chooseAction:(UIButton *)button
{
  UIAlertAction *action = [[[_actions objectAtIndex:button.tag] retain] autorelease];
  if (!action.enabled) return;
  [[self retain] autorelease];
  [self dismissViewControllerAnimated:YES completion:nil];
  [action _invoke];
}
@end
