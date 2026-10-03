#import "UIKitPrivate.h"
#define INTERACTION_VIEW - (UIView *)view { return _view; } - (void)willMoveToView:(UIView *)view {} - (void)didMoveToView:(UIView *)view { _view=view; }
@implementation UIHoverGestureRecognizer
- (void)_hoverAt:(CGPoint)point state:(UIGestureRecognizerState)state { if (!_enabled) return; _location=point; [self setState:state]; }
@end
@implementation UIToolTipInteraction
- (id)initWithDefaultToolTip:(NSString *)text { self=[super init]; if(self) _defaultToolTip=[text copy]; return self; }
- (void)dealloc { [_defaultToolTip release]; [super dealloc]; }
- (UIView *)view { return _view; }
- (void)willMoveToView:(UIView *)view { [[_view _nativeView] setToolTip:nil]; }
- (void)didMoveToView:(UIView *)view { _view=view; [[view _nativeView] setToolTip:_defaultToolTip]; }
- (NSString *)defaultToolTip { return _defaultToolTip; }
- (void)setDefaultToolTip:(NSString *)text { ASSIGNCOPY(_defaultToolTip,text); [[_view _nativeView] setToolTip:text]; }
@end
@implementation UIPointerInteraction
@synthesize delegate=_delegate;
- (id)initWithDelegate:(id<UIPointerInteractionDelegate>)delegate { self=[super init]; if(self) { _delegate=delegate; _enabled=YES; } return self; }
- (UIView *)view { return _view; }
- (void)willMoveToView:(UIView *)view { if (_inside) { [NSCursor pop]; _inside=NO; } }
- (void)didMoveToView:(UIView *)view { _view=view; }
- (BOOL)isEnabled { return _enabled; }
- (void)setEnabled:(BOOL)value { _enabled=value; if (!value && _inside) { [NSCursor pop]; _inside=NO; } }
- (void)_hover:(BOOL)inside { inside=inside && _enabled; if(inside==_inside) return; _inside=inside; if(inside) [[NSCursor pointingHandCursor] push]; else [NSCursor pop]; }
@end
@implementation UIDragItem
- (id)initWithItemProvider:(NSItemProvider *)provider { self=[super init]; if(self) _itemProvider=[provider retain]; return self; }
- (void)dealloc { [_itemProvider release]; [_localObject release]; [super dealloc]; }
@synthesize itemProvider=_itemProvider, localObject=_localObject;
@end
@interface _UIKitDragSession : NSObject <UIDragSession,UIDropSession> { @public NSArray *items; CGPoint point; BOOL local; }
@end
@implementation _UIKitDragSession
- (void)dealloc { [items release]; [super dealloc]; }
- (NSArray *)items { return items ?: @[]; }
- (CGPoint)locationInView:(UIView *)view { return [[view _nativeView] convertPoint:point fromView:nil]; }
- (id<UIDragSession>)localDragSession { return local ? self : nil; }
- (BOOL)hasItemsConformingToTypeIdentifiers:(NSArray *)types { return ([types containsObject:@"public.text"] || [types containsObject:@"public.plain-text"] || [types containsObject:@"public.utf8-plain-text"]) && items.count > 0; }
- (NSProgress *)loadObjectsOfClass:(Class)cls completion:(UIDropSessionObjectsCompletion)completion {
  NSMutableArray *objects=[NSMutableArray array]; for (UIDragItem *item in items) if ([item.localObject isKindOfClass:cls]) [objects addObject:item.localObject];
  if(completion) CALL_BLOCK(completion,objects); NSProgress *progress=[NSProgress progressWithTotalUnitCount:1]; progress.completedUnitCount=1; return progress;
}
@end
static _UIKitDragSession *UIKitCurrentDrag;
@implementation UIDragInteraction
INTERACTION_VIEW
@synthesize delegate=_delegate, enabled=_enabled;
- (id)initWithDelegate:(id<UIDragInteractionDelegate>)delegate { self=[super init]; if(self) { _delegate=delegate; _enabled=YES; } return self; }
- (BOOL)_beginDrag:(NSEvent *)event {
  if (!_enabled || UIKitCurrentDrag) return NO;
  _UIKitDragSession *session=[[_UIKitDragSession new] autorelease]; session->point=event.locationInWindow; session->local=YES;
  NSArray *items=[_delegate dragInteraction:self itemsForBeginningSession:session]; if(!items.count) return NO;
  session->items=[items copy]; NSMutableArray *strings=[NSMutableArray array];
  for(UIDragItem *item in items) if([item.localObject isKindOfClass:[NSString class]]) [strings addObject:item.localObject];
  if(!strings.count) return NO;
  NSPasteboard *board=[NSPasteboard pasteboardWithName:NSDragPboard]; [board declareTypes:@[NSStringPboardType] owner:nil]; [board setString:[strings componentsJoinedByString:@"\n"] forType:NSStringPboardType];
  NSImage *image=[[[NSImage alloc] initWithSize:NSMakeSize(180,32)] autorelease]; [image lockFocus]; [[NSColor controlBackgroundColor] set]; NSRectFill(NSMakeRect(0,0,180,32)); [[strings firstObject] drawAtPoint:NSMakePoint(8,8) withAttributes:@{NSFontAttributeName:[NSFont systemFontOfSize:14],NSForegroundColorAttributeName:[NSColor textColor]}]; [image unlockFocus];
  UIKitCurrentDrag=[session retain];
  @try { [[_view _nativeView] dragImage:image at:[[_view _nativeView] convertPoint:event.locationInWindow fromView:nil] offset:NSZeroSize event:event pasteboard:board source:self slideBack:YES]; }
  @finally { DESTROY(UIKitCurrentDrag); }
  return YES;
}
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)local { return NSDragOperationCopy; }
- (BOOL)ignoreModifierKeysWhileDragging { return YES; }
@end
@implementation UIDropProposal
- (id)initWithDropOperation:(UIDropOperation)operation { self=[super init]; if(self) _operation=operation; return self; }
@synthesize operation=_operation;
@end
@implementation UIDropInteraction
@synthesize delegate=_delegate;
- (id)initWithDelegate:(id<UIDropInteractionDelegate>)delegate { self=[super init]; if(self) _delegate=delegate; return self; }
- (UIView *)view { return _view; }
- (void)willMoveToView:(UIView *)view { [[_view _nativeView] unregisterDraggedTypes]; }
- (void)didMoveToView:(UIView *)view { _view=view; if(view) [[view _nativeView] registerForDraggedTypes:@[NSStringPboardType]]; }
- (NSUInteger)_drop:(id<NSDraggingInfo>)info perform:(BOOL)perform {
  _UIKitDragSession *session=UIKitCurrentDrag;
  if(!session) { NSString *text=[[info draggingPasteboard] stringForType:NSStringPboardType]; if (!text) return NSDragOperationNone; session=[[_UIKitDragSession new] autorelease]; UIDragItem *item=[[[UIDragItem alloc] initWithItemProvider:nil] autorelease]; item.localObject=text; session->items=[@[item] copy]; }
  session->point=[info draggingLocation];
  if([_delegate respondsToSelector:@selector(dropInteraction:canHandleSession:)] && ![_delegate dropInteraction:self canHandleSession:session]) return NSDragOperationNone;
  UIDropProposal *proposal=[_delegate respondsToSelector:@selector(dropInteraction:sessionDidUpdate:)] ? [_delegate dropInteraction:self sessionDidUpdate:session] : nil;
  if (proposal && proposal.operation != UIDropOperationCopy && proposal.operation != UIDropOperationMove) return NSDragOperationNone;
  if (perform && [_delegate respondsToSelector:@selector(dropInteraction:performDrop:)]) [_delegate dropInteraction:self performDrop:session];
  return NSDragOperationCopy;
}
@end
@implementation UIView (UIKitPointerEvents)
- (void)_hoverEvent:(NSEvent *)event state:(UIGestureRecognizerState)state {
  CGPoint point=[[[self window] _nativeView] convertPoint:event.locationInWindow fromView:nil];
  for (UIGestureRecognizer *gesture in self.gestureRecognizers) if ([gesture isKindOfClass:[UIHoverGestureRecognizer class]]) [(UIHoverGestureRecognizer *)gesture _hoverAt:point state:state];
  for (id interaction in self.interactions) if ([interaction isKindOfClass:[UIPointerInteraction class]]) [interaction _hover:state != UIGestureRecognizerStateEnded];
}
- (BOOL)_beginNativeDrag:(NSEvent *)event { for (id interaction in self.interactions) if ([interaction isKindOfClass:[UIDragInteraction class]] && [interaction _beginDrag:event]) return YES; return NO; }
- (NSUInteger)_nativeDrop:(id<NSDraggingInfo>)info perform:(BOOL)perform { for(id interaction in self.interactions) if([interaction isKindOfClass:[UIDropInteraction class]]) return [interaction _drop:info perform:perform]; return NSDragOperationNone; }
@end