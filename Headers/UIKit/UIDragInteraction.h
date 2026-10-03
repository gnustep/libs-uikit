#ifndef GNUSTEP_UIKIT_UIDRAGINTERACTION_H
#define GNUSTEP_UIKIT_UIDRAGINTERACTION_H
#import <UIKit/UIInteraction.h>
@class UIDragInteraction, UIDropInteraction;
@interface UIDragItem : NSObject { NSItemProvider *_itemProvider; id _localObject; }
- (id)initWithItemProvider:(NSItemProvider *)provider;
@property(nonatomic, readonly) NSItemProvider *itemProvider;
@property(nonatomic, retain) id localObject;
@end
@protocol UIDragDropSession <NSObject>
@property(nonatomic, readonly, copy) NSArray *items;
- (CGPoint)locationInView:(UIView *)view;
- (BOOL)hasItemsConformingToTypeIdentifiers:(NSArray *)types;
@end
@protocol UIDragSession <UIDragDropSession> @end
DEFINE_BLOCK_TYPE(UIDropSessionObjectsCompletion, void, NSArray *);
@protocol UIDropSession <UIDragDropSession>
@property(nonatomic, readonly) id<UIDragSession> localDragSession;
- (NSProgress *)loadObjectsOfClass:(Class)objectClass completion:(UIDropSessionObjectsCompletion)completion;
@end
@protocol UIDragInteractionDelegate <NSObject>
- (NSArray *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session;
@end
@interface UIDragInteraction : NSObject <UIInteraction> { UIView *_view; id<UIDragInteractionDelegate> _delegate; BOOL _enabled; }
- (id)initWithDelegate:(id<UIDragInteractionDelegate>)delegate;
@property(nonatomic, readonly, assign) id<UIDragInteractionDelegate> delegate;
@property(nonatomic, getter=isEnabled) BOOL enabled;
@end

typedef NSUInteger UIDropOperation;
enum { UIDropOperationCancel=0, UIDropOperationForbidden=1, UIDropOperationCopy=2, UIDropOperationMove=3 };
@interface UIDropProposal : NSObject { UIDropOperation _operation; }
- (id)initWithDropOperation:(UIDropOperation)operation;
@property(nonatomic, readonly) UIDropOperation operation;
@end
@protocol UIDropInteractionDelegate <NSObject>
@optional
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session;
- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session;
- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session;
@end
@interface UIDropInteraction : NSObject <UIInteraction> { UIView *_view; id<UIDropInteractionDelegate> _delegate; }
- (id)initWithDelegate:(id<UIDropInteractionDelegate>)delegate;
@property(nonatomic, readonly, assign) id<UIDropInteractionDelegate> delegate;
@end
#endif
