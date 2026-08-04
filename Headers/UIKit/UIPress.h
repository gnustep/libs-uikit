#ifndef GNUSTEP_UIKIT_UIPRESS_H
#define GNUSTEP_UIKIT_UIPRESS_H

#import <UIKit/UIKitTypes.h>

@class UIResponder;

typedef int UIPressPhase;
enum {
  UIPressPhaseBegan = 0,
  UIPressPhaseChanged = 1,
  UIPressPhaseStationary = 2,
  UIPressPhaseEnded = 3,
  UIPressPhaseCancelled = 4
};

typedef int UIPressType;
enum {
  UIPressTypeUpArrow = 0,
  UIPressTypeDownArrow = 1,
  UIPressTypeLeftArrow = 2,
  UIPressTypeRightArrow = 3,
  UIPressTypeSelect = 4,
  UIPressTypeMenu = 5,
  UIPressTypePlayPause = 6,
  UIPressTypePageUp = 30,
  UIPressTypePageDown = 31
};

@interface UIPress : NSObject
{
  NSTimeInterval _timestamp;
  UIPressPhase _phase;
  UIPressType _type;
  UIResponder *_responder;
  NSString *_characters;
  NSString *_charactersIgnoringModifiers;
  NSUInteger _modifierFlags;
  NSEvent *_NSEvent;
}
+ (UIPress *)pressWithNSEvent:(NSEvent *)event responder:(UIResponder *)responder;
- (id)initWithType:(UIPressType)type
             phase:(UIPressPhase)phase
         timestamp:(NSTimeInterval)timestamp
         responder:(UIResponder *)responder;
- (NSTimeInterval)timestamp;
- (UIPressPhase)phase;
- (void)setPhase:(UIPressPhase)phase;
- (UIPressType)type;
- (UIResponder *)responder;
- (NSString *)characters;
- (NSString *)charactersIgnoringModifiers;
- (NSUInteger)modifierFlags;
- (NSEvent *)NSEvent;
@end

#endif
