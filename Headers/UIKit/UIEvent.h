#ifndef GNUSTEP_UIKIT_UIEVENT_H
#define GNUSTEP_UIKIT_UIEVENT_H

#import <UIKit/UIKitTypes.h>

@class UITouch, UIView, UIWindow;

typedef int UIEventType;
enum {
  UIEventTypeTouches = 0,
  UIEventTypeMotion = 1,
  UIEventTypeRemoteControl = 2,
  UIEventTypePresses = 3,
  UIEventTypeScroll = 10,
  UIEventTypeHover = 11,
  UIEventTypeTransform = 14
};

typedef int UIEventSubtype;
enum {
  UIEventSubtypeNone = 0,
  UIEventSubtypeMotionShake = 1,
  UIEventSubtypeRemoteControlPlay = 100,
  UIEventSubtypeRemoteControlPause = 101,
  UIEventSubtypeRemoteControlStop = 102,
  UIEventSubtypeRemoteControlTogglePlayPause = 103,
  UIEventSubtypeRemoteControlNextTrack = 104,
  UIEventSubtypeRemoteControlPreviousTrack = 105,
  UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
  UIEventSubtypeRemoteControlEndSeekingBackward = 107,
  UIEventSubtypeRemoteControlBeginSeekingForward = 108,
  UIEventSubtypeRemoteControlEndSeekingForward = 109
};

@interface UIEvent : NSObject
{
  NSTimeInterval _timestamp;
  UIEventType _type;
  UIEventSubtype _subtype;
  NSSet *_allTouches;
  id _NSEvent;
}
- (id)initWithType:(UIEventType)type subtype:(UIEventSubtype)subtype timestamp:(NSTimeInterval)timestamp;
- (NSTimeInterval)timestamp;
- (UIEventType)type;
- (UIEventSubtype)subtype;
- (NSSet *)allTouches;
- (NSSet *)touchesForView:(UIView *)view;
- (NSSet *)touchesForWindow:(UIWindow *)window;
@end

#endif
