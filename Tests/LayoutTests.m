#import <UIKit/UIKit.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#define VERIFY(c) do { if (!(c)) { fprintf(stderr, "FAIL layout %d: %s\n", __LINE__, #c); abort(); } } while (0)
#define NEAR(a,b) (fabs((a)-(b)) < 0.001)

@interface LayoutIntrinsicProbe : UIView @end
@implementation LayoutIntrinsicProbe
- (CGSize)intrinsicContentSize { return CGSizeMake(90, 25); }
@end

void testUIKitLayout(void)
{
  UIView *root = [[UIView alloc] initWithFrame:CGRectMake(0,0,400,300)];
  CGSize boxed = [NSValue valueWithCGSize:CGSizeMake(37,19)].CGSizeValue;
  VERIFY(CGSizeEqualToSize(boxed, CGSizeMake(37,19)));
  VERIFY(CGPointEqualToPoint([NSValue valueWithCGPoint:CGPointMake(3,5)].CGPointValue, CGPointMake(3,5)));
  VERIFY(CGRectEqualToRect([NSValue valueWithCGRect:root.frame].CGRectValue, root.frame));
  VERIFY(CGRectContainsRect(root.bounds, CGRectMake(10,10,20,20)));
  VERIFY(!CGRectContainsRect(root.bounds, CGRectMake(390,10,20,20)));
  VERIFY(CGRectContainsRect(CGRectMake(400,300,-400,-300), CGRectMake(10,10,20,20)));
  VERIFY([UIView areAnimationsEnabled]);
  [UIView setAnimationsEnabled:NO]; VERIFY(![UIView areAnimationsEnabled]);
  [UIView setAnimationsEnabled:YES]; VERIFY([UIView areAnimationsEnabled]);
  UISwitch *toggle = [[UISwitch alloc] init];
  toggle.enabled = NO; VERIFY(!toggle.enabled);
  toggle.enabled = YES; VERIFY(toggle.enabled);
  [toggle setOn:YES animated:NO]; VERIFY(toggle.on);
  [toggle setOn:NO animated:YES]; VERIFY(!toggle.on);
  [toggle release];
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Test" message:nil preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
  VERIFY([alert.actions.firstObject.title isEqual:@"OK"] && alert.actions.firstObject.enabled);
  UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,100,100)];
  scroll.contentSize = CGSizeMake(400,500);
  CGRect target = CGRectMake(150,300,20,20);
  [scroll scrollRectToVisible:target animated:NO];
  VERIFY(CGRectContainsRect(scroll.bounds,target));
  CGPoint offset = scroll.contentOffset;
  [scroll scrollRectToVisible:target animated:YES];
  VERIFY(CGPointEqualToPoint(offset,scroll.contentOffset));
  [scroll scrollRectToVisible:CGRectMake(0,0,10,10) animated:NO];
  VERIFY(CGPointEqualToPoint(scroll.contentOffset,CGPointZero));
  [scroll release];
  UIView *probe = [[UIView alloc] init];
  [root addSubview:probe];
  VERIFY(!probe.hasAmbiguousLayout);
  probe.translatesAutoresizingMaskIntoConstraints = NO;
  VERIFY(probe.hasAmbiguousLayout);
  NSArray *probeConstraints = @[[probe.leftAnchor constraintEqualToAnchor:root.leftAnchor],
    [probe.topAnchor constraintEqualToAnchor:root.topAnchor],
    [probe.widthAnchor constraintEqualToConstant:20], [probe.heightAnchor constraintEqualToConstant:30]];
  [NSLayoutConstraint activateConstraints:probeConstraints];
  VERIFY(!probe.hasAmbiguousLayout);
  [[probeConstraints lastObject] setActive:NO];
  VERIFY(probe.hasAmbiguousLayout);
  NSLayoutConstraint *lower = [probe.heightAnchor constraintGreaterThanOrEqualToConstant:30];
  NSLayoutConstraint *upper = [probe.heightAnchor constraintLessThanOrEqualToConstant:30];
  [NSLayoutConstraint activateConstraints:@[lower,upper]];
  VERIFY(!probe.hasAmbiguousLayout);
  upper.constant = 40;
  VERIFY(probe.hasAmbiguousLayout);
  [probe removeFromSuperview]; [probe release];
  UIView *a = [[UIView alloc] init], *b = [[UIView alloc] init];
  [a setTranslatesAutoresizingMaskIntoConstraints:NO]; [b setTranslatesAutoresizingMaskIntoConstraints:NO];
  [root addSubview:a]; [root addSubview:b];
  NSLayoutConstraint *left = [[a.leftAnchor constraintEqualToAnchor:root.safeAreaLayoutGuide.leftAnchor constant:20] retain];
  NSLayoutConstraint *width = [[a.widthAnchor constraintEqualToAnchor:root.widthAnchor multiplier:0.5 constant:-30] retain];
  [NSLayoutConstraint activateConstraints:@[left, width,
    [a.topAnchor constraintEqualToAnchor:root.topAnchor constant:10], [a.heightAnchor constraintEqualToConstant:40],
    [b.leftAnchor constraintEqualToAnchor:a.rightAnchor constant:12],
    [b.rightAnchor constraintEqualToAnchor:root.rightAnchor constant:-20],
    [b.centerYAnchor constraintEqualToAnchor:a.centerYAnchor], [b.heightAnchor constraintEqualToAnchor:a.heightAnchor]]];
  [root layoutIfNeeded];
  VERIFY(NEAR(a.frame.origin.x,20) && NEAR(a.frame.size.width,170));
  VERIFY(NEAR(b.frame.origin.x,202) && NEAR(b.frame.size.width,178) && NEAR(b.frame.origin.y,10));
  VERIFY(left.active && [root.constraints containsObject:left]);
  VERIFY(!a.hasAmbiguousLayout && !b.hasAmbiguousLayout);
  [root setFrame:CGRectMake(0,0,600,300)]; [root layoutIfNeeded];
  VERIFY(NEAR(a.frame.size.width,270) && NEAR(b.frame.size.width,278));
  left.constant = 30; [a layoutIfNeeded]; VERIFY(NEAR(a.frame.origin.x,30));
  width.active = NO;
  NSLayoutConstraint *minimum = [a.widthAnchor constraintGreaterThanOrEqualToConstant:100];
  NSLayoutConstraint *maximum = [a.widthAnchor constraintLessThanOrEqualToConstant:200];
  NSLayoutConstraint *preferred = [a.widthAnchor constraintEqualToConstant:150]; preferred.priority = 750;
  NSLayoutConstraint *weak = [a.widthAnchor constraintEqualToConstant:110]; weak.priority = 250;
  [NSLayoutConstraint activateConstraints:@[minimum, maximum, preferred, weak]];
  [root layoutIfNeeded]; VERIFY(NEAR(a.frame.size.width,150));
  preferred.active = NO; [root layoutIfNeeded]; VERIFY(NEAR(a.frame.size.width,110));
  weak.constant = 500; [root layoutIfNeeded]; VERIFY(a.frame.size.width <= 200.001 && a.frame.size.width >= 99.999);

  UILayoutGuide *guide = [[UILayoutGuide alloc] init]; [root addLayoutGuide:guide];
  [NSLayoutConstraint activateConstraints:@[
    [guide.leftAnchor constraintEqualToAnchor:root.layoutMarginsGuide.leftAnchor],
    [guide.topAnchor constraintEqualToAnchor:root.topAnchor constant:100],
    [guide.widthAnchor constraintEqualToConstant:80], [guide.heightAnchor constraintEqualToConstant:50]]];
  root.layoutMargins = UIEdgeInsetsMake(5,16,5,16); [root layoutIfNeeded];
  VERIFY(NEAR(guide.layoutFrame.origin.x,16) && NEAR(guide.layoutFrame.size.width,80));
  [root removeLayoutGuide:guide]; VERIFY(guide.owningView == nil); [guide release];

  LayoutIntrinsicProbe *intrinsic = [[LayoutIntrinsicProbe alloc] init];
  intrinsic.translatesAutoresizingMaskIntoConstraints = NO; [root addSubview:intrinsic];
  [NSLayoutConstraint activateConstraints:@[[intrinsic.leftAnchor constraintEqualToAnchor:root.leftAnchor],
    [intrinsic.topAnchor constraintEqualToAnchor:root.topAnchor constant:200]]];
  [root layoutIfNeeded]; VERIFY(NEAR(intrinsic.frame.size.width,90) && NEAR(intrinsic.frame.size.height,25));
  [intrinsic removeFromSuperview]; [intrinsic release];

  UIView *nested = [[UIView alloc] initWithFrame:CGRectMake(40,50,100,100)]; [root addSubview:nested];
  UIView *child = [[UIView alloc] init]; child.translatesAutoresizingMaskIntoConstraints = NO; [nested addSubview:child];
  [NSLayoutConstraint activateConstraints:@[[child.leftAnchor constraintEqualToAnchor:root.leftAnchor constant:70],
    [child.topAnchor constraintEqualToAnchor:nested.topAnchor constant:12],
    [child.widthAnchor constraintEqualToConstant:20], [child.heightAnchor constraintEqualToConstant:20]]];
  [root layoutIfNeeded]; VERIFY(NEAR(child.frame.origin.x,30) && NEAR(child.frame.origin.y,12));
  [child release]; [nested release];

  [a removeFromSuperview]; VERIFY(!left.active && ![root.constraints containsObject:left]);
  VERIFY(minimum.active); /* A dimension constraint belongs to the detached view. */
  BOOL caught = NO;
  @try { left.active = YES; } @catch (NSException *exception) { caught = YES; }
  VERIFY(caught);
  [left release]; [width release]; [a release]; [b release]; [root release];

  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  UIView *temporary = [[UIView alloc] init];
  NSLayoutConstraint *survivor = [[temporary.widthAnchor constraintEqualToConstant:30] retain];
  NSLayoutDimension *anchor = [temporary.widthAnchor retain];
  [temporary release]; VERIFY(survivor.firstItem == nil && !survivor.active);
  [pool drain]; [survivor release];
  caught = NO; @try { [anchor constraintEqualToConstant:40]; } @catch (NSException *exception) { caught = YES; }
  VERIFY(caught); [anchor release];
  fprintf(stderr, "UIKit layout scenarios passed\n");
}
