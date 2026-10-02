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
	UIScreen.h \
	UIDevice.h \
	UINib.h \
	NSBundle+UIKit.h

UIKit_LIBRARIES_DEPEND_UPON = -lgnustep-gui -lgnustep-base

include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/framework.make
include GNUmakefile.postamble
