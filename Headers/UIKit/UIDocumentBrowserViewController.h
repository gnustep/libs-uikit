#ifndef GNUSTEP_UIKIT_UIDOCUMENTBROWSERVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UIDOCUMENTBROWSERVIEWCONTROLLER_H
#import <UIKit/UIViewController.h>
@class UIDocumentBrowserViewController;
@protocol UIDocumentBrowserViewControllerDelegate <NSObject>
@optional
- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didPickDocumentsAtURLs:(NSArray *)URLs;
@end
@interface UIDocumentBrowserViewController : UIViewController { NSArray *_allowedContentTypes; BOOL _allowsPickingMultipleItems; id<UIDocumentBrowserViewControllerDelegate> _delegate; }
- (id)initForOpeningFilesWithContentTypes:(NSArray *)types;
@property(nonatomic) BOOL allowsPickingMultipleItems;
@property(nonatomic, assign) id<UIDocumentBrowserViewControllerDelegate> delegate;
@end
#endif
