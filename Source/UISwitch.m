#import <UIKit/UISwitch.h>

@implementation UISwitch
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _switchButton = [[NSButton alloc] initWithFrame:[self bounds]];
      [_switchButton setButtonType:NSSwitchButton];
      [_switchButton setTitle:@""];
      [_switchButton setTarget:self];
      [_switchButton setAction:@selector(_uiSwitchChanged:)];
      [(NSView *)self addSubview:_switchButton];
    }
  return self;
}
- (void)dealloc
{
  [_switchButton release];
  [super dealloc];
}
- (void)_uiSwitchChanged:(id)sender { [self sendActionsForControlEvents:UIControlEventValueChanged]; }
- (BOOL)isOn { return [_switchButton state] == NSOnState; }
- (void)setOn:(BOOL)on { [_switchButton setState:(on ? NSOnState : NSOffState)]; }
- (void)setEnabled:(BOOL)enabled
{
  [super setEnabled:enabled];
  [_switchButton setEnabled:enabled];
}
@end
