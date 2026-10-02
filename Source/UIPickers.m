#import "UIKitPrivate.h"
@implementation UIDatePicker
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _datePicker = [[NSDatePicker alloc] initWithFrame:self.bounds];
    [_datePicker setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_datePicker setDatePickerStyle:NSTextFieldAndStepperDatePickerStyle];
    [_datePicker setDateValue:[NSDate date]];
    [_datePicker setTarget:self]; [_datePicker setAction:@selector(_changed:)];
    [self _addNativeSubview:_datePicker]; self.datePickerMode = UIDatePickerModeDateAndTime;
  } return self;
}
- (void)dealloc { [_datePicker release]; [super dealloc]; }
- (void)_changed:(id)sender { [self sendActionsForControlEvents:UIControlEventValueChanged]; }
- (UIDatePickerMode)datePickerMode { return _datePickerMode; }
- (void)setDatePickerMode:(UIDatePickerMode)mode {
  if (mode == UIDatePickerModeCountDownTimer) [NSException raise:NSInvalidArgumentException format:@"Countdown date pickers are not supported"];
  _datePickerMode = mode;
  [_datePicker setDatePickerElements:mode == UIDatePickerModeTime ? NSHourMinuteDatePickerElementFlag : mode == UIDatePickerModeDate ? NSYearMonthDayDatePickerElementFlag : NSYearMonthDayDatePickerElementFlag|NSHourMinuteDatePickerElementFlag];
}
- (UIDatePickerStyle)preferredDatePickerStyle { return _preferredDatePickerStyle; }
- (void)setPreferredDatePickerStyle:(UIDatePickerStyle)style {
  _preferredDatePickerStyle = style;
  [_datePicker setDatePickerStyle:style == UIDatePickerStyleInline ? NSClockAndCalendarDatePickerStyle : NSTextFieldAndStepperDatePickerStyle];
}
- (NSDate *)date { return [_datePicker dateValue]; }
- (void)setDate:(NSDate *)date { if (date) [_datePicker setDateValue:date]; }
- (void)setDate:(NSDate *)date animated:(BOOL)animated { self.date = date; }
- (NSDate *)minimumDate { return [_datePicker minDate]; }
- (void)setMinimumDate:(NSDate *)date { [_datePicker setMinDate:date]; }
- (NSDate *)maximumDate { return [_datePicker maxDate]; }
- (void)setMaximumDate:(NSDate *)date { [_datePicker setMaxDate:date]; }
- (void)setEnabled:(BOOL)enabled { [super setEnabled:enabled]; [_datePicker setEnabled:enabled]; }
- (CGSize)intrinsicContentSize { return CGSizeMake(240,32); }
@end

@implementation UIPickerView
- (id)initWithFrame:(CGRect)frame { self = [super initWithFrame:frame]; if (self) _components = [NSMutableArray new]; return self; }
- (void)dealloc { [_components release]; [super dealloc]; }
- (id<UIPickerViewDataSource>)dataSource { return _dataSource; }
- (void)setDataSource:(id<UIPickerViewDataSource>)source { _dataSource = source; [self reloadAllComponents]; }
- (id<UIPickerViewDelegate>)delegate { return _delegate; }
- (void)setDelegate:(id<UIPickerViewDelegate>)delegate { _delegate = delegate; [self reloadAllComponents]; }
- (NSInteger)numberOfComponents { return _components.count; }
- (NSInteger)numberOfRowsInComponent:(NSInteger)component { return component >= 0 && component < _components.count ? [[_components objectAtIndex:component] numberOfItems] : 0; }
- (void)reloadAllComponents {
  for (NSView *view in _components) [view removeFromSuperview];
  [_components removeAllObjects];
  NSInteger count = _dataSource ? [_dataSource numberOfComponentsInPickerView:self] : 0;
  for (NSInteger i = 0; i < count; i++) {
    NSPopUpButton *button = [[[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO] autorelease];
    [button setTag:i]; [button setTarget:self]; [button setAction:@selector(_selected:)];
    [_components addObject:button]; [self _addNativeSubview:button]; [self reloadComponent:i];
  }
  [self setNeedsLayout];
}
- (void)reloadComponent:(NSInteger)component {
  if (component < 0 || component >= _components.count) return;
  NSPopUpButton *button = [_components objectAtIndex:component]; NSInteger selected = button.indexOfSelectedItem;
  [button removeAllItems];
  NSInteger count = [_dataSource pickerView:self numberOfRowsInComponent:component];
  for (NSInteger row = 0; row < count; row++) {
    NSString *title = [_delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)] ? [_delegate pickerView:self titleForRow:row forComponent:component] : nil;
    /* Insert distinct menu items: addItemWithTitle coalesces duplicate titles. */
    NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:title ?: [NSString stringWithFormat:@"%ld",(long)row] action:NULL keyEquivalent:@""] autorelease];
    [[button menu] addItem:item];
  }
  if (count) [button selectItemAtIndex:MAX(0,MIN(selected,count-1))];
}
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
  if (component < 0 || component >= _components.count || row < 0 || row >= [self numberOfRowsInComponent:component]) [NSException raise:NSRangeException format:@"Invalid picker selection"];
  [[_components objectAtIndex:component] selectItemAtIndex:row];
}
- (NSInteger)selectedRowInComponent:(NSInteger)component { return component >= 0 && component < _components.count ? [[_components objectAtIndex:component] indexOfSelectedItem] : -1; }
- (void)_selected:(NSPopUpButton *)button {
  if ([_delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) [_delegate pickerView:self didSelectRow:button.indexOfSelectedItem inComponent:button.tag];
}
- (void)layoutSubviews {
  [super layoutSubviews]; CGFloat width = self.bounds.size.width / MAX(1,_components.count); NSInteger i = 0;
  for (NSView *view in _components) view.frame = CGRectMake(i++*width,MAX(0,(self.bounds.size.height-32)/2),MAX(0,width-4),32);
}
- (CGSize)intrinsicContentSize { return CGSizeMake(240,44); }
@end

@implementation UIPageControl
- (void)dealloc { [_pageIndicatorTintColor release]; [_currentPageIndicatorTintColor release]; [super dealloc]; }
- (NSInteger)numberOfPages { return _numberOfPages; }
- (void)setNumberOfPages:(NSInteger)count { _numberOfPages = MAX(0,count); self.currentPage = _currentPage; [self setNeedsDisplay]; }
- (NSInteger)currentPage { return _currentPage; }
- (void)setCurrentPage:(NSInteger)page { _currentPage = MAX(0,MIN(page,_numberOfPages-1)); [self setNeedsDisplay]; }
- (UIColor *)pageIndicatorTintColor { return _pageIndicatorTintColor; }
- (void)setPageIndicatorTintColor:(UIColor *)color { ASSIGN(_pageIndicatorTintColor,color); [self setNeedsDisplay]; }
- (UIColor *)currentPageIndicatorTintColor { return _currentPageIndicatorTintColor; }
- (void)setCurrentPageIndicatorTintColor:(UIColor *)color { ASSIGN(_currentPageIndicatorTintColor,color); [self setNeedsDisplay]; }
- (void)drawRect:(CGRect)rect {
  [super drawRect:rect]; CGFloat start = (self.bounds.size.width-_numberOfPages*20)/2;
  for (NSInteger i = 0; i < _numberOfPages; i++) {
    [[(i == _currentPage ? (_currentPageIndicatorTintColor ?: [UIColor blueColor]) : (_pageIndicatorTintColor ?: [UIColor grayColor])) NSColor] set];
    [[NSBezierPath bezierPathWithOvalInRect:CGRectMake(start+i*20+6,(self.bounds.size.height-8)/2,8,8)] fill];
  }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event]; if (![self isEnabled] || !_numberOfPages) return;
  CGPoint point = [[touches anyObject] locationInView:self];
  NSInteger page = floor((point.x-(self.bounds.size.width-_numberOfPages*20)/2)/20);
  NSInteger old = _currentPage; self.currentPage = page;
  if (old != _currentPage) [self sendActionsForControlEvents:UIControlEventValueChanged];
}
- (CGSize)intrinsicContentSize { return CGSizeMake(MAX(20,_numberOfPages*20),32); }
@end

