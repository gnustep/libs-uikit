#import "UIKitPrivate.h"
@implementation UIProgressView
- (id)initWithProgressViewStyle:(UIProgressViewStyle)style
{ self = [self initWithFrame:CGRectMake(0,0,150,8)]; if (self) _progressViewStyle = style; return self; }
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _progressIndicator = [[NSProgressIndicator alloc] initWithFrame:[self bounds]];
    [_progressIndicator setIndeterminate:NO];
    [_progressIndicator setMinValue:0]; [_progressIndicator setMaxValue:1];
    [_progressIndicator setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self _addNativeSubview:_progressIndicator];
  }
  return self;
}
- (void)dealloc { [_progressIndicator release]; [super dealloc]; }
- (float)progress { return [_progressIndicator doubleValue]; }
- (void)setProgress:(float)value { [_progressIndicator setDoubleValue:MAX(0, MIN(1, value))]; }
- (void)setProgress:(float)value animated:(BOOL)animated { [self setProgress:value]; }
- (UIProgressViewStyle)progressViewStyle { return _progressViewStyle; }
- (void)setProgressViewStyle:(UIProgressViewStyle)style { _progressViewStyle = style; }
- (CGSize)intrinsicContentSize { return CGSizeMake(UIViewNoIntrinsicMetric, 8); }
@end
