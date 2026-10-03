#import "UIKitPrivate.h"
/* Native popup tracking is synchronous; preserve the source for responder actions. */
static UIView *UIKitActiveMenuView;
static void UIKitPresentNativeMenu(NSMenu *menu, UIView *view, CGPoint point, NSEvent *event) {
  if (!menu || !view.window) return;
  if (event) { [NSMenu popUpContextMenu:menu withEvent:event forView:[view _nativeView]]; return; }
  NSView *native=[view _nativeView];
  [menu popUpMenuPositioningItem:nil atLocation:point inView:native];
  /* GNUstep's positioning API only displays the menu; explicitly track selection. */
  NSEvent *trigger=[NSEvent mouseEventWithType:NSLeftMouseDown
    location:[native convertPoint:point toView:nil] modifierFlags:0
    timestamp:[NSProcessInfo processInfo].systemUptime windowNumber:native.window.windowNumber
    context:nil eventNumber:0 clickCount:1 pressure:0];
  @try { [[menu menuRepresentation] mouseDown:trigger]; }
  @finally { [native.window removeChildWindow:[menu window]]; [[menu window] orderOut:nil]; }
}

@implementation UIMenuElement
@synthesize title=_title, image=_image, attributes=_attributes, state=_state;
- (void)dealloc { [_title release]; [_image release]; [super dealloc]; }
- (id)copyWithZone:(NSZone *)zone { return [self retain]; }
@end
@implementation UIAction
+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image identifier:(NSString *)identifier handler:(UIActionHandler)handler {
  UIAction *action=[[[self alloc] init] autorelease]; action.title=title; action.image=image; action->_handler=handler ? Block_copy(handler) : NULL; return action;
}
- (void)dealloc { if (_handler) Block_release(_handler); [super dealloc]; }
- (void)_invoke:(id)sender { if (!(_attributes & UIMenuElementAttributesDisabled) && _handler) CALL_BLOCK(_handler,self); }
@end
@implementation UICommand
@synthesize action=_action, propertyList=_propertyList;
+ (instancetype)commandWithTitle:(NSString *)title image:(UIImage *)image action:(SEL)action propertyList:(id)propertyList { UICommand *command=[[[self alloc] init] autorelease]; command.title=title; command.image=image; command->_action=action; command->_propertyList=[propertyList retain]; return command; }
- (void)dealloc { [_propertyList release]; [super dealloc]; }
- (void)_invoke:(id)sender {
  if (_attributes & UIMenuElementAttributesDisabled) return;
  UIApplication *application=[UIApplication sharedApplication];
  if ([application sendAction:_action to:nil from:self forEvent:nil]) return;
  for (UIResponder *responder=UIKitActiveMenuView; responder; responder=responder.nextResponder)
    if ([responder canPerformAction:_action withSender:self]) { [application sendAction:_action to:responder from:self forEvent:nil]; break; }
}
@end
@implementation UIMenu
+ (instancetype)menuWithTitle:(NSString *)title children:(NSArray *)children { UIMenu *menu=[[[self alloc] init] autorelease]; menu.title=title; menu->_children=[children copy]; return menu; }
- (void)dealloc { [_children release]; [super dealloc]; }
@synthesize children=_children;
- (NSMenu *)_nativeMenu {
  NSMenu *menu=[[[NSMenu alloc] initWithTitle:_title ?: @""] autorelease]; [menu setAutoenablesItems:NO];
  for (UIMenuElement *element in _children) {
    if (element.attributes & UIMenuElementAttributesHidden) continue;
    NSMenuItem *item=[[[NSMenuItem alloc] initWithTitle:element.title ?: @"" action:@selector(_invoke:) keyEquivalent:@""] autorelease];
    [item setTarget:element]; [item setRepresentedObject:element]; [item setEnabled:!(element.attributes & UIMenuElementAttributesDisabled)]; [item setState:element.state == UIMenuElementStateOn ? NSOnState : element.state == UIMenuElementStateMixed ? NSMixedState : NSOffState];
    if ([element isKindOfClass:[UIMenu class]]) [item setSubmenu:[(UIMenu *)element _nativeMenu]];
    [menu addItem:item];
  } return menu;
}
- (void)_presentInView:(UIView *)view point:(CGPoint)point event:(NSEvent *)event {
  NSMenu *menu=[self _nativeMenu];
  UIView *previous=UIKitActiveMenuView; UIKitActiveMenuView=view;
  @try {
    UIKitPresentNativeMenu(menu,view,point,event);
  } @finally { UIKitActiveMenuView=previous; }
}
@end
@implementation UIContextMenuConfiguration
+ (instancetype)configurationWithIdentifier:(id<NSCopying>)identifier previewProvider:(UIContextMenuContentPreviewProvider)preview actionProvider:(UIContextMenuActionProvider)provider {
  UIContextMenuConfiguration *configuration=[[[self alloc] init] autorelease]; configuration->_actionProvider=provider ? Block_copy(provider) : NULL; return configuration;
}
- (void)dealloc { if (_actionProvider) Block_release(_actionProvider); [super dealloc]; }
- (UIMenu *)_menu { return _actionProvider ? CALL_BLOCK_RET(_actionProvider,UIMenu *,@[]) : nil; }
@end
#define INTERACTION_VIEW - (UIView *)view { return _view; } - (void)willMoveToView:(UIView *)view {} - (void)didMoveToView:(UIView *)view { _view=view; }
@implementation UIContextMenuInteraction
INTERACTION_VIEW
@synthesize delegate=_delegate;
- (id)initWithDelegate:(id<UIContextMenuInteractionDelegate>)delegate { self=[super init]; if(self) _delegate=delegate; return self; }
- (void)_presentAtPoint:(CGPoint)point event:(NSEvent *)event {
  UIContextMenuConfiguration *configuration=[_delegate contextMenuInteraction:self configurationForMenuAtLocation:point];
  [[configuration _menu] _presentInView:_view point:point event:event];
}
@end
@implementation UIEditMenuConfiguration
@synthesize sourcePoint=_sourcePoint, identifier=_identifier;
+ (instancetype)configurationWithIdentifier:(id<NSCopying>)identifier sourcePoint:(CGPoint)point { UIEditMenuConfiguration *configuration=[[[self alloc] init] autorelease]; configuration->_sourcePoint=point; configuration->_identifier=[identifier copyWithZone:NULL]; return configuration; }
- (void)dealloc { [(id)_identifier release]; [super dealloc]; }
@end
@implementation UIEditMenuInteraction
INTERACTION_VIEW
@synthesize delegate=_delegate;
- (id)initWithDelegate:(id<UIEditMenuInteractionDelegate>)delegate { self=[super init]; if(self) _delegate=delegate; return self; }
- (void)presentEditMenuWithConfiguration:(UIEditMenuConfiguration *)configuration {
  NSArray *actions=@[[UICommand commandWithTitle:@"Copy" image:nil action:@selector(copy:) propertyList:nil],[UICommand commandWithTitle:@"Paste" image:nil action:@selector(paste:) propertyList:nil]];
  UIMenu *menu=[_delegate respondsToSelector:@selector(editMenuInteraction:menuForConfiguration:suggestedActions:)] ? [_delegate editMenuInteraction:self menuForConfiguration:configuration suggestedActions:actions] : [UIMenu menuWithTitle:@"Edit" children:actions];
  ASSIGN(_nativeMenu,[menu _nativeMenu]);
  UIView *previous=UIKitActiveMenuView; UIKitActiveMenuView=_view;
  @try { UIKitPresentNativeMenu(_nativeMenu,_view,configuration.sourcePoint,nil); }
  @finally { UIKitActiveMenuView=previous; DESTROY(_nativeMenu); }
}
- (void)dismissMenu { [_nativeMenu closeTransient]; }
- (void)dealloc { [_nativeMenu release]; [super dealloc]; }
@end