ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif

PACKAGE_NAME = libs-uikit

include $(GNUSTEP_MAKEFILES)/common.make

LIBRARY_NAME = libs-uikit
libs-uikit_VERSION = 0.2.0
libs-uikit_INTERFACE_VERSION = 1

libs-uikit_OBJC_FILES = $(shell cat Sources.list)

libs-uikit_HEADER_FILES_DIR = ../Headers/UIKit
libs-uikit_HEADER_FILES_INSTALL_DIR = /UIKit
libs-uikit_HEADER_FILES = \
	UIKit.h \
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

libs-uikit_LIBRARIES_DEPEND_UPON = -lgnustep-gui -lgnustep-base

include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/library.make
include GNUmakefile.postamble
