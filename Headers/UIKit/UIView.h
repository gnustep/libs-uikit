#ifndef GNUSTEP_UIKIT_UIVIEW_H
#define GNUSTEP_UIKIT_UIVIEW_H

#import <UIKit/UIKitTypes.h>

@class UIColor;

@interface UIView : NSView
{
  UIColor *_backgroundColor;
  BOOL _hidden;
  CGFloat _alpha;
  UIViewContentMode _contentMode;
  UIViewAutoresizing _uiAutoresizingMask;
  NSInteger _tag;
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
- (void)layoutSubviews;
@end

#endif
