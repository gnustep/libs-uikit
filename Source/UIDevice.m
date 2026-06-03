#import <UIKit/UIDevice.h>

@implementation UIDevice
+ (UIDevice *)currentDevice
{
  static UIDevice *device = nil;
  if (device == nil)
    device = [[self alloc] init];
  return device;
}
- (NSString *)name { return [[NSHost currentHost] localizedName]; }
- (NSString *)systemName { return @"GNUstep"; }
- (NSString *)systemVersion { return [[NSProcessInfo processInfo] operatingSystemVersionString]; }
- (NSString *)model { return @"GNUstep UIKit"; }
@end
