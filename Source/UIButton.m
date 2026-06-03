#import <UIKit/UIButton.h>

@implementation UIButton
+ (UIButton *)buttonWithType:(int)buttonType
{
  UIButton *button = [[[self alloc] initWithFrame:NSMakeRect(0, 0, 80, 24)] autorelease];
  return button;
}
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _button = [[NSButton alloc] initWithFrame:[self bounds]];
      [_button setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      [_button setButtonType:NSMomentaryPushInButton];
      [_button setBezelStyle:NSRoundedBezelStyle];
      [_button setTarget:self];
      [_button setAction:@selector(_uiButtonPressed:)];
      [(NSView *)self addSubview:_button];
    }
  return self;
}
- (void)dealloc
{
  [_button release];
  [super dealloc];
}
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events
{
  [super addTarget:target action:action forControlEvents:events];
}
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events
{
  [super removeTarget:target action:action forControlEvents:events];
}
- (void)_uiButtonPressed:(id)sender { [self sendActionsForControlEvents:UIControlEventTouchUpInside]; }
- (void)setTitle:(NSString *)title forState:(UIControlState)state { [_button setTitle:(title == nil ? @"" : title)]; }
- (NSString *)titleForState:(UIControlState)state { return [_button title]; }
- (void)setEnabled:(BOOL)enabled
{
  [super setEnabled:enabled];
  [_button setEnabled:enabled];
}
- (BOOL)isEnabled { return [_button isEnabled]; }
@end
