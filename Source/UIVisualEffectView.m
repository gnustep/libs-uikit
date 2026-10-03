#import "UIKitPrivate.h"
extern NSImage *UIKitSoftImage(NSImage *source);
extern NSImage *UIKitSnapshot(UIView *view);
@interface UIGlassEffect (DesktopStyle)
- (UIGlassEffectStyle)_style;
@end
@implementation UIVisualEffect @end
@implementation UIBlurEffect
+ (UIBlurEffect *)effectWithStyle:(UIBlurEffectStyle)style { UIBlurEffect *effect = [[[self alloc] init] autorelease]; effect->_style = style; return effect; }
- (UIBlurEffectStyle)_style { return _style; }
@end
@implementation UIVisualEffectView
- (id)initWithEffect:(UIVisualEffect *)effect { self = [self initWithFrame:CGRectZero]; if (self) self.effect = effect; return self; }
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) { _contentView = [[UIView alloc] initWithFrame:self.bounds]; _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; [self addSubview:_contentView]; }
  return self;
}
- (void)dealloc { [_effect release]; [_contentView release]; [super dealloc]; }
- (UIView *)contentView { return _contentView; }
- (UIVisualEffect *)effect { return _effect; }
- (void)_hoverEvent:(NSEvent *)event state:(UIGestureRecognizerState)state {
  [super _hoverEvent:event state:state];
  if ([_effect isKindOfClass:[UIGlassEffect class]] && [(UIGlassEffect *)_effect isInteractive]) {
    _glassHovered=state != UIGestureRecognizerStateEnded; [self setNeedsDisplay];
  }
}
- (void)drawRect:(CGRect)rect {
  if ([_effect isKindOfClass:[UIGlassEffect class]] || [_effect isKindOfClass:[UIGlassContainerEffect class]]) {
    [NSGraphicsContext saveGraphicsState];
    [[NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:16 yRadius:16] addClip];
    for (UIView *sibling in self.superview.subviews) {
      if (sibling == self) break;
      if (!NSIntersectsRect(sibling.frame,self.frame) || [sibling isHidden]) continue;
      NSImage *image=UIKitSoftImage(UIKitSnapshot(sibling));
      CGRect target=sibling.frame; target.origin.x-=self.frame.origin.x; target.origin.y-=self.frame.origin.y;
      [image drawInRect:target fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.85 respectFlipped:YES hints:nil];
    }
    BOOL clear=[_effect isKindOfClass:[UIGlassEffect class]] && [(UIGlassEffect *)_effect _style] == UIGlassEffectStyleClear;
    NSColor *tint=[NSColor colorWithCalibratedWhite:0.95 alpha:clear ? 0.1 : 0.25];
    if ([_effect isKindOfClass:[UIGlassEffect class]] && [(UIGlassEffect *)_effect tintColor]) tint=[[(UIGlassEffect *)_effect tintColor] NSColor];
    [tint set]; NSRectFillUsingOperation(self.bounds,NSCompositeSourceOver);
    if (_glassHovered) { [[NSColor colorWithCalibratedWhite:1 alpha:0.12] set]; NSRectFillUsingOperation(self.bounds,NSCompositeSourceOver); }
    [[NSColor colorWithCalibratedWhite:1 alpha:_glassHovered ? 0.9 : 0.6] set];
    [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds,1,1) xRadius:16 yRadius:16] stroke];
    [NSGraphicsContext restoreGraphicsState];
  } else [super drawRect:rect];
}
- (void)setEffect:(UIVisualEffect *)effect {
  ASSIGN(_effect,effect);
  BOOL dark = [effect isKindOfClass:[UIBlurEffect class]] && [(UIBlurEffect *)effect _style] == UIBlurEffectStyleDark;
  self.backgroundColor = effect ? [UIColor colorWithWhite:dark ? 0.15 : 0.95 alpha:0.75] : [UIColor clearColor];
}
@end