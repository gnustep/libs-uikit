#import <UIKit/UIKitTypes.h>

@implementation NSValue (UIKitGeometry)
+ (NSValue *)valueWithCGPoint:(CGPoint)point { return [self valueWithPoint:point]; }
+ (NSValue *)valueWithCGSize:(CGSize)size { return [self valueWithSize:size]; }
+ (NSValue *)valueWithCGRect:(CGRect)rect { return [self valueWithRect:rect]; }
- (CGPoint)CGPointValue { return [self pointValue]; }
- (CGSize)CGSizeValue { return [self sizeValue]; }
- (CGRect)CGRectValue { return [self rectValue]; }
@end
