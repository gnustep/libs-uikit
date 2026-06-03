#import <UIKit/UIKit.h>

@interface ExampleViewController : UIViewController
{
  UILabel *_titleLabel;
  UITextField *_nameField;
  UISlider *_slider;
  UISwitch *_enabledSwitch;
}
- (void)setTitleLabel:(UILabel *)label;
- (void)setNameField:(UITextField *)field;
- (void)setSlider:(UISlider *)slider;
- (void)setEnabledSwitch:(UISwitch *)enabledSwitch;
- (IBAction)buttonPressed:(id)sender;
- (IBAction)valueChanged:(id)sender;
@end

@implementation ExampleViewController
- (void)setTitleLabel:(UILabel *)label { _titleLabel = label; }
- (void)setNameField:(UITextField *)field { _nameField = field; }
- (void)setSlider:(UISlider *)slider { _slider = slider; }
- (void)setEnabledSwitch:(UISwitch *)enabledSwitch { _enabledSwitch = enabledSwitch; }
- (void)viewDidLoad
{
  [super viewDidLoad];
  [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
  [_enabledSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}
- (IBAction)buttonPressed:(id)sender
{
  NSString *name = [_nameField text];
  if ([name length] == 0)
    name = @"UIKit";
  [_titleLabel setText:[NSString stringWithFormat:@"Hello, %@", name]];
}
- (IBAction)valueChanged:(id)sender
{
  [_titleLabel setAlpha:[_slider value]];
  [_nameField setEnabled:[_enabledSwitch isOn]];
}
@end

@interface ExampleAppDelegate : NSObject <UIApplicationDelegate>
{
  UIWindow *_window;
  ExampleViewController *_viewController;
}
@end

@implementation ExampleAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
  _window = [[UIWindow alloc] initWithFrame:CGRectMake(80, 80, 420, 320)];
  _viewController = [[ExampleViewController alloc] initWithNibName:@"MainView" bundle:nil];
  [_window setTitle:@"GNUstep UIKit Example"];
  [_window setRootViewController:_viewController];
  [_window makeKeyAndVisible];
}
- (void)dealloc
{
  [_window release];
  [_viewController release];
  [super dealloc];
}
@end

int main(int argc, char **argv)
{
  return UIApplicationMain(argc, argv, nil, @"ExampleAppDelegate");
}
