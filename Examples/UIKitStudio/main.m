#import "StudioApp.h"

int main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  int result = UIApplicationMain(argc, argv, nil, NSStringFromClass([StudioAppDelegate class]));
  [pool drain];
  return result;
}
