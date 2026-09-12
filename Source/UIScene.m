#import <UIKit/UIScene.h>
#import <UIKit/UISceneSession.h>

@implementation UIScene
- (id)initWithSession:(UISceneSession *)session
{
  self = [super init];
  if (self != nil)
    {
      _session = [session retain];
      _activationState = UISceneActivationStateUnattached;
      [session setScene:self];
    }
  return self;
}
- (void)dealloc
{
  if ([_session scene] == self)
    [_session setScene:nil];
  [_session release];
  [super dealloc];
}
- (UISceneSession *)session { return _session; }
- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }
- (UISceneActivationState)activationState { return _activationState; }
- (void)setActivationState:(UISceneActivationState)state
{
  if (_activationState == state) return;
  UISceneActivationState previous = _activationState;
  if (previous == UISceneActivationStateForegroundActive && [_delegate respondsToSelector:@selector(sceneWillResignActive:)])
    [_delegate sceneWillResignActive:self];
  if ((previous == UISceneActivationStateBackground || previous == UISceneActivationStateUnattached) &&
      (state == UISceneActivationStateForegroundActive || state == UISceneActivationStateForegroundInactive) &&
      [_delegate respondsToSelector:@selector(sceneWillEnterForeground:)]) [_delegate sceneWillEnterForeground:self];
  _activationState = state;
  if (state == UISceneActivationStateForegroundActive && [_delegate respondsToSelector:@selector(sceneDidBecomeActive:)]) [_delegate sceneDidBecomeActive:self];
  if (state == UISceneActivationStateBackground && [_delegate respondsToSelector:@selector(sceneDidEnterBackground:)]) [_delegate sceneDidEnterBackground:self];
  if (state == UISceneActivationStateUnattached && [_delegate respondsToSelector:@selector(sceneDidDisconnect:)]) [_delegate sceneDidDisconnect:self];
}
@end
