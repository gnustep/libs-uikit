#ifndef GNUSTEP_UIKIT_UISCENECONFIGURATION_H
#define GNUSTEP_UIKIT_UISCENECONFIGURATION_H

#import <UIKit/UIKitTypes.h>

@interface UISceneConfiguration : NSObject <NSCopying>
{
  NSString *_name;
  NSString *_sessionRole;
  Class _delegateClass;
  Class _sceneClass;
  NSArray *_storyboardNames;
}
+ (id)configurationWithName:(NSString *)name sessionRole:(NSString *)sessionRole;
- (id)initWithName:(NSString *)name sessionRole:(NSString *)sessionRole;
- (NSString *)name;
- (void)setName:(NSString *)name;
- (NSString *)sessionRole;
- (void)setSessionRole:(NSString *)sessionRole;
- (Class)delegateClass;
- (void)setDelegateClass:(Class)delegateClass;
- (Class)sceneClass;
- (void)setSceneClass:(Class)sceneClass;
- (NSArray *)storyboardNames;
- (void)setStoryboardNames:(NSArray *)storyboardNames;
@end

#endif
