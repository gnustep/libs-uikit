ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif

PACKAGE_NAME = libs-uikit

include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = UIKit
UIKit_VERSION = 0.2.0
UIKit_INTERFACE_VERSION = 1

UIKit_OBJC_FILES = $(shell cat Sources.list)

UIKit_HEADER_FILES_DIR = ../Headers/UIKit
UIKit_HEADER_FILES = \
	UIKit.h \
	NSLayoutConstraint.h \
	NSLayoutAnchor.h \
	UILayoutGuide.h \
	GNUstepUIKit.h \
	UIKitTypes.h \
	UIGestureRecognizer.h \
	UITapGestureRecognizer.h \
	UIPanGestureRecognizer.h \
	UIResponder.h \
	UIEvent.h \
	UITouch.h \
	UIPress.h \
	UIPressesEvent.h \
	UIApplication.h \
	UISceneConfiguration.h \
	UISceneSession.h \
	UIScene.h \
	UIWindowScene.h \
	UIView.h \
	UIWindow.h \
	UIViewController.h \
	UICollectionViewController.h \
	UITableViewController.h \
	UIColor.h \
	UIImage.h \
	UIFont.h \
	UILabel.h \
	UIImageView.h \
	UIControl.h \
	UIButton.h \
	UITextField.h \
	UITextView.h \
	UIProgressView.h \
	UIStepper.h \
	UIAlertController.h \
	UISlider.h \
	UISwitch.h \
	UISegmentedControl.h \
	UIScrollView.h \
	UITableViewCell.h \
	NSIndexPath+UIKit.h \
	UITableView.h \
	UICollectionViewCell.h \
	UICollectionViewLayout.h \
	UICollectionViewFlowLayout.h \
	UICollectionView.h \
	UIStackView.h \
	UIOpenGLView.h \
	UINavigationItem.h \
	UINavigationController.h \
	UITabBarController.h \
	UIActivityIndicatorView.h \
	UIAlertView.h \
	UISearchBar.h \
	UISearchController.h \
	UIBarButtonItem.h \
	UIToolbar.h \
	UINavigationBar.h \
	UITabBarItem.h \
	UITabBar.h \
	UIPopoverPresentationController.h \
	UIDatePicker.h \
	UIPickerView.h \
	UIPageControl.h \
	UICalendarView.h \
	UIRefreshControl.h \
	UIViewLayer.h \
	UIVisualEffectView.h \
	UIPageViewController.h \
	UISplitViewController.h \
	UIActivityViewController.h \
	UIColorPickerViewController.h \
	UIFontDescriptor.h \
	UIFontPickerViewController.h \
	UILongPressGestureRecognizer.h \
	UISwipeGestureRecognizer.h \
	UIPinchGestureRecognizer.h \
	UIRotationGestureRecognizer.h \
	UIBlurEffect.h \
	UIVisualEffect.h \
	UICalendarSelectionSingleDate.h \
	UIFontPickerViewControllerConfiguration.h \
	UIColorWell.h \
	UISearchTextField.h \
	UIPasteboard.h \
	UIPasteControl.h \
	UIContentConfiguration.h \
	UIListContentConfiguration.h \
	UIContentUnavailableConfiguration.h \
	UIContentUnavailableView.h \
	UICollectionViewListCell.h \
	UITableViewHeaderFooterView.h \
	UIInteraction.h \
	UIMenu.h \
	UIAction.h \
	UICommand.h \
	UIMenuElement.h \
	UIContextMenuInteraction.h \
	UIEditMenuInteraction.h \
	UIContextMenuConfiguration.h \
	UIEditMenuConfiguration.h \
	UIDocumentPickerViewController.h \
	UIDocumentBrowserViewController.h \
	UIImagePickerController.h \
	UIReferenceLibraryViewController.h \
	UITextFormattingViewController.h \
	UITextFormattingViewControllerConfiguration.h \
	UITextFormattingViewControllerChangeValue.h \
	UIGlassEffect.h \
	UIGlassContainerEffect.h \
	UIBackgroundExtensionView.h \
	UIHoverGestureRecognizer.h \
	UIToolTipInteraction.h \
	UIPointerInteraction.h \
	UIDragInteraction.h \
	UIDragItem.h \
	UIDropInteraction.h \
	UIDropProposal.h \
	UIScreen.h \
	UIDevice.h \
	UINib.h \
	NSBundle+UIKit.h

UIKit_LIBRARIES_DEPEND_UPON = -lgnustep-gui -lgnustep-base

include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/framework.make
include GNUmakefile.postamble
