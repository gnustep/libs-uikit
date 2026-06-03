#ifndef GNUSTEP_UIKIT_UIRESPONDER_H
#define GNUSTEP_UIKIT_UIRESPONDER_H

#import <UIKit/UIKitTypes.h>

@interface UIResponder : NSObject
{
}
- (BOOL)canBecomeFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (UIResponder *)nextResponder;
@end

#endif
