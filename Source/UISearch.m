#import "UIKitPrivate.h"
@implementation UISearchBar
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _searchField = [[NSSearchField alloc] initWithFrame:self.bounds];
    [_searchField setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [[_searchField cell] setSendsWholeSearchString:YES];
    [_searchField setDelegate:self]; [_searchField setTarget:self]; [_searchField setAction:@selector(_search:)];
    [self _addNativeSubview:_searchField];
  } return self;
}
- (void)dealloc { [_lastNotifiedText release]; [_searchField setDelegate:nil]; [_searchField release]; [super dealloc]; }
@synthesize delegate = _delegate;
- (NSString *)text { return [_searchField stringValue]; }
- (void)setText:(NSString *)text { [_searchField setStringValue:text ?: @""]; ASSIGNCOPY(_lastNotifiedText,self.text); }
- (NSString *)placeholder { return [[_searchField cell] placeholderString]; }
- (void)setPlaceholder:(NSString *)text { [[_searchField cell] setPlaceholderString:text ?: @""]; }
- (void)_reportTextChange {
  NSString *text = self.text;
  if ([_lastNotifiedText isEqualToString:text]) return;
  ASSIGNCOPY(_lastNotifiedText,text);
  if ([_delegate respondsToSelector:@selector(searchBar:textDidChange:)]) [_delegate searchBar:self textDidChange:text];
}
- (void)controlTextDidChange:(NSNotification *)notification { [self _reportTextChange]; }
- (void)_search:(id)sender {
  /* NSSearchField also sends actions for edits and its clear button. Only
     an explicit Return is UIKit's search-button action. */
  [self _reportTextChange];
  NSEvent *event = [NSApp currentEvent];
  if (event.type == NSKeyDown && ([[event characters] isEqualToString:@"\r"] || [[event characters] isEqualToString:@"\n"]))
    if ([_delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) [_delegate searchBarSearchButtonClicked:self];
}
- (BOOL)canBecomeFirstResponder { return YES; }
- (NSResponder *)_nativeResponder { return _searchField; }
- (CGSize)intrinsicContentSize { return CGSizeMake(200,32); }
@end
@implementation UISearchController
- (id)init { return [self initWithSearchResultsController:nil]; }
- (id)initWithSearchResultsController:(UIViewController *)controller {
  self = [super initWithNibName:nil bundle:nil];
  if (self) { _searchBar = [UISearchBar new]; _searchBar.delegate = self; _searchResultsController = [controller retain]; _obscuresBackgroundDuringPresentation = YES; }
  return self;
}
- (void)dealloc { _searchBar.delegate = nil; [_searchBar release]; [_searchResultsController release]; [super dealloc]; }
@synthesize searchResultsUpdater = _searchResultsUpdater, active = _active, obscuresBackgroundDuringPresentation = _obscuresBackgroundDuringPresentation;
- (UISearchBar *)searchBar { return _searchBar; }
- (UIViewController *)searchResultsController { return _searchResultsController; }
- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)text { _active = YES; [_searchResultsUpdater updateSearchResultsForSearchController:self]; }
- (void)searchBarSearchButtonClicked:(UISearchBar *)bar { [_searchResultsUpdater updateSearchResultsForSearchController:self]; [bar resignFirstResponder]; }
@end
