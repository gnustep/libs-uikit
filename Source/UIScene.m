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
- (void)setActivationState:(UISceneActivationState)state { _activationState = state; }
@end
