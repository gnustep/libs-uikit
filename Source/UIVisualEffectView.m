#import "UIKitPrivate.h"
@implementation UIVisualEffect @end
@implementation UIBlurEffect
+ (UIBlurEffect *)effectWithStyle:(UIBlurEffectStyle)style { UIBlurEffect *effect = [[[self alloc] init] autorelease]; effect->_style = style; return effect; }
- (UIBlurEffectStyle)_style { return _style; }
@end
@implementation UIVisualEffectView
- (id)initWithEffect:(UIVisualEffect *)effect { self = [self initWithFrame:CGRectZero]; if (self) self.effect = effect; return self; }
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) { _contentView = [[UIView alloc] initWithFrame:self.bounds]; _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; [self addSubview:_contentView]; }
  return self;
}
- (void)dealloc { [_effect release]; [_contentView release]; [super dealloc]; }
- (UIView *)contentView { return _contentView; }
- (UIVisualEffect *)effect { return _effect; }
- (void)setEffect:(UIVisualEffect *)effect {
  ASSIGN(_effect,effect);
  BOOL dark = [effect isKindOfClass:[UIBlurEffect class]] && [(UIBlurEffect *)effect _style] == UIBlurEffectStyleDark;
  self.backgroundColor = effect ? [UIColor colorWithWhite:dark ? 0.15 : 0.95 alpha:0.75] : [UIColor clearColor];
}
@end