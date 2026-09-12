#import <UIKit/UIResponder.h>

@implementation UIResponder
- (BOOL)canBecomeFirstResponder { return NO; }
- (BOOL)becomeFirstResponder
{
  if (_uiChangingFirstResponder) return YES;
  if ([self canBecomeFirstResponder] == NO || NSApp == nil || [NSApp keyWindow] == nil)
    return NO;
  if ([[NSApp keyWindow] firstResponder] == self) return YES;
  _uiChangingFirstResponder = YES;
  BOOL result;
  @try { result = [[NSApp keyWindow] makeFirstResponder:self]; }
  @finally { _uiChangingFirstResponder = NO; }
  return result;
}
- (BOOL)resignFirstResponder
{
  if (_uiChangingFirstResponder) return YES;
  if (NSApp == nil || [NSApp keyWindow] == nil || [[NSApp keyWindow] firstResponder] != (NSResponder *)self)
    return YES;
  _uiChangingFirstResponder = YES;
  BOOL result;
  @try { result = [[NSApp keyWindow] makeFirstResponder:nil]; }
  @finally { _uiChangingFirstResponder = NO; }
  return result;
}
- (UIResponder *)nextResponder { return (UIResponder *)[super nextResponder]; }
@end
