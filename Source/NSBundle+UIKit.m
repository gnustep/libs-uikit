#import <UIKit/NSBundle+UIKit.h>
#import <UIKit/UINib.h>

@implementation NSBundle (UIKit)
- (BOOL)loadNibNamed:(NSString *)name owner:(id)owner options:(NSDictionary *)options
{
  NSArray *objects = [[UINib nibWithNibName:name bundle:self] instantiateWithOwner:owner options:options];
  return [objects count] != 0;
}
@end
