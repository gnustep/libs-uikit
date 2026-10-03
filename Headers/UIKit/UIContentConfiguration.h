#ifndef GNUSTEP_UIKIT_UICONTENTCONFIGURATION_H
#define GNUSTEP_UIKIT_UICONTENTCONFIGURATION_H
#import <UIKit/UIKitTypes.h>
@class UIView;
@protocol UIContentConfiguration <NSObject, NSCopying>
- (UIView *)makeContentView;
- (id<UIContentConfiguration>)updatedConfigurationForState:(id)state;
@end
@protocol UIContentView <NSObject>
@property(nonatomic, copy) id<UIContentConfiguration> configuration;
@end
#endif
