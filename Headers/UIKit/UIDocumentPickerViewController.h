#ifndef GNUSTEP_UIKIT_UIDOCUMENTPICKERVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UIDOCUMENTPICKERVIEWCONTROLLER_H
#import <UIKit/UIViewController.h>
@class UIDocumentPickerViewController;
typedef NSInteger UIDocumentPickerMode;
enum { UIDocumentPickerModeImport, UIDocumentPickerModeOpen, UIDocumentPickerModeExportToService, UIDocumentPickerModeMoveToService };
@protocol UIDocumentPickerDelegate <NSObject>
@optional
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray *)URLs;
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller;
@end
@interface UIDocumentPickerViewController : UIViewController { NSArray *_documentTypes; BOOL _allowsMultipleSelection; id<UIDocumentPickerDelegate> _delegate; }
- (id)initWithDocumentTypes:(NSArray *)types inMode:(UIDocumentPickerMode)mode;
@property(nonatomic) BOOL allowsMultipleSelection;
@property(nonatomic, assign) id<UIDocumentPickerDelegate> delegate;
@end
#endif
