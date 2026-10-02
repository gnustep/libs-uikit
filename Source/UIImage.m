#import "UIKitPrivate.h"
#import <UIKit/UIImage.h>

@implementation UIImage
+ (UIImage *)systemImageNamed:(NSString *)name
{
  NSDictionary *symbols = @{ @"hand.tap": @"☞", @"doc.text": @"▤", @"photo.artframe": @"▧" };
  NSString *symbol = [symbols objectForKey:name];
  if (!symbol) return nil;
  NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(32,32)] autorelease];
  [image lockFocus];
  [symbol drawAtPoint:NSMakePoint(2,2) withAttributes:@{ NSFontAttributeName:[NSFont systemFontOfSize:28], NSForegroundColorAttributeName:[NSColor controlTextColor] }];
  [image unlockFocus];
  return [[[self alloc] initWithNSImage:image] autorelease];
}
+ (UIImage *)imageNamed:(NSString *)name
{
  NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
  if (path == nil)
    path = [[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]];
  return path == nil ? nil : [self imageWithContentsOfFile:path];
}
+ (UIImage *)imageWithContentsOfFile:(NSString *)path
{
  NSImage *image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
  return image == nil ? nil : [[[self alloc] initWithNSImage:image] autorelease];
}
- (id)initWithNSImage:(NSImage *)image
{
  self = [super init];
  if (self != nil)
    _image = [image retain];
  return self;
}
- (void)dealloc
{
  [_image release];
  [super dealloc];
}
- (NSImage *)NSImage { return _image; }
- (CGSize)size { return [_image size]; }
@end
