#import "UIKitPrivate.h"
@implementation UIGlassEffect
+ (instancetype)effectWithStyle:(UIGlassEffectStyle)style { UIGlassEffect *effect=[[[self alloc] init] autorelease]; effect->_style=style; return effect; }
@synthesize tintColor=_tintColor, interactive=_interactive;
- (void)dealloc { [_tintColor release]; [super dealloc]; }
- (UIGlassEffectStyle)_style { return _style; }
@end
@implementation UIGlassContainerEffect
@synthesize spacing=_spacing;
@end
/* Downsampled sibling snapshots provide a desktop backdrop approximation.
   No private compositor or screen capture is used. */
NSImage *UIKitSoftImage(NSImage *source) {
  if (!source) return nil;
  NSImage *small=[[[NSImage alloc] initWithSize:NSMakeSize(48,48)] autorelease];
  [small lockFocus]; [source drawInRect:NSMakeRect(0,0,48,48) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1]; [small unlockFocus];
  NSBitmapImageRep *input=[[[NSBitmapImageRep alloc] initWithData:[small TIFFRepresentation]] autorelease];
  if (!input || input.bitsPerSample != 8 || input.isPlanar) return small;
  NSBitmapImageRep *output=[[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:48 pixelsHigh:48 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0] autorelease];
  for (NSInteger y=0;y<48;y++) for(NSInteger x=0;x<48;x++) {
    NSUInteger sums[4]={0,0,0,0}, count=0;
    for(NSInteger j=MAX(0,y-2);j<=MIN(47,y+2);j++) for(NSInteger i=MAX(0,x-2);i<=MIN(47,x+2);i++) {
      NSUInteger pixel[5]={0,0,0,255,0}; [input getPixel:pixel atX:i y:j];
      for (NSInteger c=0;c<3;c++) sums[c]+=pixel[c]; sums[3]+=input.hasAlpha ? pixel[input.samplesPerPixel-1] : 255; count++;
    }
    for(NSInteger c=0;c<4;c++) sums[c]/=count; [output setPixel:sums atX:x y:y];
  }
  NSImage *result=[[[NSImage alloc] initWithSize:NSMakeSize(48,48)] autorelease]; [result addRepresentation:output]; return result;
}
NSImage *UIKitSnapshot(UIView *view) {
  if (view.bounds.size.width <= 0 || view.bounds.size.height <= 0) return nil;
  NSView *native=[view _nativeView];
  /* GNUstep caching reads existing pixels; paint the content before sampling. */
  [native displayRectIgnoringOpacity:native.bounds];
  NSBitmapImageRep *rep=[native bitmapImageRepForCachingDisplayInRect:native.bounds];
  if(!rep) return nil; [native cacheDisplayInRect:native.bounds toBitmapImageRep:rep];
  NSImage *image=[[[NSImage alloc] initWithSize:view.bounds.size] autorelease]; [image addRepresentation:rep]; return image;
}
@implementation UIBackgroundExtensionView
- (id)initWithFrame:(CGRect)frame { self=[super initWithFrame:frame]; if(self) _automaticallyPlacesContentView=YES; return self; }
- (void)dealloc { [_contentView release]; [super dealloc]; }
- (UIView *)contentView { return _contentView; }
- (void)setContentView:(UIView *)view { if(view==_contentView) return; [_contentView removeFromSuperview]; ASSIGN(_contentView,view); if(view) [self addSubview:view]; [self setNeedsLayout]; }
- (BOOL)automaticallyPlacesContentView { return _automaticallyPlacesContentView; }
- (void)setAutomaticallyPlacesContentView:(BOOL)value { _automaticallyPlacesContentView=value; [self setNeedsLayout]; }
- (void)layoutSubviews { [super layoutSubviews]; if (_automaticallyPlacesContentView) { UIEdgeInsets insets=self.safeAreaInsets; _contentView.frame=CGRectMake(insets.left,insets.top,MAX(0,self.bounds.size.width-insets.left-insets.right),MAX(0,self.bounds.size.height-insets.top-insets.bottom)); } [self setNeedsDisplay]; }
- (void)drawRect:(CGRect)rect {
  [super drawRect:rect]; NSImage *image=UIKitSoftImage(UIKitSnapshot(_contentView));
  [image drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.6];
}
@end