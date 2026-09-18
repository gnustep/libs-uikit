#ifndef GNUSTEP_UIKIT_UIIMAGE_H
#define GNUSTEP_UIKIT_UIIMAGE_H

#import <UIKit/UIKitTypes.h>

@interface UIImage : NSObject
{
  id _image;
}
+ (UIImage *)imageNamed:(NSString *)name;
+ (UIImage *)imageWithContentsOfFile:(NSString *)path;
- (CGSize)size;
@end

#endif
