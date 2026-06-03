#import <UIKit/UISlider.h>

@implementation UISlider
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _slider = [[NSSlider alloc] initWithFrame:[self bounds]];
      [_slider setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      [_slider setMinValue:0.0];
      [_slider setMaxValue:1.0];
      [_slider setTarget:self];
      [_slider setAction:@selector(_uiSliderChanged:)];
      [(NSView *)self addSubview:_slider];
    }
  return self;
}
- (void)dealloc
{
  [_slider release];
  [super dealloc];
}
- (void)_uiSliderChanged:(id)sender { [self sendActionsForControlEvents:UIControlEventValueChanged]; }
- (float)value { return [_slider floatValue]; }
- (void)setValue:(float)value { [_slider setFloatValue:value]; }
- (float)minimumValue { return [_slider minValue]; }
- (void)setMinimumValue:(float)value { [_slider setMinValue:value]; }
- (float)maximumValue { return [_slider maxValue]; }
- (void)setMaximumValue:(float)value { [_slider setMaxValue:value]; }
- (void)setEnabled:(BOOL)enabled
{
  [super setEnabled:enabled];
  [_slider setEnabled:enabled];
}
@end
