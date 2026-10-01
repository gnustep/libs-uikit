/* GNUstep-only screenshot host. The application itself imports UIKit only. */
#import <UIKit/GNUstepUIKit.h>
#import "../Examples/UIKitStudio/StudioApp.h"
#include <stdlib.h>
@interface UIViewController (StudioCaptureAPI)
- (void)selectScreen:(NSInteger)index;
@end
@interface StudioCaptureDelegate : StudioAppDelegate { NSInteger _screen; }
@end
@implementation StudioCaptureDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options
{
  BOOL result = [super application:application didFinishLaunchingWithOptions:options];
  [self performSelector:@selector(capture) withObject:nil afterDelay:0.5]; return result;
}
- (void)capture
{
  [self.window layoutIfNeeded]; [self.window layoutIfNeeded]; [[self.window _nativeWindow] display];
  NSView *view = [self.window _nativeView];
  NSBitmapImageRep *bitmap = [view bitmapImageRepForCachingDisplayInRect:view.bounds];
  [view cacheDisplayInRect:view.bounds toBitmapImageRep:bitmap];
  NSString *directory = [[[NSProcessInfo processInfo] environment] objectForKey:@"UIKIT_STUDIO_SCREENSHOTS"];
  if (!directory) directory = @"/tmp/uikit-studio-screenshots";
  [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
  NSString *name = [[NSArray arrayWithObjects:@"compose",@"library",@"palette",nil] objectAtIndex:_screen];
  NSString *path = [directory stringByAppendingPathComponent:[name stringByAppendingString:@".png"]];
  if (![[bitmap representationUsingType:NSPNGFileType properties:[NSDictionary dictionary]] writeToFile:path atomically:YES]) exit(1);
  if (++_screen == 3) exit(0);
  [self.window.rootViewController selectScreen:_screen];
  [self performSelector:@selector(capture) withObject:nil afterDelay:0.2];
}
@end
int main(int argc, char **argv) { return UIApplicationMain(argc, argv, nil, NSStringFromClass([StudioCaptureDelegate class])); }
