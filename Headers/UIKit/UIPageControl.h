#ifndef GNUSTEP_UIKIT_UIPAGECONTROL_H
#define GNUSTEP_UIKIT_UIPAGECONTROL_H
#import <UIKit/UIControl.h>
@class UIColor;
@interface UIPageControl : UIControl
{ NSInteger _numberOfPages, _currentPage; UIColor *_pageIndicatorTintColor, *_currentPageIndicatorTintColor; }
@property(nonatomic) NSInteger numberOfPages;
@property(nonatomic) NSInteger currentPage;
@property(nonatomic, retain) UIColor *pageIndicatorTintColor;
@property(nonatomic, retain) UIColor *currentPageIndicatorTintColor;
@end
#endif
