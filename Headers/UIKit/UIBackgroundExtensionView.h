#ifndef GNUSTEP_UIKIT_UIBACKGROUNDEXTENSIONVIEW_H
#define GNUSTEP_UIKIT_UIBACKGROUNDEXTENSIONVIEW_H
#import <UIKit/UIView.h>
@interface UIBackgroundExtensionView : UIView { UIView *_contentView; BOOL _automaticallyPlacesContentView; }
@property(nonatomic, retain) UIView *contentView;
@property(nonatomic) BOOL automaticallyPlacesContentView;
@end
#endif
