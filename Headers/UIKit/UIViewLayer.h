#ifndef GNUSTEP_UIKIT_UIVIEWLAYER_H
#define GNUSTEP_UIKIT_UIVIEWLAYER_H
#import <UIKit/UIKitTypes.h>
@class UIView;
/* AppKit drawing bridge for UIView.layer. This is not a Core Animation layer. */
@interface UIViewLayer : NSObject
{ @private UIView *_view; CGFloat _cornerRadius; BOOL _masksToBounds; }
@property(nonatomic) CGFloat cornerRadius;
@property(nonatomic) BOOL masksToBounds;
@end
#endif
