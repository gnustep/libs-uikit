#ifndef GNUSTEP_UIKIT_UISCREEN_H
#define GNUSTEP_UIKIT_UISCREEN_H

#import <UIKit/UIKitTypes.h>

@interface UIScreen : NSObject
+ (UIScreen *)mainScreen;
- (CGRect)bounds;
@end

#endif
