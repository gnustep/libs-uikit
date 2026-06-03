#import "UIKitPrivate.h"

@implementation UIImageView
- (id)initWithImage:(UIImage *)image
{
  self = [self initWithFrame:NSMakeRect(0, 0, [image size].width, [image size].height)];
  if (self != nil)
    [self setImage:image];
  return self;
}
- (void)dealloc
{
  [_image release];
  [super dealloc];
}
- (UIImage *)image { return _image; }
- (void)setImage:(UIImage *)image
{
  ASSIGN(_image, image);
  [self setNeedsDisplay:YES];
}
- (void)drawRect:(NSRect)rect
{
  [super drawRect:rect];
  [[_image NSImage] drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}
@end
