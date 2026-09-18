#import "UIKitPrivate.h"
#import <UIKit/NSIndexPath+UIKit.h>

#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
#endif

@implementation NSIndexPath (UIKit)
+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section
{
  NSUInteger indexes[2];
  indexes[0] = section;
  indexes[1] = row;
  return [NSIndexPath indexPathWithIndexes:indexes length:2];
}
+ (NSIndexPath *)indexPathForItem:(NSInteger)item inSection:(NSInteger)section
{
  return [self indexPathForRow:item inSection:section];
}
- (NSInteger)section { return [self length] > 0 ? [self indexAtPosition:0] : 0; }
- (NSInteger)row { return [self length] > 1 ? [self indexAtPosition:1] : 0; }
- (NSInteger)item { return [self row]; }
@end

#if defined(__clang__)
#pragma clang diagnostic pop
#endif
