#ifndef GNUSTEP_UIKIT_UIVIEW_H
#define GNUSTEP_UIKIT_UIVIEW_H

#import <UIKit/UIResponder.h>

@class UIColor, UIEvent, UITouch, UIGestureRecognizer, UIWindow;

@interface UIView : UIResponder
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

  NSMutableArray *_gestureRecognizers;
  UITouch *_activeTouch;
  id _owningViewController;
  id _nativeView;
  CGRect _frame, _bounds;
  NSMutableArray *_subviews;
  UIView *_superview;
  BOOL _autoresizesSubviews;
  BOOL _clipsToBounds;
}
- (id)initWithCoder:(NSCoder *)coder;
- (UIWindow *)window;
- (BOOL)autoresizesSubviews;
- (void)setAutoresizesSubviews:(BOOL)value;
- (BOOL)clipsToBounds;
- (void)setClipsToBounds:(BOOL)value;
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index;
- (void)insertSubview:(UIView *)view belowSubview:(UIView *)sibling;
- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)sibling;
- (void)bringSubviewToFront:(UIView *)view;
- (void)sendSubviewToBack:(UIView *)view;
- (BOOL)isDescendantOfView:(UIView *)view;
- (CGPoint)convertPoint:(CGPoint)point toView:(UIView *)view;
- (CGPoint)convertPoint:(CGPoint)point fromView:(UIView *)view;
- (CGRect)convertRect:(CGRect)rect toView:(UIView *)view;
- (CGRect)convertRect:(CGRect)rect fromView:(UIView *)view;
- (void)willMoveToSuperview:(UIView *)view;
- (void)didMoveToSuperview;
- (void)willMoveToWindow:(UIWindow *)window;
- (void)didMoveToWindow;
- (void)didAddSubview:(UIView *)view;
- (void)willRemoveSubview:(UIView *)view;
- (void)drawRect:(CGRect)rect;
- (void)setNeedsDisplayInRect:(CGRect)rect;
- (BOOL)endEditing:(BOOL)force;
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
@end

#endif
