#import <UIKit/UIResponder.h>

@implementation UIResponder
- (BOOL)canBecomeFirstResponder { return NO; }
- (BOOL)becomeFirstResponder
{
  if ([self canBecomeFirstResponder] == NO || NSApp == nil || [NSApp keyWindow] == nil)
    return NO;
  return [[NSApp keyWindow] makeFirstResponder:(NSResponder *)self];
}
- (BOOL)resignFirstResponder
{
  if (NSApp == nil || [NSApp keyWindow] == nil || [[NSApp keyWindow] firstResponder] != (NSResponder *)self)
    return YES;
  return [[NSApp keyWindow] makeFirstResponder:nil];
}
- (UIResponder *)nextResponder { return nil; }
@end
