#ifndef GNUSTEP_UIKIT_UIIMAGEPICKERCONTROLLER_H
#define GNUSTEP_UIKIT_UIIMAGEPICKERCONTROLLER_H
#import <UIKit/UIViewController.h>
@class UIImagePickerController;
typedef NSInteger UIImagePickerControllerSourceType;
enum { UIImagePickerControllerSourceTypePhotoLibrary, UIImagePickerControllerSourceTypeCamera, UIImagePickerControllerSourceTypeSavedPhotosAlbum };
extern NSString * const UIImagePickerControllerOriginalImage;
extern NSString * const UIImagePickerControllerImageURL;
@protocol UIImagePickerControllerDelegate <NSObject>
@optional
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
@end
@interface UIImagePickerController : UIViewController { UIImagePickerControllerSourceType _sourceType; id<UIImagePickerControllerDelegate> _delegate; }
+ (BOOL)isSourceTypeAvailable:(UIImagePickerControllerSourceType)type;
@property(nonatomic) UIImagePickerControllerSourceType sourceType;
@property(nonatomic, assign) id<UIImagePickerControllerDelegate> delegate;
@end
#endif
