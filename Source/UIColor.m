#import "UIKitPrivate.h"

@implementation UIColor
+ (UIColor *)_colorWithNSColor:(NSColor *)color
{
  UIColor *uiColor = [[[self alloc] init] autorelease];
  uiColor->_color = [color retain];
  return uiColor;
}
+ (UIColor *)blackColor { return [self _colorWithNSColor:[NSColor blackColor]]; }
+ (UIColor *)whiteColor { return [self _colorWithNSColor:[NSColor whiteColor]]; }
+ (UIColor *)clearColor { return [self _colorWithNSColor:[NSColor clearColor]]; }
+ (UIColor *)redColor { return [self _colorWithNSColor:[NSColor redColor]]; }
+ (UIColor *)greenColor { return [self _colorWithNSColor:[NSColor greenColor]]; }
+ (UIColor *)blueColor { return [self _colorWithNSColor:[NSColor blueColor]]; }
+ (UIColor *)grayColor { return [self _colorWithNSColor:[NSColor grayColor]]; }
+ (UIColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
  return [self _colorWithNSColor:[NSColor colorWithCalibratedWhite:white alpha:alpha]];
}
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
  return [self _colorWithNSColor:[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha]];
}
- (void)dealloc
{
  [_color release];
  [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone { return [self retain]; }
- (NSColor *)NSColor { return _color; }
@end
