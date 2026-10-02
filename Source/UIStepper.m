#import "UIKitPrivate.h"
@implementation UIStepper
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _stepper = [[NSStepper alloc] initWithFrame:[self bounds]];
    [_stepper setMinValue:0]; [_stepper setMaxValue:100]; [_stepper setIncrement:1];
    [_stepper setValueWraps:NO]; [_stepper setAutorepeat:YES]; [_stepper setContinuous:YES];
    [_stepper setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_stepper setTarget:self]; [_stepper setAction:@selector(_stepperChanged:)];
    [self _addNativeSubview:_stepper];
  }
  return self;
}
- (void)dealloc { [_stepper release]; [super dealloc]; }
- (void)_stepperChanged:(id)sender { [self sendActionsForControlEvents:UIControlEventValueChanged]; }
- (double)value { return [_stepper doubleValue]; }
- (void)setValue:(double)value { [_stepper setDoubleValue:MAX(self.minimumValue, MIN(self.maximumValue, value))]; }
- (double)minimumValue { return [_stepper minValue]; }
- (void)setMinimumValue:(double)value { [_stepper setMinValue:value]; if (self.maximumValue < value) [_stepper setMaxValue:value]; self.value = self.value; }
- (double)maximumValue { return [_stepper maxValue]; }
- (void)setMaximumValue:(double)value { [_stepper setMaxValue:value]; if (self.minimumValue > value) [_stepper setMinValue:value]; self.value = self.value; }
- (double)stepValue { return [_stepper increment]; }
- (void)setStepValue:(double)value {
  if (!isfinite(value) || value <= 0) [NSException raise:NSInvalidArgumentException format:@"stepValue must be positive"];
  [_stepper setIncrement:value];
}
- (BOOL)wraps { return [_stepper valueWraps]; }
- (void)setWraps:(BOOL)value { [_stepper setValueWraps:value]; }
- (BOOL)autorepeat { return [_stepper autorepeat]; }
- (void)setAutorepeat:(BOOL)value { [_stepper setAutorepeat:value]; }
- (BOOL)isContinuous { return [_stepper isContinuous]; }
- (void)setContinuous:(BOOL)value { [_stepper setContinuous:value]; }
- (void)setEnabled:(BOOL)value { [super setEnabled:value]; [_stepper setEnabled:value]; }
- (CGSize)intrinsicContentSize { return CGSizeMake(24, 28); }
@end
