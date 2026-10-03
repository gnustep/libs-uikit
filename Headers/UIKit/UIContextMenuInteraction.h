#ifndef GNUSTEP_UIKIT_UICONTEXTMENUINTERACTION_H
#define GNUSTEP_UIKIT_UICONTEXTMENUINTERACTION_H
#import <UIKit/UIInteraction.h>
#import <UIKit/UIMenu.h>
@class UIViewController, UIContextMenuInteraction;
DEFINE_BLOCK_TYPE_NO_ARGS(UIContextMenuContentPreviewProvider, UIViewController *);
DEFINE_BLOCK_TYPE(UIContextMenuActionProvider, UIMenu *, NSArray *);
@interface UIContextMenuConfiguration : NSObject { UIContextMenuActionProvider _actionProvider; }
+ (instancetype)configurationWithIdentifier:(id<NSCopying>)identifier previewProvider:(UIContextMenuContentPreviewProvider)previewProvider actionProvider:(UIContextMenuActionProvider)actionProvider;
@end
@protocol UIContextMenuInteractionDelegate <NSObject>
- (UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction configurationForMenuAtLocation:(CGPoint)location;
@end
@interface UIContextMenuInteraction : NSObject <UIInteraction> { UIView *_view; id<UIContextMenuInteractionDelegate> _delegate; }
- (id)initWithDelegate:(id<UIContextMenuInteractionDelegate>)delegate;
@property(nonatomic, readonly, assign) id<UIContextMenuInteractionDelegate> delegate;
@end
#endif
