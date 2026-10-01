#import "UIKitPrivate.h"

@implementation _UIKitViewPeer
- (BOOL)isFlipped { return YES; }
- (BOOL)acceptsFirstResponder { return [owner canBecomeFirstResponder]; }
- (BOOL)becomeFirstResponder { return YES; }
- (BOOL)resignFirstResponder { return [owner canResignFirstResponder]; }
- (void)setFrame:(NSRect)frame
{
  [super setFrame:frame];
  if (owner) [owner _nativeFrameChanged:frame];
}
- (BOOL)wantsDefaultClipping { return [owner clipsToBounds]; }
- (void)drawRect:(NSRect)rect { [owner layoutIfNeeded]; [owner drawRect:rect]; }
- (NSView *)hitTest:(NSPoint)point
{
  NSPoint local = [self convertPoint:point fromView:[self superview]];
  local = [[owner _nativeCoordinateView] convertPoint:local fromView:self];
  UIView *hit = [owner hitTest:local withEvent:nil];
  if (!hit) return nil;
  NSView *nativeHit = [super hitTest:point];
  if ([nativeHit isDescendantOf:[hit _nativeView]]) return nativeHit;
  return [hit _nativeView];
}
- (void)mouseDown:(NSEvent *)event { [owner mouseDown:event]; }
- (void)mouseDragged:(NSEvent *)event { [owner mouseDragged:event]; }
- (void)mouseUp:(NSEvent *)event { [owner mouseUp:event]; }
@end

