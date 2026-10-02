#ifndef GNUSTEP_UIKIT_UISWIPEGESTURERECOGNIZER_H
#define GNUSTEP_UIKIT_UISWIPEGESTURERECOGNIZER_H
#import <UIKit/UIGestureRecognizer.h>
typedef NSUInteger UISwipeGestureRecognizerDirection;
enum { UISwipeGestureRecognizerDirectionRight = 1, UISwipeGestureRecognizerDirectionLeft = 2, UISwipeGestureRecognizerDirectionUp = 4, UISwipeGestureRecognizerDirectionDown = 8 };
@interface UISwipeGestureRecognizer : UIGestureRecognizer
{ UISwipeGestureRecognizerDirection _direction; CGPoint _start; NSTimeInterval _startTime; }
@property(nonatomic) UISwipeGestureRecognizerDirection direction;
@end
#endif
