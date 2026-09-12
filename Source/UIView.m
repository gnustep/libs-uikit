#import "UIKitPrivate.h"

@implementation UIView
- (id)init { return [self initWithFrame:CGRectZero]; }
- (BOOL)isFlipped { return YES; }
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      [self setAutoresizesSubviews:YES];
      _userInteractionEnabled = YES;
      _gestureRecognizers = [NSMutableArray new];
      _alpha = 1.0;
      _contentMode = UIViewContentModeScaleToFill;
      _uiAutoresizingMask = UIViewAutoresizingNone;
    }
  return self;
}
- (void)dealloc
{
  for (UIGestureRecognizer *recognizer in _gestureRecognizers) [recognizer _setView:nil];
  [_gestureRecognizers release]; [_activeTouch release];
  [_backgroundColor release];
  [super dealloc];
}
- (CGRect)frame { return [super frame]; }
- (void)setFrame:(CGRect)frame { if (!NSEqualRects([self frame], frame)) { [super setFrame:frame]; [self setNeedsLayout]; } }
- (CGRect)bounds { return [super bounds]; }
- (void)setBounds:(CGRect)bounds { if (!NSEqualRects([self bounds], bounds)) { [super setBounds:bounds]; [self setNeedsLayout]; } }
- (CGPoint)center
{
  NSRect frame = [self frame];
  return NSMakePoint(NSMidX(frame), NSMidY(frame));
}
- (void)setCenter:(CGPoint)center
{
  NSRect frame = [self frame];
  frame.origin.x = center.x - frame.size.width / 2.0;
  frame.origin.y = center.y - frame.size.height / 2.0;
  [self setFrame:frame];
}
- (UIColor *)backgroundColor { return _backgroundColor; }
- (void)setBackgroundColor:(UIColor *)color
{
  ASSIGN(_backgroundColor, color);
  [self setNeedsDisplay:YES];
}
- (BOOL)isHidden { return _hidden; }
- (void)setHidden:(BOOL)hidden
{
  _hidden = hidden;
  [super setHidden:hidden];
  if ([[self superview] respondsToSelector:@selector(setNeedsLayout)])
    [[self superview] setNeedsLayout];
}
- (CGFloat)alpha { return _alpha; }
- (void)setAlpha:(CGFloat)alpha
{
  _alpha = alpha;
  if ([self respondsToSelector:@selector(setAlphaValue:)])
    [self setAlphaValue:alpha];
}
- (UIViewContentMode)contentMode { return _contentMode; }
- (void)setContentMode:(UIViewContentMode)mode { _contentMode = mode; }
- (UIViewAutoresizing)autoresizingMask { return _uiAutoresizingMask; }
- (void)setAutoresizingMask:(UIViewAutoresizing)mask
{
  _uiAutoresizingMask = mask;
  [super setAutoresizingMask:UIKitAutoresizingMaskToAppKit(mask)];
}
- (NSInteger)tag { return _tag; }
- (void)setTag:(NSInteger)tag { _tag = tag; }
- (void)addSubview:(UIView *)view { [super addSubview:(NSView *)view]; [self setNeedsLayout]; }
- (void)removeFromSuperview
{
  [[self retain] autorelease]; [self _cancelActiveTouch];
  [super removeFromSuperview];
}
- (NSArray *)subviews { return [super subviews]; }
- (UIView *)superview { return (UIView *)[super superview]; }
- (UIView *)viewWithTag:(NSInteger)tag
{
  NSEnumerator *enumerator;
  UIView *subview;

  if (_tag == tag)
    return self;

  enumerator = [[self subviews] objectEnumerator];
  while ((subview = [enumerator nextObject]) != nil)
    {
      UIView *match = [subview viewWithTag:tag];
      if (match != nil)
        return match;
    }

  return nil;
}
- (void)setNeedsDisplay { [super setNeedsDisplay:YES]; }
- (void)setNeedsLayout
{
  if (!_uiNeedsLayout)
    [self performSelector:@selector(layoutIfNeeded) withObject:nil afterDelay:0];
  _uiNeedsLayout = YES;
  [super setNeedsDisplay:YES];
}
- (void)layoutIfNeeded
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(layoutIfNeeded) object:nil];
  if (_uiNeedsLayout)
    {
      _uiNeedsLayout = NO;
      [self layoutSubviews];
    }
  for (id subview in [[[self subviews] copy] autorelease])
    if ([subview respondsToSelector:@selector(layoutIfNeeded)])
      [subview layoutIfNeeded];
}
- (void)layoutSubviews {}
- (CGSize)sizeThatFits:(CGSize)size { return [self bounds].size; }
- (void)sizeToFit { CGRect frame = [self frame]; frame.size = [self sizeThatFits:frame.size]; [self setFrame:frame]; }
/* Use UIKit coordinates here: GNUstep versions differ in how NSView treats
   vertical autoresizing margins in flipped superviews. */
- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
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
- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
  [super resizeSubviewsWithOldSize:oldSize];
  [self setNeedsLayout];
  [self layoutIfNeeded];
}
- (void)drawRect:(NSRect)rect
{
  [self layoutIfNeeded];
  if (_backgroundColor != nil)
    {
      [[_backgroundColor NSColor] set];
      NSRectFill(rect);
    }
}

- (BOOL)isUserInteractionEnabled { return _userInteractionEnabled; }
- (void)setUserInteractionEnabled:(BOOL)enabled { if (!enabled) [self _cancelActiveTouch]; _userInteractionEnabled = enabled; }
- (NSArray *)gestureRecognizers { return [[_gestureRecognizers copy] autorelease]; }
- (void)addGestureRecognizer:(UIGestureRecognizer *)recognizer
{
  if (!recognizer || [recognizer view] == self) return;
  [[recognizer retain] autorelease];
  [[recognizer view] removeGestureRecognizer:recognizer];
  [_gestureRecognizers addObject:recognizer]; [recognizer _setView:self];
}
- (void)removeGestureRecognizer:(UIGestureRecognizer *)recognizer
{
  if ([recognizer view] != self) return;
  [recognizer _setView:nil]; [_gestureRecognizers removeObjectIdenticalTo:recognizer];
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event { return NSPointInRect(point, [self bounds]); }
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  if (!_userInteractionEnabled || [self isHidden] || _alpha <= 0.01 || ![self pointInside:point withEvent:event]) return nil;
  for (id child in [[self subviews] reverseObjectEnumerator]) {
    if (![child isKindOfClass:[UIView class]]) continue;
    UIView *hit = [child hitTest:[child convertPoint:point fromView:self] withEvent:event];
    if (hit) return hit;
  }
  return self;
}
- (NSView *)hitTest:(NSPoint)point
{
  if (!_userInteractionEnabled || [self isHidden] || _alpha <= 0.01) return nil;
  return [super hitTest:point];
}
- (void)_setOwningViewController:(id)controller { _owningViewController = controller; }
- (NSResponder *)nextResponder { return _owningViewController ?: [super nextResponder]; }
- (BOOL)canBecomeFirstResponder { return NO; }
- (BOOL)acceptsFirstResponder { return [self canBecomeFirstResponder]; }
- (BOOL)becomeFirstResponder
{
  if (_uiChangingFirstResponder || [[self window] firstResponder] == self) return YES;
  if (![self canBecomeFirstResponder] || ![self window]) return NO;
  _uiChangingFirstResponder = YES;
  BOOL result;
  @try { result = [[self window] makeFirstResponder:self]; }
  @finally { _uiChangingFirstResponder = NO; }
  return result;
}
- (BOOL)resignFirstResponder
{
  if (_uiChangingFirstResponder || [[self window] firstResponder] != self) return YES;
  _uiChangingFirstResponder = YES;
  BOOL result;
  @try { result = [[self window] makeFirstResponder:nil]; }
  @finally { _uiChangingFirstResponder = NO; }
  return result;
}
- (void)_forwardTouches:(NSSet *)touches event:(UIEvent *)event selector:(SEL)selector
{
  NSResponder *next = [self nextResponder];
  while (next && ![next respondsToSelector:selector]) next = [next nextResponder];
  if (next) [next performSelector:selector withObject:touches withObject:event];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { [self _forwardTouches:touches event:event selector:_cmd]; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { [self _forwardTouches:touches event:event selector:_cmd]; }
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { [self _forwardTouches:touches event:event selector:_cmd]; }
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event { [self _forwardTouches:touches event:event selector:_cmd]; }
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
  for (NSView *ancestor = self; ancestor; ancestor = [ancestor superview]) {
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
