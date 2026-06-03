#ifndef GNUSTEP_UIKIT_UIDEVICE_H
#define GNUSTEP_UIKIT_UIDEVICE_H

#import <UIKit/UIKitTypes.h>

@interface UIDevice : NSObject
+ (UIDevice *)currentDevice;
- (NSString *)name;
- (NSString *)systemName;
- (NSString *)systemVersion;
- (NSString *)model;
@end

#endif
