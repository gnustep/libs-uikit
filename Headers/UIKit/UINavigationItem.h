#ifndef GNUSTEP_UIKIT_UINavigationITEM_H
#define GNUSTEP_UIKIT_UINavigationITEM_H

#import <UIKit/UIKitTypes.h>

@interface UINavigationItem : NSObject
{
  NSString *_title;
}
- (NSString *)title;
- (void)setTitle:(NSString *)title;
@end

#endif
