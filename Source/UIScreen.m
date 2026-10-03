#import "UIKitPrivate.h"
#import <UIKit/UIScreen.h>

@implementation UIScreen
+ (UIScreen *)mainScreen
{
  static UIScreen *screen = nil;
  if (screen == nil)
    screen = [[self alloc] init];
  return screen;
}
- (CGRect)bounds
{
#if !defined(__ANDROID__)
  // Desktop apps default to a large iPad's landscape size in logical points.
  if (![[NSUserDefaults standardUserDefaults] boolForKey:@"GSUIKitUseFullScreenSize"])
    return CGRectMake(0, 0, 1366, 1024);
#endif
  return [[NSScreen mainScreen] frame];
}
@end
