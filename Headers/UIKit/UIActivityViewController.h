#ifndef GNUSTEP_UIKIT_UIACTIVITYVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UIACTIVITYVIEWCONTROLLER_H
#import <UIKit/UIViewController.h>
@interface UIActivityViewController : UIViewController
{ NSArray *_activityItems; }
- (id)initWithActivityItems:(NSArray *)items applicationActivities:(NSArray *)activities;
@end
#endif
