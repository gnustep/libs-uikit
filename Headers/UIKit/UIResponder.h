#ifndef GNUSTEP_UIKIT_UIRESPONDER_H
#define GNUSTEP_UIKIT_UIRESPONDER_H
#import <UIKit/UIKitTypes.h>
@class UIEvent;
@interface UIResponder : NSObject
- (void)paste:(id)sender;
- (BOOL)canBecomeFirstResponder;
- (BOOL)canResignFirstResponder;
- (BOOL)isFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (UIResponder *)nextResponder;
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end
#endif
