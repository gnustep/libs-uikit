#ifndef GNUSTEP_UIKIT_UISCENESESSION_H
#define GNUSTEP_UIKIT_UISCENESESSION_H

#import <UIKit/UIKitTypes.h>

@class UIScene, UISceneConfiguration;

extern NSString *UISceneSessionRoleApplication;
extern NSString *UISceneSessionRoleExternalDisplay;

@interface UISceneSession : NSObject
{
  NSString *_role;
  UISceneConfiguration *_configuration;
  UIScene *_scene;
  NSDictionary *_userInfo;
  NSString *_persistentIdentifier;
}
- (id)initWithRole:(NSString *)role configuration:(UISceneConfiguration *)configuration;
- (NSString *)role;
- (UISceneConfiguration *)configuration;
- (UIScene *)scene;
- (void)setScene:(UIScene *)scene;
- (NSDictionary *)userInfo;
- (void)setUserInfo:(NSDictionary *)userInfo;
- (NSString *)persistentIdentifier;
@end

#endif
