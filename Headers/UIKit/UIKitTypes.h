#ifndef GNUSTEP_UIKIT_UIKIT_TYPES_H
#define GNUSTEP_UIKIT_UIKIT_TYPES_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#ifndef IBOutlet
#define IBOutlet
#endif
#ifndef IBAction
#define IBAction void
#endif

typedef NSPoint CGPoint;
typedef NSSize CGSize;
typedef NSRect CGRect;
typedef NSEdgeInsets UIEdgeInsets;

#define CGPointMake NSMakePoint
#define CGSizeMake NSMakeSize
#define CGRectMake NSMakeRect
#define CGRectZero NSZeroRect
#define CGSizeZero NSZeroSize
#define CGPointZero NSZeroPoint
#define CGRectGetMinX NSMinX
#define CGRectGetMinY NSMinY
#define CGRectGetMaxX NSMaxX
#define CGRectGetMaxY NSMaxY
#define CGRectGetMidX NSMidX
#define CGRectGetMidY NSMidY
#define CGRectGetWidth NSWidth
#define CGRectGetHeight NSHeight

typedef unsigned int UIViewAutoresizing;
enum {
  UIViewAutoresizingNone = 0,
  UIViewAutoresizingFlexibleLeftMargin = 1 << 0,
  UIViewAutoresizingFlexibleWidth = 1 << 1,
  UIViewAutoresizingFlexibleRightMargin = 1 << 2,
  UIViewAutoresizingFlexibleTopMargin = 1 << 3,
  UIViewAutoresizingFlexibleHeight = 1 << 4,
  UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};

typedef int UIViewContentMode;
enum {
  UIViewContentModeScaleToFill = 0,
  UIViewContentModeScaleAspectFit = 1,
  UIViewContentModeScaleAspectFill = 2,
  UIViewContentModeCenter = 4
};

typedef unsigned int UIControlState;
enum {
  UIControlStateNormal = 0,
  UIControlStateHighlighted = 1 << 0,
  UIControlStateDisabled = 1 << 1,
  UIControlStateSelected = 1 << 2
};

typedef unsigned int UIControlEvents;
enum {
  UIControlEventTouchDown = 1 << 0,
  UIControlEventTouchDownRepeat = 1 << 1,
  UIControlEventTouchDragInside = 1 << 2,
  UIControlEventTouchDragOutside = 1 << 3,
  UIControlEventTouchDragEnter = 1 << 4,
  UIControlEventTouchDragExit = 1 << 5,
  UIControlEventTouchUpInside = 1 << 6,
  UIControlEventTouchUpOutside = 1 << 7,
  UIControlEventTouchCancel = 1 << 8,
  UIControlEventValueChanged = 1 << 12,
  UIControlEventEditingDidBegin = 1 << 16,
  UIControlEventEditingChanged = 1 << 17,
  UIControlEventEditingDidEnd = 1 << 18,
  UIControlEventEditingDidEndOnExit = 1 << 19,
  UIControlEventAllTouchEvents = 0x00000fff,
  UIControlEventAllEditingEvents = 0x000f0000,
  UIControlEventAllEvents = 0xffffffff
};

typedef int UITableViewCellSelectionStyle;
enum {
  UITableViewCellSelectionStyleNone = 0,
  UITableViewCellSelectionStyleBlue = 1,
  UITableViewCellSelectionStyleGray = 2,
  UITableViewCellSelectionStyleDefault = 3
};

typedef int UIKeyboardType;
enum {
  UIKeyboardTypeDefault = 0,
  UIKeyboardTypeASCIICapable = 1,
  UIKeyboardTypeNumbersAndPunctuation = 2,
  UIKeyboardTypeURL = 3,
  UIKeyboardTypeNumberPad = 4,
  UIKeyboardTypePhonePad = 5,
  UIKeyboardTypeEmailAddress = 7
};

typedef int UIReturnKeyType;
enum {
  UIReturnKeyDefault = 0,
  UIReturnKeyGo = 1,
  UIReturnKeySearch = 6,
  UIReturnKeyDone = 9
};

typedef int UIActivityIndicatorViewStyle;
enum {
  UIActivityIndicatorViewStyleWhiteLarge = 0,
  UIActivityIndicatorViewStyleWhite = 1,
  UIActivityIndicatorViewStyleGray = 2
};

typedef int UIInterfaceOrientation;
enum {
  UIInterfaceOrientationPortrait = 1,
  UIInterfaceOrientationPortraitUpsideDown = 2,
  UIInterfaceOrientationLandscapeLeft = 3,
  UIInterfaceOrientationLandscapeRight = 4
};

#endif
