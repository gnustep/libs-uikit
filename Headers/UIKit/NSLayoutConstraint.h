#ifndef GNUSTEP_UIKIT_NSLAYOUTCONSTRAINT_H
#define GNUSTEP_UIKIT_NSLAYOUTCONSTRAINT_H
#import <UIKit/UIKitTypes.h>

/* GNUstep's native constraints operate on NSView. UIKit constraints instead
   operate on the logical view tree. The alias preserves application source. */
#ifndef _NSLayoutConstraint_h_GNUSTEP_GUI_INCLUDE
typedef NSInteger NSLayoutAttribute;
enum { NSLayoutAttributeNotAnAttribute = 0, NSLayoutAttributeLeft = 1,
  NSLayoutAttributeRight, NSLayoutAttributeTop, NSLayoutAttributeBottom,
  NSLayoutAttributeLeading, NSLayoutAttributeTrailing, NSLayoutAttributeWidth,
  NSLayoutAttributeHeight, NSLayoutAttributeCenterX, NSLayoutAttributeCenterY,
  NSLayoutAttributeLastBaseline, NSLayoutAttributeFirstBaseline,
  NSLayoutAttributeBaseline = NSLayoutAttributeLastBaseline };
typedef NSInteger NSLayoutRelation;
enum { NSLayoutRelationLessThanOrEqual = -1, NSLayoutRelationEqual = 0,
  NSLayoutRelationGreaterThanOrEqual = 1 };
#endif
typedef float UILayoutPriority;
static const UILayoutPriority UILayoutPriorityRequired = 1000;
static const UILayoutPriority UILayoutPriorityDefaultHigh = 750;
static const UILayoutPriority UILayoutPriorityDefaultLow = 250;
static const UILayoutPriority UILayoutPriorityFittingSizeLevel = 50;
@class UIView;
@interface UILayoutConstraint : NSObject
{
  id _firstItem, _secondItem;
  NSLayoutAttribute _firstAttribute, _secondAttribute;
  NSLayoutRelation _relation;
  CGFloat _multiplier, _constant;
  UILayoutPriority _priority;
  NSString *_identifier;
  UIView *_container;
}
+ (instancetype)constraintWithItem:(id)item attribute:(NSLayoutAttribute)attribute
  relatedBy:(NSLayoutRelation)relation toItem:(id)other attribute:(NSLayoutAttribute)otherAttribute
  multiplier:(CGFloat)multiplier constant:(CGFloat)constant;
+ (void)activateConstraints:(NSArray *)constraints;
+ (void)deactivateConstraints:(NSArray *)constraints;
@property(nonatomic, getter=isActive) BOOL active;
@property(nonatomic) CGFloat constant;
@property(nonatomic) UILayoutPriority priority;
@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, readonly, assign) id firstItem;
@property(nonatomic, readonly, assign) id secondItem;
@property(nonatomic, readonly) NSLayoutAttribute firstAttribute;
@property(nonatomic, readonly) NSLayoutAttribute secondAttribute;
@property(nonatomic, readonly) NSLayoutRelation relation;
@property(nonatomic, readonly) CGFloat multiplier;
@end
@compatibility_alias NSLayoutConstraint UILayoutConstraint;
#endif
