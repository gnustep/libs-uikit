#ifndef GNUSTEP_UIKIT_UIVIEW_H
#define GNUSTEP_UIKIT_UIVIEW_H

#import <UIKit/UIKitTypes.h>

@class UIColor, UIEvent, UITouch, UIGestureRecognizer;

@interface UIView : NSView
{
  UIColor *_backgroundColor;
  BOOL _hidden;
  CGFloat _alpha;
  UIViewContentMode _contentMode;
  UIViewAutoresizing _uiAutoresizingMask;
  NSInteger _tag;
  BOOL _uiNeedsLayout;
  BOOL _userInteractionEnabled;
  BOOL _uiTouchCancelled;
  BOOL _uiChangingFirstResponder;
  NSMutableArray *_gestureRecognizers;
  UITouch *_activeTouch;
  id _owningViewController;
}
- (id)initWithFrame:(CGRect)frame;
- (CGRect)frame;
- (void)setFrame:(CGRect)frame;
- (CGRect)bounds;
- (void)setBounds:(CGRect)bounds;
- (CGPoint)center;
- (void)setCenter:(CGPoint)center;
- (UIColor *)backgroundColor;
- (void)setBackgroundColor:(UIColor *)color;
- (BOOL)isHidden;
- (void)setHidden:(BOOL)hidden;
- (CGFloat)alpha;
- (void)setAlpha:(CGFloat)alpha;
- (UIViewContentMode)contentMode;
- (void)setContentMode:(UIViewContentMode)mode;
- (UIViewAutoresizing)autoresizingMask;
- (void)setAutoresizingMask:(UIViewAutoresizing)mask;
- (NSInteger)tag;
- (void)setTag:(NSInteger)tag;
- (void)addSubview:(UIView *)view;
- (void)removeFromSuperview;
- (NSArray *)subviews;
- (UIView *)superview;
- (UIView *)viewWithTag:(NSInteger)tag;
- (void)setNeedsDisplay;
- (void)setNeedsLayout;
- (void)layoutIfNeeded;
- (void)layoutSubviews;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)sizeToFit;
- (BOOL)isUserInteractionEnabled;
- (void)setUserInteractionEnabled:(BOOL)enabled;
- (NSArray *)gestureRecognizers;
- (void)addGestureRecognizer:(UIGestureRecognizer *)recognizer;
- (void)removeGestureRecognizer:(UIGestureRecognizer *)recognizer;
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
- (BOOL)canBecomeFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

#endif
