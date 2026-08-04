#ifndef GNUSTEP_UIKIT_UIWINDOWSCENE_H
#define GNUSTEP_UIKIT_UIWINDOWSCENE_H

#import <UIKit/UIScene.h>

@class UIScreen, UIWindow;

@interface UIWindowScene : UIScene
{
  NSMutableArray *_windows;
  UIScreen *_screen;
}
- (NSArray *)windows;
- (void)addWindow:(UIWindow *)window;
- (void)removeWindow:(UIWindow *)window;
- (UIWindow *)keyWindow;
- (UIScreen *)screen;
@end

#endif
