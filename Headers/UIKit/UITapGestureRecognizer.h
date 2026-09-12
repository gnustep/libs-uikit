#ifndef GNUSTEP_UIKIT_UITAPGESTURERECOGNIZER_H
#define GNUSTEP_UIKIT_UITAPGESTURERECOGNIZER_H
#import <UIKit/UIGestureRecognizer.h>
@interface UITapGestureRecognizer : UIGestureRecognizer
{
  NSUInteger _numberOfTapsRequired;
  CGPoint _start;
}
- (NSUInteger)numberOfTapsRequired;
- (void)setNumberOfTapsRequired:(NSUInteger)count;
@end
#endif
