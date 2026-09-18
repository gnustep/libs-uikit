#import "UIKitPrivate.h"
#import <UIKit/UISceneSession.h>
#import <UIKit/UIScene.h>
#import <UIKit/UISceneConfiguration.h>

NSString *UISceneSessionRoleApplication = @"UIWindowSceneSessionRoleApplication";
NSString *UISceneSessionRoleExternalDisplay = @"UIWindowSceneSessionRoleExternalDisplay";

@implementation UISceneSession
- (id)initWithRole:(NSString *)role configuration:(UISceneConfiguration *)configuration
{
  self = [super init];
  if (self != nil)
    {
      _role = [role copy];
      _configuration = [configuration retain];
      _persistentIdentifier = [[[NSProcessInfo processInfo] globallyUniqueString] copy];
    }
  return self;
}
- (void)dealloc
{
  [_role release];
  [_configuration release];
  [_userInfo release];
  [_persistentIdentifier release];
  [super dealloc];
}
- (NSString *)role { return _role; }
- (UISceneConfiguration *)configuration { return _configuration; }
- (UIScene *)scene { return _scene; }
- (void)setScene:(UIScene *)scene { _scene = scene; }
- (NSDictionary *)userInfo { return _userInfo; }
- (void)setUserInfo:(NSDictionary *)userInfo { ASSIGNCOPY(_userInfo, userInfo); }
- (NSString *)persistentIdentifier { return _persistentIdentifier; }
@end
