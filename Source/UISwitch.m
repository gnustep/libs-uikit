#import "UIKitPrivate.h"
#import <UIKit/UISwitch.h>

@implementation UISwitch
- (CGSize)intrinsicContentSize { return CGSizeMake(40,24); }
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
      [self _addNativeSubview:_switchButton];
    }
  return self;
}
- (void)dealloc
{
  [_switchButton release];
  [super dealloc];
}
- (void)_uiSwitchChanged:(id)sender { [self sendActionsForControlEvents:UIControlEventValueChanged]; }
- (BOOL)isOn { return [(NSButton *)_switchButton state] == NSOnState; }
- (void)setOn:(BOOL)on { [_switchButton setState:(on ? NSOnState : NSOffState)]; }
- (void)setOn:(BOOL)on animated:(BOOL)animated { [self setOn:on]; }
- (void)setEnabled:(BOOL)enabled
{
  [super setEnabled:enabled];
  [_switchButton setEnabled:enabled];
}
@end
