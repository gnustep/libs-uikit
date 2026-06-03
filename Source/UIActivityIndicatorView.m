#import <UIKit/UIActivityIndicatorView.h>

@implementation UIActivityIndicatorView
- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
  return [self initWithFrame:NSMakeRect(0, 0, style == UIActivityIndicatorViewStyleWhiteLarge ? 32 : 20, style == UIActivityIndicatorViewStyleWhiteLarge ? 32 : 20)];
}
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _progressIndicator = [[NSProgressIndicator alloc] initWithFrame:[self bounds]];
      [_progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
      [_progressIndicator setIndeterminate:YES];
      [(NSView *)self addSubview:_progressIndicator];
    }
  return self;
}
- (void)dealloc
{
  [_progressIndicator release];
  [super dealloc];
}
- (void)startAnimating { [_progressIndicator startAnimation:self]; }
- (void)stopAnimating { [_progressIndicator stopAnimation:self]; }
- (BOOL)isAnimating { return [_progressIndicator isDisplayedWhenStopped] == NO; }
@end
