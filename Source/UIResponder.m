#import "UIKitPrivate.h"
@implementation UIResponder
- (UIResponder *)nextResponder { return nil; }
- (UIWindow *)_responderWindow { return [[self nextResponder] _responderWindow]; }
- (NSResponder *)_nativeResponder { return nil; }
- (BOOL)canBecomeFirstResponder { return NO; }
- (BOOL)canResignFirstResponder { return YES; }
- (BOOL)isFirstResponder { return [[self _responderWindow] _firstResponder] == self; }
- (BOOL)becomeFirstResponder { return [self isFirstResponder] || ([self canBecomeFirstResponder] && [[self _responderWindow] _makeFirstResponder:self]); }
- (BOOL)resignFirstResponder { return ![self isFirstResponder] || ([self canResignFirstResponder] && [[self _responderWindow] _makeFirstResponder:nil]); }
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender { return [self respondsToSelector:action]; }
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { [[self nextResponder] touchesBegan:touches withEvent:event]; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { [[self nextResponder] touchesMoved:touches withEvent:event]; }
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { [[self nextResponder] touchesEnded:touches withEvent:event]; }
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event { [[self nextResponder] touchesCancelled:touches withEvent:event]; }
@end
