#import "UIKitPrivate.h"

@implementation UIView
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _alpha = 1.0;
      _contentMode = UIViewContentModeScaleToFill;
      _uiAutoresizingMask = UIViewAutoresizingNone;
    }
  return self;
}
- (void)dealloc
{
  [_backgroundColor release];
  [super dealloc];
}
- (CGRect)frame { return [super frame]; }
- (void)setFrame:(CGRect)frame { [super setFrame:frame]; }
- (CGRect)bounds { return [super bounds]; }
- (void)setBounds:(CGRect)bounds { [super setBounds:bounds]; }
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
- (void)addSubview:(UIView *)view { [super addSubview:(NSView *)view]; }
- (void)removeFromSuperview { [super removeFromSuperview]; }
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
- (void)setNeedsLayout { [self layoutSubviews]; }
- (void)layoutSubviews {}
- (void)drawRect:(NSRect)rect
{
  if (_backgroundColor != nil)
    {
      [[_backgroundColor NSColor] set];
      NSRectFill(rect);
    }
}
@end
