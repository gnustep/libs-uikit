#import <UIKit/UIResponder.h>

@implementation UIResponder
- (BOOL)canBecomeFirstResponder { return NO; }
- (BOOL)becomeFirstResponder { return NO; }
- (BOOL)resignFirstResponder { return YES; }
- (UIResponder *)nextResponder { return nil; }
@end
