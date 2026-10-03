#ifndef GNUSTEP_UIKIT_UIPASTEBOARD_H
#define GNUSTEP_UIKIT_UIPASTEBOARD_H
#import <UIKit/UIKitTypes.h>
@interface UIPasteboard : NSObject { id _pasteboard; }
+ (UIPasteboard *)generalPasteboard;
@property(nonatomic, copy) NSString *string;
@property(nonatomic, readonly) BOOL hasStrings;
@end
#endif
