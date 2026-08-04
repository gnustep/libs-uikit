#ifndef GNUSTEP_UIKIT_NSINDEXPATH_UIKIT_H
#define GNUSTEP_UIKIT_NSINDEXPATH_UIKIT_H

#import <UIKit/UIKitTypes.h>

@interface NSIndexPath (UIKit)
+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;
+ (NSIndexPath *)indexPathForItem:(NSInteger)item inSection:(NSInteger)section;
- (NSInteger)section;
- (NSInteger)row;
- (NSInteger)item;
@end

#endif
