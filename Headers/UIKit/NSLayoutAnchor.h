#ifndef GNUSTEP_UIKIT_NSLAYOUTANCHOR_H
#define GNUSTEP_UIKIT_NSLAYOUTANCHOR_H
#import <UIKit/NSLayoutConstraint.h>
@interface UILayoutAnchor : NSObject
{
  id _item;
  NSLayoutAttribute _attribute;
}
- (NSLayoutConstraint *)constraintEqualToAnchor:(UILayoutAnchor *)anchor;
- (NSLayoutConstraint *)constraintEqualToAnchor:(UILayoutAnchor *)anchor constant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(UILayoutAnchor *)anchor;
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(UILayoutAnchor *)anchor constant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(UILayoutAnchor *)anchor;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(UILayoutAnchor *)anchor constant:(CGFloat)constant;
@end
@interface UILayoutXAxisAnchor : UILayoutAnchor @end
@interface UILayoutYAxisAnchor : UILayoutAnchor @end
@interface UILayoutDimension : UILayoutAnchor
- (NSLayoutConstraint *)constraintEqualToConstant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)multiplier;
- (NSLayoutConstraint *)constraintEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)multiplier constant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintLessThanOrEqualToConstant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)multiplier;
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)multiplier constant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToConstant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)multiplier;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)multiplier constant:(CGFloat)constant;
@end
@compatibility_alias NSLayoutAnchor UILayoutAnchor;
@compatibility_alias NSLayoutXAxisAnchor UILayoutXAxisAnchor;
@compatibility_alias NSLayoutYAxisAnchor UILayoutYAxisAnchor;
@compatibility_alias NSLayoutDimension UILayoutDimension;
#endif
