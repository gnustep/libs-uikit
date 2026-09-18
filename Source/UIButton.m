#import "UIKitPrivate.h"
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
      _titles = [[NSMutableDictionary alloc] init];
      _button = [[NSButton alloc] initWithFrame:[self bounds]];
      [_button setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      [_button setButtonType:NSMomentaryPushInButton];
      [_button setBezelStyle:NSRoundedBezelStyle];
      [_button setTarget:self];
      [_button setAction:@selector(_uiButtonPressed:)];
      [self _addNativeSubview:_button];
    }
  return self;
}
- (void)dealloc
{
  [_titles release];
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
- (void)_updateTitle
{
  UIControlState state = (_enabled ? 0 : UIControlStateDisabled) | (_selected ? UIControlStateSelected : 0) | (_highlighted ? UIControlStateHighlighted : 0);
  NSString *title = [_titles objectForKey:[NSNumber numberWithUnsignedInt:state]];
  if (!title) title = [_titles objectForKey:[NSNumber numberWithUnsignedInt:UIControlStateNormal]];
  [_button setTitle:title ?: @""];
}
- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
  NSNumber *key = [NSNumber numberWithUnsignedInt:state];
  if (title) [_titles setObject:title forKey:key]; else [_titles removeObjectForKey:key];
  [self _updateTitle];
}
- (NSString *)titleForState:(UIControlState)state { return [_titles objectForKey:[NSNumber numberWithUnsignedInt:state]]; }
- (void)setSelected:(BOOL)selected { [super setSelected:selected]; [self _updateTitle]; }
- (void)setHighlighted:(BOOL)highlighted { [super setHighlighted:highlighted]; [self _updateTitle]; }
- (void)setEnabled:(BOOL)enabled
{
  [super setEnabled:enabled];
  [_button setEnabled:enabled];
  [self _updateTitle];
}
- (BOOL)isEnabled { return [_button isEnabled]; }
@end
