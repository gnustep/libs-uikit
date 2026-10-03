#ifndef GNUSTEP_UIKIT_UICOLORWELL_H
#define GNUSTEP_UIKIT_UICOLORWELL_H
#import <UIKit/UIControl.h>
@class UIColor;
@interface UIColorWell : UIControl { id _colorWell; NSString *_title; BOOL _supportsAlpha; }
@property(nonatomic, retain) UIColor *selectedColor;
@property(nonatomic, copy) NSString *title;
@property(nonatomic) BOOL supportsAlpha;
@end
#endif