@interface UICalendarView (Selection)
- (void)_updateSelection;
@end
@interface UICalendarSelectionSingleDate (Owner)
- (void)_setCalendarView:(UICalendarView *)view;
@end
@implementation UICalendarSelectionSingleDate
- (id)initWithDelegate:(id<UICalendarSelectionSingleDateDelegate>)delegate { self = [super init]; if (self) _delegate = delegate; return self; }
- (void)dealloc { [_selectedDate release]; [super dealloc]; }
- (id<UICalendarSelectionSingleDateDelegate>)delegate { return _delegate; }
- (void)_setCalendarView:(UICalendarView *)view { _calendarView = view; }
- (NSDateComponents *)selectedDate { return _selectedDate; }
- (void)setSelectedDate:(NSDateComponents *)date { ASSIGNCOPY(_selectedDate,date); [_calendarView _updateSelection]; }
- (void)setSelectedDate:(NSDateComponents *)date animated:(BOOL)animated { self.selectedDate = date; }
@end
@implementation UICalendarView
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _datePicker = [[NSDatePicker alloc] initWithFrame:self.bounds];
    [_datePicker setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_datePicker setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
    [_datePicker setDatePickerStyle:NSClockAndCalendarDatePickerStyle];
    [_datePicker setDateValue:[NSDate date]];
    [_datePicker setTarget:self]; [_datePicker setAction:@selector(_selected:)]; [self _addNativeSubview:_datePicker];
  } return self;
}
- (void)dealloc { [_selectionBehavior _setCalendarView:nil]; [_selectionBehavior release]; [_datePicker release]; [super dealloc]; }
- (UICalendarSelectionSingleDate *)selectionBehavior { return _selectionBehavior; }
- (void)setSelectionBehavior:(UICalendarSelectionSingleDate *)selection {
  [_selectionBehavior _setCalendarView:nil]; ASSIGN(_selectionBehavior,selection); [selection _setCalendarView:self]; [self _updateSelection];
}
- (void)_updateSelection { if (!_selectionBehavior.selectedDate) return; NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:_selectionBehavior.selectedDate]; if (date) [_datePicker setDateValue:date]; }
- (void)_selected:(id)sender {
  NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[_datePicker dateValue]];
  id delegate = _selectionBehavior.delegate;
  if ([delegate respondsToSelector:@selector(dateSelection:canSelectDate:)] && ![delegate dateSelection:_selectionBehavior canSelectDate:components]) { [self _updateSelection]; return; }
  _selectionBehavior.selectedDate = components;
  if ([delegate respondsToSelector:@selector(dateSelection:didSelectDate:)]) [delegate dateSelection:_selectionBehavior didSelectDate:components];
}
- (CGSize)intrinsicContentSize { return CGSizeMake(280,240); }
@end
