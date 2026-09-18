#import "UIKitPrivate.h"
#import <UIKit/UISceneConfiguration.h>

@implementation UISceneConfiguration
+ (id)configurationWithName:(NSString *)name sessionRole:(NSString *)sessionRole
{
  return [[[self alloc] initWithName:name sessionRole:sessionRole] autorelease];
}
- (id)initWithName:(NSString *)name sessionRole:(NSString *)sessionRole
{
  self = [super init];
  if (self != nil)
    {
      _name = [name copy];
      _sessionRole = [sessionRole copy];
    }
  return self;
}
- (void)dealloc
{
  [_name release];
  [_sessionRole release];
  [_storyboardNames release];
  [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone
{
  UISceneConfiguration *configuration;

  configuration = [[[self class] allocWithZone:zone] initWithName:_name sessionRole:_sessionRole];
  [configuration setDelegateClass:_delegateClass];
  [configuration setSceneClass:_sceneClass];
  [configuration setStoryboardNames:_storyboardNames];
  return configuration;
}
- (NSString *)name { return _name; }
- (void)setName:(NSString *)name { ASSIGNCOPY(_name, name); }
- (NSString *)sessionRole { return _sessionRole; }
- (void)setSessionRole:(NSString *)sessionRole { ASSIGNCOPY(_sessionRole, sessionRole); }
- (Class)delegateClass { return _delegateClass; }
- (void)setDelegateClass:(Class)delegateClass { _delegateClass = delegateClass; }
- (Class)sceneClass { return _sceneClass; }
- (void)setSceneClass:(Class)sceneClass { _sceneClass = sceneClass; }
- (NSArray *)storyboardNames { return _storyboardNames; }
- (void)setStoryboardNames:(NSArray *)storyboardNames { ASSIGNCOPY(_storyboardNames, storyboardNames); }
@end
