#ifndef GNUSTEP_UIKIT_UICONTROL_H
#define GNUSTEP_UIKIT_UICONTROL_H

#import <UIKit/UIView.h>

@interface UIControl : UIView
{
  NSMutableArray *_uiTargets;
  BOOL _enabled;
  BOOL _selected;
  BOOL _highlighted;
}
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events;
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events;
- (void)sendActionsForControlEvents:(UIControlEvents)events;
@property(nonatomic, getter=isEnabled) BOOL enabled;
@property(nonatomic, getter=isSelected) BOOL selected;
@property(nonatomic, getter=isHighlighted) BOOL highlighted;
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isSelected;
- (void)setSelected:(BOOL)selected;
- (BOOL)isHighlighted;
- (void)setHighlighted:(BOOL)highlighted;
@end

#endif
