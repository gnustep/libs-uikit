#import "UIKitPrivate.h"
#import <UIKit/UIActivityIndicatorView.h>

@implementation UIActivityIndicatorView
- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
  CGFloat size = (style == UIActivityIndicatorViewStyleWhiteLarge || style == UIActivityIndicatorViewStyleLarge) ? 32 : 20;
  self = [self initWithFrame:CGRectMake(0,0,size,size)];
  if (self) _indicatorSize = size;
  return self;
}
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _indicatorSize = 20;
      _progressIndicator = [[NSProgressIndicator alloc] initWithFrame:[self bounds]];
      [(NSProgressIndicator *)_progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
      [_progressIndicator setIndeterminate:YES];
      [self _addNativeSubview:_progressIndicator];
      _hidesWhenStopped = YES; [self setHidden:YES];
    }
  return self;
}
- (void)dealloc
{
  [_progressIndicator release];
  [super dealloc];
}
- (void)startAnimating { _animating = YES; [self setHidden:NO]; [_progressIndicator startAnimation:self]; }
- (void)stopAnimating { _animating = NO; [_progressIndicator stopAnimation:self]; if (_hidesWhenStopped) [self setHidden:YES]; }
- (BOOL)isAnimating { return _animating; }
- (BOOL)hidesWhenStopped { return _hidesWhenStopped; }
- (void)setHidesWhenStopped:(BOOL)value { _hidesWhenStopped = value; if (!_animating) self.hidden = value; }
- (void)layoutSubviews {
  [super layoutSubviews]; CGFloat size = MIN(_indicatorSize,MIN(self.bounds.size.width,self.bounds.size.height));
  [_progressIndicator setFrame:CGRectMake((self.bounds.size.width-size)/2,(self.bounds.size.height-size)/2,size,size)];
}
- (CGSize)intrinsicContentSize { return CGSizeMake(_indicatorSize,_indicatorSize); }
@end
