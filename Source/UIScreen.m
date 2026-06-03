#import <UIKit/UIScreen.h>

@implementation UIScreen
+ (UIScreen *)mainScreen
{
  static UIScreen *screen = nil;
  if (screen == nil)
    screen = [[self alloc] init];
  return screen;
}
- (CGRect)bounds { return [[NSScreen mainScreen] frame]; }
@end