@implementation UIView
- (id)init { return [self initWithFrame:CGRectZero]; }
- (id)initWithCoder:(NSCoder *)coder { return [self initWithFrame:CGRectZero]; }
- (id)initWithFrame:(CGRect)frame
{
  self = [super init];
  if (self) {
    _frame = frame; _bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [self _uiInitializeLayout];
    _subviews = [NSMutableArray new]; _gestureRecognizers = [NSMutableArray new];
    _userInteractionEnabled = YES; _autoresizesSubviews = YES; _alpha = 1;
    _nativeView = [[_UIKitViewPeer alloc] initWithFrame:frame];
    ((_UIKitViewPeer *)_nativeView)->owner = self;
    [_nativeView setAutoresizesSubviews:YES];
  }
  return self;
}
- (void)dealloc
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  [self _uiDestroyLayout];
  for (UIGestureRecognizer *recognizer in _gestureRecognizers) [recognizer _setView:nil];
  for (UIView *view in _subviews) view->_superview = nil;
  ((_UIKitViewPeer *)_nativeView)->owner = nil;
  [_nativeView removeFromSuperview]; [_nativeView release]; [_subviews release];
  [_gestureRecognizers release]; [_activeTouch release]; [_backgroundColor release];
  [super dealloc];
}
- (NSView *)_nativeView { return _nativeView; }
- (NSView *)_nativeContainerView { return _nativeView; }
- (NSView *)_nativeCoordinateView { return _nativeView; }
- (void)_addNativeSubview:(NSView *)view { [_nativeView addSubview:view]; }
- (CGRect)frame { return _frame; }
- (void)setFrame:(CGRect)frame
{
  if (NSEqualRects(_frame, frame)) return;
  CGSize previous = _bounds.size;
  _frame = frame; _bounds.size = frame.size;
  [_nativeView setFrame:frame]; [_nativeView setBounds:_bounds];
  if (_autoresizesSubviews && !NSEqualSizes(previous, _bounds.size))
    for (UIView *view in [self subviews]) [view resizeWithOldSuperviewSize:previous];
  [self setNeedsLayout];
}
- (void)_nativeFrameChanged:(CGRect)frame { [self setFrame:frame]; }
- (CGRect)bounds { return _bounds; }
- (void)setBounds:(CGRect)bounds
{
  if (NSEqualRects(_bounds, bounds)) return;
  CGSize previous = _bounds.size; _bounds = bounds;
  [_nativeView setBounds:bounds];
  if (_autoresizesSubviews && !NSEqualSizes(previous, bounds.size))
    for (UIView *view in [self subviews]) [view resizeWithOldSuperviewSize:previous];
  [self setNeedsLayout];
}
- (CGPoint)center { return CGPointMake(NSMidX(_frame), NSMidY(_frame)); }
- (void)setCenter:(CGPoint)point { CGRect frame = _frame; frame.origin = CGPointMake(point.x-frame.size.width/2, point.y-frame.size.height/2); [self setFrame:frame]; }
- (UIColor *)backgroundColor { return _backgroundColor; }
- (void)setBackgroundColor:(UIColor *)color { ASSIGN(_backgroundColor, color); [self setNeedsDisplay]; }
- (BOOL)isHidden { return _hidden; }
- (void)setHidden:(BOOL)hidden { if (hidden) [self _cancelActiveTouch]; _hidden = hidden; [_nativeView setHidden:hidden]; [_superview setNeedsLayout]; }
- (CGFloat)alpha { return _alpha; }
- (void)setAlpha:(CGFloat)alpha { _alpha = alpha; if ([_nativeView respondsToSelector:@selector(setAlphaValue:)]) [_nativeView setAlphaValue:alpha]; }
- (UIViewContentMode)contentMode { return _contentMode; }
- (void)setContentMode:(UIViewContentMode)mode { _contentMode = mode; [self setNeedsDisplay]; }
- (UIViewAutoresizing)autoresizingMask { return _uiAutoresizingMask; }
- (void)setAutoresizingMask:(UIViewAutoresizing)mask { _uiAutoresizingMask = mask; }
- (BOOL)autoresizesSubviews { return _autoresizesSubviews; }
- (void)setAutoresizesSubviews:(BOOL)value { _autoresizesSubviews = value; }
- (BOOL)clipsToBounds { return _clipsToBounds; }
- (void)setClipsToBounds:(BOOL)value { _clipsToBounds = value; [self setNeedsDisplay]; }
- (NSInteger)tag { return _tag; }
- (void)setTag:(NSInteger)tag { _tag = tag; }
- (UIWindow *)window { return [_superview window]; }
- (NSArray *)subviews { return [[_subviews copy] autorelease]; }
- (UIView *)superview { return _superview; }
- (void)addSubview:(UIView *)view { [self insertSubview:view atIndex:[_subviews count]]; }
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
  if (!view) return;
  if (![view isKindOfClass:[UIView class]] || [self isDescendantOfView:view])
    [NSException raise:NSInvalidArgumentException format:@"Invalid UIView hierarchy"];
  if (index < 0 || index > [_subviews count]) [NSException raise:NSRangeException format:@"Invalid subview index"];
  [[view retain] autorelease];
  if (view->_superview == self) {
    [_subviews removeObjectIdenticalTo:view];
    [_subviews insertObject:view atIndex:MIN((NSUInteger)index, [_subviews count])];
    [self _syncNativeSubviewOrder]; return;
  }
  [view removeFromSuperview];
  UIWindow *window = [self window];
  [view willMoveToSuperview:self]; [view _willMoveToWindow:window];
  [_subviews insertObject:view atIndex:index]; view->_superview = self;
  [[self _nativeContainerView] addSubview:[view _nativeView]];
  [self _syncNativeSubviewOrder];
  [view didMoveToSuperview]; [view _didMoveToWindow]; [self didAddSubview:view];
  [self setNeedsLayout];
}
- (void)insertSubview:(UIView *)view belowSubview:(UIView *)sibling
{ NSUInteger index = [_subviews indexOfObjectIdenticalTo:sibling]; if (index == NSNotFound) [NSException raise:NSInvalidArgumentException format:@"Not a sibling"]; if (view == sibling) return; NSUInteger old = [_subviews indexOfObjectIdenticalTo:view]; if (old != NSNotFound && old < index) index--; [self insertSubview:view atIndex:index]; }
- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)sibling
{ NSUInteger index = [_subviews indexOfObjectIdenticalTo:sibling]; if (index == NSNotFound) [NSException raise:NSInvalidArgumentException format:@"Not a sibling"]; if (view == sibling) return; NSUInteger old = [_subviews indexOfObjectIdenticalTo:view]; if (old != NSNotFound && old < index) index--; [self insertSubview:view atIndex:index+1]; }
- (void)bringSubviewToFront:(UIView *)view { if (view && view->_superview == self) [self insertSubview:view atIndex:[_subviews count]]; }
- (void)sendSubviewToBack:(UIView *)view { if (view && view->_superview == self) [self insertSubview:view atIndex:0]; }
- (void)_syncNativeSubviewOrder
{
  NSView *previous = nil;
  for (UIView *view in _subviews) {
    [[self _nativeContainerView] addSubview:[view _nativeView] positioned:NSWindowAbove relativeTo:previous];
    previous = [view _nativeView];
  }
}
- (void)_sortSubviewsUsingFunction:(NSComparisonResult (*)(id,id,void *))function context:(void *)context
{ [_subviews sortUsingFunction:function context:context]; [self _syncNativeSubviewOrder]; }
- (void)removeFromSuperview
{
  if (!_superview) return;
  [[self retain] autorelease]; UIView *parent = _superview;
  [self _uiRemoveAncestorConstraints];
  [parent willRemoveSubview:self]; [self willMoveToSuperview:nil]; [self _willMoveToWindow:nil];
  [_nativeView removeFromSuperview]; _superview = nil; [parent->_subviews removeObjectIdenticalTo:self];
  [self didMoveToSuperview]; [self _didMoveToWindow]; [parent setNeedsLayout];
}
- (BOOL)isDescendantOfView:(UIView *)view
{ for (UIView *ancestor = self; ancestor; ancestor = [ancestor superview]) if (ancestor == view) return YES; return NO; }
- (UIView *)viewWithTag:(NSInteger)tag
{ if (_tag == tag) return self; for (UIView *view in _subviews) { UIView *found = [view viewWithTag:tag]; if (found) return found; } return nil; }
- (CGPoint)convertPoint:(CGPoint)point toView:(UIView *)view
{ return [[self _nativeCoordinateView] convertPoint:point toView:[(view ?: (UIView *)[self window]) _nativeCoordinateView]]; }
- (CGPoint)convertPoint:(CGPoint)point fromView:(UIView *)view
{ return [[self _nativeCoordinateView] convertPoint:point fromView:[(view ?: (UIView *)[self window]) _nativeCoordinateView]]; }
- (CGRect)convertRect:(CGRect)rect toView:(UIView *)view
{ return [[self _nativeCoordinateView] convertRect:rect toView:[(view ?: (UIView *)[self window]) _nativeCoordinateView]]; }
- (CGRect)convertRect:(CGRect)rect fromView:(UIView *)view
{ return [[self _nativeCoordinateView] convertRect:rect fromView:[(view ?: (UIView *)[self window]) _nativeCoordinateView]]; }
- (void)_willMoveToWindow:(UIWindow *)window
{
  if ([self window] != window) { [self _cancelActiveTouch]; if ([self isFirstResponder]) [self resignFirstResponder]; }
  [self willMoveToWindow:window]; for (UIView *view in [self subviews]) [view _willMoveToWindow:window];
}
- (void)_didMoveToWindow { [self didMoveToWindow]; for (UIView *view in [self subviews]) [view _didMoveToWindow]; }
- (void)willMoveToSuperview:(UIView *)view {}
- (void)didMoveToSuperview {}
- (void)willMoveToWindow:(UIWindow *)window {}
- (void)didMoveToWindow {}
- (void)didAddSubview:(UIView *)view {}
- (void)willRemoveSubview:(UIView *)view {}
- (void)setNeedsDisplay { [_nativeView setNeedsDisplay:YES]; }
- (void)setNeedsDisplayInRect:(CGRect)rect { [_nativeView setNeedsDisplayInRect:rect]; }
- (void)setNeedsLayout
{
  if (!_uiNeedsLayout) [self performSelector:@selector(layoutIfNeeded) withObject:nil afterDelay:0];
  _uiNeedsLayout = YES; [self setNeedsDisplay];
}
- (void)layoutIfNeeded
{
  UIView *root = self; while ([root superview]) root = [root superview];
  if (root->_uiSolvingLayout) return;
  root->_uiSolvingLayout = YES;
  @try {
    [root updateConstraintsIfNeeded];
    [root _uiSolveLayout];
    [root _uiLayoutPass];
  } @finally { root->_uiSolvingLayout = NO; }
}
- (void)layoutSubviews {}
- (CGSize)sizeThatFits:(CGSize)size { return [self bounds].size; }
- (void)sizeToFit { CGRect frame = [self frame]; frame.size = [self sizeThatFits:frame.size]; [self setFrame:frame]; }
- (void)drawRect:(CGRect)rect { if (_backgroundColor) { [[_backgroundColor NSColor] set]; NSRectFill(rect); } }
- (BOOL)endEditing:(BOOL)force
{
  UIResponder *responder = [[self window] _firstResponder];
  if (![responder isKindOfClass:[UIView class]] || ![(UIView *)responder isDescendantOfView:self]) return NO;
  if (force) return [[self window] _makeFirstResponder:nil];
  return [responder resignFirstResponder];
}
- (void)_setOwningViewController:(id)controller { _owningViewController = controller; }
- (UIResponder *)nextResponder { return _owningViewController ?: _superview; }
- (UIWindow *)_responderWindow { return [self window]; }
- (NSResponder *)_nativeResponder { return _nativeView; }
- (BOOL)isUserInteractionEnabled { return _userInteractionEnabled; }
- (void)setUserInteractionEnabled:(BOOL)enabled { if (!enabled) [self _cancelActiveTouch]; _userInteractionEnabled = enabled; }
- (NSArray *)gestureRecognizers { return [[_gestureRecognizers copy] autorelease]; }
- (void)addGestureRecognizer:(UIGestureRecognizer *)recognizer
{
  if (!recognizer || [recognizer view] == self) return;
  [[recognizer retain] autorelease]; [[recognizer view] removeGestureRecognizer:recognizer];
  [_gestureRecognizers addObject:recognizer]; [recognizer _setView:self];
}
- (void)removeGestureRecognizer:(UIGestureRecognizer *)recognizer
{ if ([recognizer view] != self) return; [recognizer _setView:nil]; [_gestureRecognizers removeObjectIdenticalTo:recognizer]; }
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event { return CGRectContainsPoint([self bounds], point); }
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  if (!_userInteractionEnabled || _hidden || _alpha <= 0.01 || ![self pointInside:point withEvent:event]) return nil;
  for (UIView *child in [[self subviews] reverseObjectEnumerator]) {
    UIView *hit = [child hitTest:[child convertPoint:point fromView:self] withEvent:event]; if (hit) return hit;
  }
  return self;
}
/* Use UIKit coordinates here: GNUstep versions differ in how NSView treats
   vertical autoresizing margins in flipped superviews. */
- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
  if (!_translatesAutoresizingMaskIntoConstraints) return;
  CGRect frame = [self frame];
  CGSize size = [[self superview] bounds].size;
  CGFloat *positions[2] = { &frame.origin.x, &frame.origin.y };
  CGFloat *lengths[2] = { &frame.size.width, &frame.size.height };
  CGFloat oldLengths[2] = { oldSize.width, oldSize.height };
  CGFloat newLengths[2] = { size.width, size.height };
  NSUInteger leading[2] = { UIViewAutoresizingFlexibleLeftMargin, UIViewAutoresizingFlexibleTopMargin };
  NSUInteger sizing[2] = { UIViewAutoresizingFlexibleWidth, UIViewAutoresizingFlexibleHeight };
  NSUInteger trailing[2] = { UIViewAutoresizingFlexibleRightMargin, UIViewAutoresizingFlexibleBottomMargin };
  for (NSUInteger axis = 0; axis < 2; axis++) {
    BOOL a = (_uiAutoresizingMask & leading[axis]) != 0;
    BOOL b = (_uiAutoresizingMask & sizing[axis]) != 0;
    BOOL c = (_uiAutoresizingMask & trailing[axis]) != 0;
    NSUInteger count = a + b + c;
    if (!count) continue;
    CGFloat before = MAX(0, *positions[axis]);
    CGFloat length = MAX(0, *lengths[axis]);
    CGFloat after = MAX(0, oldLengths[axis] - before - length);
    CGFloat flexible = a * before + b * length + c * after;
    CGFloat change = newLengths[axis] - oldLengths[axis];
    if (a) *positions[axis] += change * (flexible ? before / flexible : 1.0 / count);
    if (b) *lengths[axis] = MAX(0, length + change * (flexible ? length / flexible : 1.0 / count));
  }
  [self setFrame:frame];
}
- (void)_cancelActiveTouch
{
  if (!_activeTouch) return;
  [_activeTouch setPhase:UITouchPhaseCancelled];
  UIEvent *event = [[[UIEvent alloc] _initWithTouch:_activeTouch nativeEvent:[_activeTouch NSEvent]] autorelease];
  if (!_uiTouchCancelled) [self touchesCancelled:[event allTouches] withEvent:event];
  for (UIGestureRecognizer *recognizer in [self gestureRecognizers])
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
      [recognizer touchesCancelled:[event allTouches] withEvent:event];
  DESTROY(_activeTouch); _uiTouchCancelled = YES;
}
- (void)_deliverMouse:(NSEvent *)native phase:(UITouchPhase)phase
{
  if (phase == UITouchPhaseBegan) {
    DESTROY(_activeTouch); _activeTouch = [[UITouch touchWithNSEvent:native view:self] retain]; _uiTouchCancelled = NO;
  }
  if (!_activeTouch) return;
  [_activeTouch _updateWithNSEvent:native phase:phase];
  UIEvent *event = [[[UIEvent alloc] _initWithTouch:_activeTouch nativeEvent:native] autorelease];
  SEL selector = phase == UITouchPhaseBegan ? @selector(touchesBegan:withEvent:) :
    phase == UITouchPhaseMoved ? @selector(touchesMoved:withEvent:) : @selector(touchesEnded:withEvent:);
  BOOL cancel = NO;
  for (UIView *ancestor = self; ancestor; ancestor = [ancestor superview]) {
    if (![ancestor isKindOfClass:[UIView class]]) continue;
    for (UIGestureRecognizer *recognizer in [(UIView *)ancestor gestureRecognizers]) {
      if (![recognizer isEnabled]) continue;
      if (phase == UITouchPhaseBegan) [recognizer reset];
      UIGestureRecognizerState state = [recognizer state];
      if (state == UIGestureRecognizerStateFailed || state == UIGestureRecognizerStateCancelled || state == UIGestureRecognizerStateEnded) continue;
      [recognizer performSelector:selector withObject:[event allTouches] withObject:event];
      state = [recognizer state];
      if ([recognizer cancelsTouchesInView] && (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateEnded)) cancel = YES;
    }
  }
  if (cancel && !_uiTouchCancelled) { _uiTouchCancelled = YES; [self touchesCancelled:[event allTouches] withEvent:event]; }
  if (!_uiTouchCancelled) [self performSelector:selector withObject:[event allTouches] withObject:event];
  if (phase == UITouchPhaseEnded) DESTROY(_activeTouch);
}
- (void)mouseDown:(NSEvent *)event { [self _deliverMouse:event phase:UITouchPhaseBegan]; }
- (void)mouseDragged:(NSEvent *)event { [self _deliverMouse:event phase:UITouchPhaseMoved]; }
- (void)mouseUp:(NSEvent *)event { [self _deliverMouse:event phase:UITouchPhaseEnded]; }
@end
