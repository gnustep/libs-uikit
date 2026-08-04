#ifndef GNUSTEP_UIKIT_UIPRESSESEVENT_H
#define GNUSTEP_UIKIT_UIPRESSESEVENT_H

#import <UIKit/UIEvent.h>

@class UIResponder;

@interface UIPressesEvent : UIEvent
{
  NSSet *_allPresses;
}
+ (UIPressesEvent *)eventWithPresses:(NSSet *)presses;
- (id)initWithPresses:(NSSet *)presses timestamp:(NSTimeInterval)timestamp;
- (NSSet *)allPresses;
- (NSSet *)pressesForResponder:(UIResponder *)responder;
@end

#endif
