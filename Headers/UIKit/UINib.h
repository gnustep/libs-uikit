#ifndef GNUSTEP_UIKIT_UINIB_H
#define GNUSTEP_UIKIT_UINIB_H

#import <UIKit/UIKitTypes.h>

@interface UINib : NSObject
{
  NSString *_nibName;
  NSBundle *_bundle;
}
+ (UINib *)nibWithNibName:(NSString *)name bundle:(NSBundle *)bundle;
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle;
- (NSArray *)instantiateWithOwner:(id)owner options:(NSDictionary *)options;
@end

#endif
