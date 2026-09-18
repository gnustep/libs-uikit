#ifndef GNUSTEP_UIKIT_BACKEND_H
#define GNUSTEP_UIKIT_BACKEND_H
/* Backend integration only. Ordinary UIKit applications do not import this. */
#define NSTextAlignment GNUstepNSTextAlignment
#define NSTextAlignmentLeft GNUstepNSTextAlignmentLeft
#define NSTextAlignmentCenter GNUstepNSTextAlignmentCenter
#define NSTextAlignmentRight GNUstepNSTextAlignmentRight
#define NSTextAlignmentJustified GNUstepNSTextAlignmentJustified
#define NSTextAlignmentNatural GNUstepNSTextAlignmentNatural
#import <AppKit/AppKit.h>
#undef NSTextAlignment
#undef NSTextAlignmentLeft
#undef NSTextAlignmentCenter
#undef NSTextAlignmentRight
#undef NSTextAlignmentJustified
#undef NSTextAlignmentNatural
#import <UIKit/UIKit.h>
@interface UIView (GNUstepBackend)
- (NSView *)_nativeView;
@end
@interface UIWindow (GNUstepBackend)
- (NSWindow *)_nativeWindow;
- (void)close;
@end
#endif
