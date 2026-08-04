#import <UIKit/UIPress.h>
#import <UIKit/UIResponder.h>

static UIPressType UIKitPressTypeForNSEvent(NSEvent *event)
{
  NSString *characters = [event charactersIgnoringModifiers];
  unichar key;

  if ([characters length] == 0)
    return UIPressTypeSelect;

  key = [characters characterAtIndex:0];
  switch (key)
    {
      case NSUpArrowFunctionKey: return UIPressTypeUpArrow;
      case NSDownArrowFunctionKey: return UIPressTypeDownArrow;
      case NSLeftArrowFunctionKey: return UIPressTypeLeftArrow;
      case NSRightArrowFunctionKey: return UIPressTypeRightArrow;
      case NSPageUpFunctionKey: return UIPressTypePageUp;
      case NSPageDownFunctionKey: return UIPressTypePageDown;
      default: return UIPressTypeSelect;
    }
}

@implementation UIPress
+ (UIPress *)pressWithNSEvent:(NSEvent *)event responder:(UIResponder *)responder
{
  UIPress *press;

  press = [[[self alloc] initWithType:UIKitPressTypeForNSEvent(event)
                                phase:UIPressPhaseBegan
                            timestamp:[event timestamp]
                            responder:responder] autorelease];
  press->_characters = [[event characters] copy];
  press->_charactersIgnoringModifiers = [[event charactersIgnoringModifiers] copy];
  press->_modifierFlags = [event modifierFlags];
  press->_NSEvent = [event retain];
  return press;
}
- (id)initWithType:(UIPressType)type
             phase:(UIPressPhase)phase
         timestamp:(NSTimeInterval)timestamp
         responder:(UIResponder *)responder
{
  self = [super init];
  if (self != nil)
    {
      _type = type;
      _phase = phase;
      _timestamp = timestamp;
      _responder = [responder retain];
    }
  return self;
}
- (void)dealloc
{
  [_responder release];
  [_characters release];
  [_charactersIgnoringModifiers release];
  [_NSEvent release];
  [super dealloc];
}
- (NSTimeInterval)timestamp { return _timestamp; }
- (UIPressPhase)phase { return _phase; }
- (void)setPhase:(UIPressPhase)phase { _phase = phase; }
- (UIPressType)type { return _type; }
- (UIResponder *)responder { return _responder; }
- (NSString *)characters { return _characters; }
- (NSString *)charactersIgnoringModifiers { return _charactersIgnoringModifiers; }
- (NSUInteger)modifierFlags { return _modifierFlags; }
- (NSEvent *)NSEvent { return _NSEvent; }
@end
