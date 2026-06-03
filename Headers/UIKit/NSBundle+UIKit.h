#ifndef GNUSTEP_UIKIT_NSBundle_UIKIT_H
#define GNUSTEP_UIKIT_NSBundle_UIKIT_H

#import <UIKit/UIKitTypes.h>

@interface NSBundle (UIKit)
- (BOOL)loadNibNamed:(NSString *)name owner:(id)owner options:(NSDictionary *)options;
@end

#endif
