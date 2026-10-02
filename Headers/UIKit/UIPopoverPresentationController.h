#ifndef GNUSTEP_UIKIT_UIPOPOVERPRESENTATIONCONTROLLER_H
#define GNUSTEP_UIKIT_UIPOPOVERPRESENTATIONCONTROLLER_H
#import <UIKit/UIKitTypes.h>
@class UIView;
@interface UIPopoverPresentationController : NSObject
{ UIView *_sourceView; CGRect _sourceRect; }
@property(nonatomic, retain) UIView *sourceView;
@property(nonatomic) CGRect sourceRect;
@end
#endif
