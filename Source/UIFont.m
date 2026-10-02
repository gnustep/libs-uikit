#import "UIKitPrivate.h"

UIFontTextStyle const UIFontTextStyleTitle1 = @"UICTFontTextStyleTitle1";
UIFontTextStyle const UIFontTextStyleLargeTitle = @"UICTFontTextStyleLargeTitle";
UIFontTextStyle const UIFontTextStyleTitle2 = @"UICTFontTextStyleTitle2";
UIFontTextStyle const UIFontTextStyleTitle3 = @"UICTFontTextStyleTitle3";
UIFontTextStyle const UIFontTextStyleHeadline = @"UICTFontTextStyleHeadline";
UIFontTextStyle const UIFontTextStyleSubheadline = @"UICTFontTextStyleSubheadline";
UIFontTextStyle const UIFontTextStyleBody = @"UICTFontTextStyleBody";
UIFontTextStyle const UIFontTextStyleCallout = @"UICTFontTextStyleCallout";
UIFontTextStyle const UIFontTextStyleFootnote = @"UICTFontTextStyleFootnote";
UIFontTextStyle const UIFontTextStyleCaption1 = @"UICTFontTextStyleCaption1";
UIFontTextStyle const UIFontTextStyleCaption2 = @"UICTFontTextStyleCaption2";
@implementation UIFont
+ (UIFont *)preferredFontForTextStyle:(UIFontTextStyle)style
{
  if ([style isEqual:UIFontTextStyleTitle1]) return [self systemFontOfSize:28];
  if ([style isEqual:UIFontTextStyleLargeTitle]) return [self systemFontOfSize:34];
  if ([style isEqual:UIFontTextStyleTitle2]) return [self systemFontOfSize:22];
  if ([style isEqual:UIFontTextStyleTitle3]) return [self systemFontOfSize:20];
  if ([style isEqual:UIFontTextStyleHeadline]) return [self boldSystemFontOfSize:17];
  if ([style isEqual:UIFontTextStyleSubheadline]) return [self systemFontOfSize:15];
  if ([style isEqual:UIFontTextStyleBody]) return [self systemFontOfSize:17];
  if ([style isEqual:UIFontTextStyleCallout]) return [self systemFontOfSize:16];
  if ([style isEqual:UIFontTextStyleFootnote]) return [self systemFontOfSize:13];
  if ([style isEqual:UIFontTextStyleCaption1]) return [self systemFontOfSize:12];
  if ([style isEqual:UIFontTextStyleCaption2]) return [self systemFontOfSize:11];
  return [self systemFontOfSize:17];
}
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
