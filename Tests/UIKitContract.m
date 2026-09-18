/* This translation unit must compile with UIKit alone. The separate test host
   initializes the desktop backend; no application-side adaptation belongs here. */
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <stdio.h>
#include <stdlib.h>

#if defined(_APPKIT_H) || defined(_GNUstep_H_NSView)
#error UIKit must not import AppKit
#endif

#define REQUIRE(value) do { if (!(value)) { fprintf(stderr, "Contract failed at %s:%d: %s\n", __FILE__, __LINE__, #value); abort(); } } while (0)

@interface ContractController : UIViewController { @public NSUInteger actions; }
- (void)save:(id)sender;
@end
@implementation ContractController
- (void)save:(id)sender { actions++; }
@end

void UIKitRunPublicContract(void)
{
  REQUIRE(class_getSuperclass([UIResponder class]) == [NSObject class]);
  REQUIRE(class_getSuperclass([UIView class]) == [UIResponder class]);
  REQUIRE(class_getSuperclass([UIWindow class]) == [UIView class]);
  REQUIRE(class_getSuperclass([UITextView class]) == [UIScrollView class]);
  REQUIRE(NSTextAlignmentCenter == 1 && NSTextAlignmentRight == 2);

  UIWindow *window = [[[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
  ContractController *controller = [[[ContractController alloc] init] autorelease];
  window.rootViewController = controller;
  [window makeKeyAndVisible];
  UIView *root = controller.view;
  REQUIRE(root.superview == window && root.window == window);
  REQUIRE(root.nextResponder == controller);
  REQUIRE(controller.nextResponder == window);
  REQUIRE(window.nextResponder == [UIApplication sharedApplication]);

  UIButton *button = [UIButton buttonWithType:0];
  button.frame = CGRectMake(10, 20, 100, 30);
  [button setTitle:@"Save" forState:UIControlStateNormal];
  [root addSubview:button];
  REQUIRE(button.subviews.count == 0);
  REQUIRE(button.superview == root && button.window == window);
  [button addTarget:nil action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
  [button sendActionsForControlEvents:UIControlEventTouchUpInside];
  REQUIRE(controller->actions == 1);

  UIScrollView *scroll = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, 200, 200)] autorelease];
  [root addSubview:scroll];
  scroll.contentSize = CGSizeMake(200, 1000);
  UIView *content = [[[UIView alloc] initWithFrame:CGRectMake(10, 300, 50, 50)] autorelease];
  [scroll addSubview:content];
  scroll.contentOffset = CGPointMake(0, 250);
  REQUIRE(scroll.subviews.count == 1 && content.superview == scroll);
  REQUIRE([content isDescendantOfView:root]);
  CGPoint position = [content convertPoint:CGPointZero toView:root];
  REQUIRE(position.x == 10 && position.y == 130);
  REQUIRE([root hitTest:position withEvent:nil] == content);
  CGPoint inverse = [content convertPoint:position fromView:root];
  REQUIRE(inverse.x == 0 && inverse.y == 0);

  UIView *a = [[[UIView alloc] init] autorelease];
  UIView *b = [[[UIView alloc] init] autorelease];
  UIView *c = [[[UIView alloc] init] autorelease];
  [content addSubview:a]; [content addSubview:b]; [content addSubview:c];
  [content insertSubview:a belowSubview:c];
  REQUIRE([content.subviews objectAtIndex:0] == b);
  REQUIRE([content.subviews objectAtIndex:1] == a);
  [content insertSubview:b aboveSubview:a];
  REQUIRE([content.subviews objectAtIndex:1] == b);
  [root addSubview:a];
  REQUIRE(a.superview == root && ![content.subviews containsObject:a]);
  [a removeFromSuperview];
  REQUIRE(a.superview == nil && a.window == nil);

  UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)] autorelease];
  [root addSubview:field];
  field.text = @"unchanged source";
  REQUIRE(field.subviews.count == 0);
  REQUIRE([field becomeFirstResponder] && field.isFirstResponder);
  REQUIRE([root endEditing:NO] && !field.isFirstResponder);
  UITextView *textView = [[[UITextView alloc] initWithFrame:CGRectMake(0, 300, 150, 80)] autorelease];
  [root addSubview:textView];
  textView.text = @"Text view";
  REQUIRE([textView becomeFirstResponder] && textView.isFirstResponder);
  REQUIRE([textView resignFirstResponder]);
  REQUIRE(textView.subviews.count == 0);
  window.hidden = YES;
  printf("PASS: UIKit-only public contract\n");
}
