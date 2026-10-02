#ifndef GNUSTEP_UIKIT_UIVIEW_H
#define GNUSTEP_UIKIT_UIVIEW_H

#import <UIKit/UIResponder.h>
#import <UIKit/UIViewLayer.h>
#import <UIKit/UILayoutGuide.h>
extern const CGFloat UIViewNoIntrinsicMetric;

@class UIColor, UIEvent, UITouch, UIGestureRecognizer, UIWindow;

@interface UIView : UIResponder
{
  NSString *_accessibilityHint;
  BOOL _isAccessibilityElement;
  NSString *_accessibilityLabel, *_accessibilityIdentifier;
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
  UIViewLayer *_layer;
  id _nativeView;
  CGRect _frame, _bounds;
  NSMutableArray *_subviews;
  UIView *_superview;
  BOOL _autoresizesSubviews;
  BOOL _clipsToBounds;
  BOOL _translatesAutoresizingMaskIntoConstraints;
  BOOL _uiNeedsUpdateConstraints;
  BOOL _uiSolvingLayout;
  NSMutableArray *_uiConstraints, *_uiLayoutGuides, *_uiConstraintReferences;
  NSMutableDictionary *_uiAnchors;
  UILayoutGuide *_safeAreaLayoutGuide, *_layoutMarginsGuide;
  UIEdgeInsets _layoutMargins;
  UILayoutPriority _uiHugging[2], _uiCompression[2];
}
@property(nonatomic, copy) NSString *accessibilityHint;
@property(nonatomic) BOOL isAccessibilityElement;
@property(nonatomic, copy) NSString *accessibilityLabel;
@property(nonatomic, copy) NSString *accessibilityIdentifier;
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
@property(nonatomic, readonly) UIViewLayer *layer;
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

@interface UIView (UILayout)
@property(nonatomic) BOOL translatesAutoresizingMaskIntoConstraints;
@property(nonatomic, readonly) NSArray *constraints;
@property(nonatomic, readonly) NSArray *layoutGuides;
@property(nonatomic, readonly) UILayoutGuide *safeAreaLayoutGuide;
@property(nonatomic, readonly) UILayoutGuide *layoutMarginsGuide;
@property(nonatomic, readonly) UIEdgeInsets safeAreaInsets;
@property(nonatomic) UIEdgeInsets layoutMargins;
@property(nonatomic, readonly) NSLayoutXAxisAnchor *leftAnchor;
@property(nonatomic, readonly) NSLayoutXAxisAnchor *rightAnchor;
@property(nonatomic, readonly) NSLayoutXAxisAnchor *leadingAnchor;
@property(nonatomic, readonly) NSLayoutXAxisAnchor *trailingAnchor;
@property(nonatomic, readonly) NSLayoutYAxisAnchor *topAnchor;
@property(nonatomic, readonly) NSLayoutYAxisAnchor *bottomAnchor;
@property(nonatomic, readonly) NSLayoutXAxisAnchor *centerXAnchor;
@property(nonatomic, readonly) NSLayoutYAxisAnchor *centerYAnchor;
@property(nonatomic, readonly) NSLayoutDimension *widthAnchor;
@property(nonatomic, readonly) NSLayoutDimension *heightAnchor;
- (void)addConstraint:(NSLayoutConstraint *)constraint;
- (void)addConstraints:(NSArray *)constraints;
- (void)removeConstraint:(NSLayoutConstraint *)constraint;
- (void)removeConstraints:(NSArray *)constraints;
- (void)addLayoutGuide:(UILayoutGuide *)guide;
- (void)removeLayoutGuide:(UILayoutGuide *)guide;
- (CGSize)intrinsicContentSize;
- (void)invalidateIntrinsicContentSize;
- (UILayoutPriority)contentHuggingPriorityForAxis:(UILayoutConstraintAxis)axis;
- (void)setContentHuggingPriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis;
- (UILayoutPriority)contentCompressionResistancePriorityForAxis:(UILayoutConstraintAxis)axis;
- (void)setContentCompressionResistancePriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis;
- (void)setNeedsUpdateConstraints;
- (BOOL)needsUpdateConstraints;
- (void)updateConstraints;
- (void)updateConstraintsIfNeeded;
@end

#endif
