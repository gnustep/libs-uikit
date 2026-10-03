#ifndef GNUSTEP_UIKIT_UICONTENTUNAVAILABLECONFIGURATION_H
#define GNUSTEP_UIKIT_UICONTENTUNAVAILABLECONFIGURATION_H
#import <UIKit/UIListContentConfiguration.h>
@interface UIContentUnavailableConfiguration : UIListContentConfiguration
+ (instancetype)emptyConfiguration;
+ (instancetype)searchConfiguration;
+ (instancetype)loadingConfiguration;
@end
#endif
