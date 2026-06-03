#import <UIKit/UINavigationItem.h>

@implementation UINavigationItem
- (void)dealloc
{
  [_title release];
  [super dealloc];
}
- (NSString *)title { return _title; }
- (void)setTitle:(NSString *)title { ASSIGNCOPY(_title, title); }
@end
