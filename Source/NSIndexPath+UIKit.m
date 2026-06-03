#import <UIKit/NSIndexPath+UIKit.h>

@implementation NSIndexPath (UIKit)
+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section
{
  NSUInteger indexes[2];
  indexes[0] = section;
  indexes[1] = row;
  return [NSIndexPath indexPathWithIndexes:indexes length:2];
}
- (NSInteger)row { return [self length] > 1 ? [self indexAtPosition:1] : 0; }
@end
