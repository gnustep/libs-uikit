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
      [(NSView *)self addSubview:_segmentedControl];
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
  [_segmentedControl setLabel:(title == nil ? @"" : title) forSegment:segment];
}
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment { return [_segmentedControl labelForSegment:segment]; }
- (NSInteger)selectedSegmentIndex { return [_segmentedControl selectedSegment]; }
- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex { [_segmentedControl setSelectedSegment:selectedSegmentIndex]; }
@end
