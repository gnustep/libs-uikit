#ifndef GNUSTEP_UIKIT_UILAYOUTGUIDE_H
#define GNUSTEP_UIKIT_UILAYOUTGUIDE_H
#import <UIKit/NSLayoutAnchor.h>
@class UIView;
@interface UILayoutGuide : NSObject
{
  UIView *_owningView;
  CGRect _layoutFrame;
  NSString *_identifier;
  NSMutableDictionary *_uiAnchors;
  NSMutableArray *_uiConstraintReferences;
}
@property(nonatomic, assign) UIView *owningView;
@property(nonatomic, readonly) CGRect layoutFrame;
@property(nonatomic, copy) NSString *identifier;
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
@end
#endif
