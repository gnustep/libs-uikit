#import "UIKitPrivate.h"
#import <UIKit/UISegmentedControl.h>

@implementation UISegmentedControl
- (id)initWithItems:(NSArray *)items
{
  self = [self initWithFrame:NSMakeRect(0, 0, 160, 28)];
  if (self != nil)
    {
      NSUInteger i;
      for (i = 0; i < [items count]; i++)
        [self insertSegmentWithTitle:[[items objectAtIndex:i] description] atIndex:i animated:NO];
    }
  return self;
}
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil)
    {
      _segmentedControl = [[NSSegmentedControl alloc] initWithFrame:[self bounds]];
      [_segmentedControl setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      [_segmentedControl setTarget:self];
      [_segmentedControl setAction:@selector(_uiSegmentChanged:)];
      [self _addNativeSubview:_segmentedControl];
    }
  return self;
}
- (void)dealloc
{
  [_segmentedControl release];
  [super dealloc];
}
- (void)_uiSegmentChanged:(id)sender { [self sendActionsForControlEvents:UIControlEventValueChanged]; }
- (NSUInteger)numberOfSegments { return [_segmentedControl segmentCount]; }
- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated
{
  NSInteger count = [_segmentedControl segmentCount];
  if (segment > count)
    segment = count;
  [_segmentedControl setSegmentCount:count + 1];
  for (NSInteger index = count; index > (NSInteger)segment; index--)
    [_segmentedControl setLabel:[_segmentedControl labelForSegment:index - 1] forSegment:index];
  [_segmentedControl setLabel:(title == nil ? @"" : title) forSegment:segment];
}
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment { return [_segmentedControl labelForSegment:segment]; }
- (NSInteger)selectedSegmentIndex { return [_segmentedControl selectedSegment]; }
- (void)setSelectedSegmentIndex:(NSInteger)index
{
  if (index < -1 || index >= [_segmentedControl segmentCount])
    [NSException raise:NSRangeException format:@"Invalid segment index"];
  for (NSInteger segment = 0; segment < [_segmentedControl segmentCount]; segment++)
    [_segmentedControl setSelected:segment == index forSegment:segment];
}
- (void)setEnabled:(BOOL)enabled { [super setEnabled:enabled]; [_segmentedControl setEnabled:enabled]; }
@end
