#ifndef GNUSTEP_UIKIT_UIALERTVIEW_H
#define GNUSTEP_UIKIT_UIALERTVIEW_H

#import <UIKit/UIKitTypes.h>

@interface UIAlertView : NSObject
{
  NSString *_title;
  NSString *_message;
}
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
- (void)show;
@end

#endif
