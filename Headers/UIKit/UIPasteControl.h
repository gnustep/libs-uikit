#ifndef GNUSTEP_UIKIT_UIPASTECONTROL_H
#define GNUSTEP_UIKIT_UIPASTECONTROL_H
#import <UIKit/UIControl.h>
@interface UIPasteControlConfiguration : NSObject <NSCopying> @end
@interface UIPasteControl : UIControl { id _pasteButton; UIResponder *_target; }
- (id)initWithConfiguration:(UIPasteControlConfiguration *)configuration;
@property(nonatomic, assign) UIResponder *target;
@end
#endif
