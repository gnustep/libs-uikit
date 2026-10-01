#ifndef GNUSTEP_UIKIT_UITABLEVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UITABLEVIEWCONTROLLER_H
#import <UIKit/UIViewController.h>
#import <UIKit/UITableView.h>
@interface UITableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
  UITableViewStyle _tableViewStyle;
  BOOL _clearsSelectionOnViewWillAppear;
}
- (id)initWithStyle:(UITableViewStyle)style;
@property(nonatomic, retain) UITableView *tableView;
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;
@end
#endif
