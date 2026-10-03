#ifndef GNUSTEP_UIKIT_UICONTENTUNAVAILABLEVIEW_H
#define GNUSTEP_UIKIT_UICONTENTUNAVAILABLEVIEW_H
#import <UIKit/UIView.h>
#import <UIKit/UIContentUnavailableConfiguration.h>
@interface UIContentUnavailableView : UIView <UIContentView>
{ id<UIContentConfiguration> _configuration; UIView *_configuredView; BOOL _scrollEnabled; }
- (id)initWithConfiguration:(UIContentUnavailableConfiguration *)configuration;
@property(nonatomic, copy) id<UIContentConfiguration> configuration;
@property(nonatomic) BOOL scrollEnabled;
@end
#endif
