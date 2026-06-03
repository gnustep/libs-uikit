#ifndef GNUSTEP_UIKIT_UIIMAGE_H
#define GNUSTEP_UIKIT_UIIMAGE_H

#import <UIKit/UIKitTypes.h>

@interface UIImage : NSObject
{
  NSImage *_image;
}
+ (UIImage *)imageNamed:(NSString *)name;
+ (UIImage *)imageWithContentsOfFile:(NSString *)path;
- (id)initWithNSImage:(NSImage *)image;
- (NSImage *)NSImage;
- (CGSize)size;
@end

#endif
