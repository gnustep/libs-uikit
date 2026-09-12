#import "UIKitPrivate.h"

@implementation UIFont
+ (UIFont *)_fontWithNSFont:(NSFont *)font
{
  UIFont *uiFont = [[[self alloc] init] autorelease];
  uiFont->_font = [font retain];
  return uiFont;
}
+ (UIFont *)systemFontOfSize:(CGFloat)fontSize { return [self _fontWithNSFont:[NSFont systemFontOfSize:fontSize]]; }
+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize { return [self _fontWithNSFont:[NSFont boldSystemFontOfSize:fontSize]]; }
+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize
{
  NSFont *font = [NSFont fontWithName:fontName size:fontSize];
  return font == nil ? nil : [self _fontWithNSFont:font];
}
- (void)dealloc
{
  [_font release];
  [super dealloc];
}
- (CGFloat)pointSize { return [_font pointSize]; }
- (NSString *)fontName { return [_font fontName]; }
- (CGFloat)lineHeight { return [_font ascender] - [_font descender] + [_font leading]; }
- (NSFont *)NSFont { return _font; }
@end
