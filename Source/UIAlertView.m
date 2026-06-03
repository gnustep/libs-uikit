#import <UIKit/UIAlertView.h>

@implementation UIAlertView
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
  self = [super init];
  if (self != nil)
    {
      _title = [title copy];
      _message = [message copy];
    }
  return self;
}
- (void)dealloc
{
  [_title release];
  [_message release];
  [super dealloc];
}
- (void)show
{
  NSRunAlertPanel(_title == nil ? @"" : _title, _message == nil ? @"" : _message, @"OK", nil, nil);
}
@end
