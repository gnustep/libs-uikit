#import "UIKitPrivate.h"
#include <math.h>
#include <stdlib.h>

const CGFloat UIViewNoIntrinsicMetric = -1;

@interface NSObject (UIKitLayoutItem)
- (NSMutableArray *)_uiConstraintReferences;
- (UILayoutAnchor *)_uiAnchor:(NSLayoutAttribute)attribute;
- (void)_uiLayoutChanged;
@end
@interface UILayoutAnchor (UIKitLayoutPrivate)
- (id)_initWithItem:(id)item attribute:(NSLayoutAttribute)attribute;
- (void)_invalidate;
@end
@interface UILayoutConstraint (UIKitLayoutPrivate)
- (void)_installInView:(UIView *)view;
- (void)_invalidateItem:(id)item;
@end
@interface UILayoutGuide (UIKitLayoutPrivate)
- (void)_setLayoutFrame:(CGRect)frame;
@end
@interface UIView (UIKitLayoutPrivate)
- (void)_uiInitializeLayout;
- (void)_uiDestroyLayout;
- (void)_uiRemoveAncestorConstraints;
- (void)_uiSolveLayout;
- (void)_uiLayoutPass;
@end

static UIView *UILayoutView(id item)
{ return [item isKindOfClass:[UILayoutGuide class]] ? [item owningView] : item; }
static UIView *UILayoutCommonAncestor(id first, id second)
{
  UIView *a = UILayoutView(first), *b = UILayoutView(second);
  if (!second) return a;
  for (UIView *p = a; p; p = [p superview]) if ([b isDescendantOfView:p]) return p;
  return nil;
}
static void UILayoutInvalidateItem(id item, NSMutableArray *references, NSDictionary *anchors)
{
  for (NSValue *value in [[references copy] autorelease])
    [(UILayoutConstraint *)[value pointerValue] _invalidateItem:item];
  for (UILayoutAnchor *anchor in [anchors allValues]) [anchor _invalidate];
}
static BOOL UILayoutDimensionAttribute(NSLayoutAttribute a)
{ return a == NSLayoutAttributeWidth || a == NSLayoutAttributeHeight; }
static BOOL UILayoutHorizontalAttribute(NSLayoutAttribute a)
{ return a == NSLayoutAttributeLeft || a == NSLayoutAttributeRight || a == NSLayoutAttributeLeading || a == NSLayoutAttributeTrailing || a == NSLayoutAttributeCenterX; }

@implementation UILayoutConstraint
+ (instancetype)constraintWithItem:(id)item attribute:(NSLayoutAttribute)a relatedBy:(NSLayoutRelation)relation
  toItem:(id)other attribute:(NSLayoutAttribute)b multiplier:(CGFloat)m constant:(CGFloat)c
{
  BOOL firstValid = [item isKindOfClass:[UIView class]] || [item isKindOfClass:[UILayoutGuide class]];
  BOOL secondValid = !other || [other isKindOfClass:[UIView class]] || [other isKindOfClass:[UILayoutGuide class]];
  BOOL attributesValid = a >= NSLayoutAttributeLeft && a <= NSLayoutAttributeCenterY;
  if (other) attributesValid = attributesValid && b >= NSLayoutAttributeLeft && b <= NSLayoutAttributeCenterY &&
    (UILayoutDimensionAttribute(a) == UILayoutDimensionAttribute(b)) &&
    (UILayoutDimensionAttribute(a) || UILayoutHorizontalAttribute(a) == UILayoutHorizontalAttribute(b));
  else attributesValid = attributesValid && UILayoutDimensionAttribute(a) && b == NSLayoutAttributeNotAnAttribute;
  if (!firstValid || !secondValid || !attributesValid || !isfinite(m) || !isfinite(c) ||
      relation < -1 || relation > 1 || (other && m <= 0) || (!UILayoutDimensionAttribute(a) && m != 1))
    [NSException raise:NSInvalidArgumentException format:@"Invalid or unsupported layout constraint"];
  UILayoutConstraint *constraint = [[[self alloc] init] autorelease];
  constraint->_firstItem = item; constraint->_secondItem = other;
  constraint->_firstAttribute = a; constraint->_secondAttribute = b;
  constraint->_relation = relation; constraint->_multiplier = m; constraint->_constant = c;
  constraint->_priority = UILayoutPriorityRequired;
  [[item _uiConstraintReferences] addObject:[NSValue valueWithPointer:constraint]];
  if (other != item) [[other _uiConstraintReferences] addObject:[NSValue valueWithPointer:constraint]];
  return constraint;
}
- (void)dealloc
{
  NSValue *reference = [NSValue valueWithPointer:self];
  [[_firstItem _uiConstraintReferences] removeObject:reference];
  if (_secondItem != _firstItem) [[_secondItem _uiConstraintReferences] removeObject:reference];
  [_identifier release]; [super dealloc];
}
- (void)_invalidateItem:(id)item
{
  [[self retain] autorelease]; [self setActive:NO];
  if (_firstItem == item) _firstItem = nil;
  if (_secondItem == item) _secondItem = nil;
}
+ (void)activateConstraints:(NSArray *)constraints
{
  /* Validate the whole batch before mutating ownership. */
  for (UILayoutConstraint *constraint in constraints)
    if (!UILayoutCommonAncestor([constraint firstItem], [constraint secondItem]))
      [NSException raise:NSInvalidArgumentException format:@"Constraint items have no common ancestor"];
  for (UILayoutConstraint *constraint in constraints) [constraint setActive:YES];
}
+ (void)deactivateConstraints:(NSArray *)constraints
{ for (UILayoutConstraint *constraint in [[constraints copy] autorelease]) [constraint setActive:NO]; }
- (void)_installInView:(UIView *)view { _container = view; }
- (BOOL)isActive { return _container != nil; }
- (void)setActive:(BOOL)active
{
  if (active == [self isActive]) return;
  if (!active) { [_container removeConstraint:self]; return; }
  UIView *container = UILayoutCommonAncestor(_firstItem, _secondItem);
  if (!container) [NSException raise:NSInvalidArgumentException format:@"Constraint items have no common ancestor"];
  [container addConstraint:self];
}
- (id)firstItem { return _firstItem; }
- (id)secondItem { return _secondItem; }
- (NSLayoutAttribute)firstAttribute { return _firstAttribute; }
- (NSLayoutAttribute)secondAttribute { return _secondAttribute; }
- (NSLayoutRelation)relation { return _relation; }
- (CGFloat)multiplier { return _multiplier; }
- (CGFloat)constant { return _constant; }
- (void)setConstant:(CGFloat)value
{
  if (!isfinite(value)) [NSException raise:NSInvalidArgumentException format:@"Non-finite constraint constant"];
  _constant = value; [_container _uiLayoutChanged];
}
- (UILayoutPriority)priority { return _priority; }
- (void)setPriority:(UILayoutPriority)value
{
  if (!isfinite(value) || value <= 0 || value > 1000)
    [NSException raise:NSInvalidArgumentException format:@"Constraint priority must be in (0, 1000]"];
  _priority = value; [_container _uiLayoutChanged];
}
- (NSString *)identifier { return _identifier; }
- (void)setIdentifier:(NSString *)value { ASSIGNCOPY(_identifier, value); }
@end

@implementation UILayoutAnchor
- (id)_initWithItem:(id)item attribute:(NSLayoutAttribute)a
{ if ((self = [super init])) { _item = item; _attribute = a; } return self; }
- (void)_invalidate { _item = nil; }
- (NSLayoutConstraint *)_constraint:(UILayoutAnchor *)anchor relation:(NSLayoutRelation)relation multiplier:(CGFloat)m constant:(CGFloat)c
{
  if (!_item || !anchor || !anchor->_item)
    [NSException raise:NSInvalidArgumentException format:@"Layout anchor has no item"];
  return [NSLayoutConstraint constraintWithItem:_item attribute:_attribute relatedBy:relation
    toItem:anchor->_item attribute:anchor->_attribute multiplier:m constant:c];
}
- (NSLayoutConstraint *)constraintEqualToAnchor:(UILayoutAnchor *)anchor
{ return [self constraintEqualToAnchor:anchor constant:0]; }
- (NSLayoutConstraint *)constraintEqualToAnchor:(UILayoutAnchor *)anchor constant:(CGFloat)c
{ return [self _constraint:anchor relation:0 multiplier:1 constant:c]; }
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(UILayoutAnchor *)anchor
{ return [self constraintLessThanOrEqualToAnchor:anchor constant:0]; }
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(UILayoutAnchor *)anchor constant:(CGFloat)c
{ return [self _constraint:anchor relation:-1 multiplier:1 constant:c]; }
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(UILayoutAnchor *)anchor
{ return [self constraintGreaterThanOrEqualToAnchor:anchor constant:0]; }
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(UILayoutAnchor *)anchor constant:(CGFloat)c
{ return [self _constraint:anchor relation:1 multiplier:1 constant:c]; }
@end
@implementation UILayoutXAxisAnchor @end
@implementation UILayoutYAxisAnchor @end
@implementation UILayoutDimension
- (NSLayoutConstraint *)constraintEqualToConstant:(CGFloat)c
{ return [NSLayoutConstraint constraintWithItem:_item attribute:_attribute relatedBy:0
  toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:c]; }
- (NSLayoutConstraint *)constraintEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)m
{ return [self constraintEqualToAnchor:anchor multiplier:m constant:0]; }
- (NSLayoutConstraint *)constraintEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)m constant:(CGFloat)c
{ return [self _constraint:anchor relation:0 multiplier:m constant:c]; }
- (NSLayoutConstraint *)constraintLessThanOrEqualToConstant:(CGFloat)c
{ return [NSLayoutConstraint constraintWithItem:_item attribute:_attribute relatedBy:-1
  toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:c]; }
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)m
{ return [self constraintLessThanOrEqualToAnchor:anchor multiplier:m constant:0]; }
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)m constant:(CGFloat)c
{ return [self _constraint:anchor relation:-1 multiplier:m constant:c]; }
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToConstant:(CGFloat)c
{ return [NSLayoutConstraint constraintWithItem:_item attribute:_attribute relatedBy:1
  toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:c]; }
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)m
{ return [self constraintGreaterThanOrEqualToAnchor:anchor multiplier:m constant:0]; }
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(UILayoutDimension *)anchor multiplier:(CGFloat)m constant:(CGFloat)c
{ return [self _constraint:anchor relation:1 multiplier:m constant:c]; }
@end

static UILayoutAnchor *UILayoutGetAnchor(id item, NSMutableDictionary *anchors, NSLayoutAttribute attribute)
{
  NSNumber *key = [NSNumber numberWithInteger:attribute];
  UILayoutAnchor *anchor = [anchors objectForKey:key];
  if (!anchor) {
    Class type = UILayoutDimensionAttribute(attribute) ? [UILayoutDimension class] :
      UILayoutHorizontalAttribute(attribute) ? [UILayoutXAxisAnchor class] : [UILayoutYAxisAnchor class];
    anchor = [[[type alloc] _initWithItem:item attribute:attribute] autorelease];
    [anchors setObject:anchor forKey:key];
  }
  return anchor;
}
#define UIKIT_ANCHORS \
- (NSLayoutXAxisAnchor *)leftAnchor { return (id)[self _uiAnchor:NSLayoutAttributeLeft]; } \
- (NSLayoutXAxisAnchor *)rightAnchor { return (id)[self _uiAnchor:NSLayoutAttributeRight]; } \
- (NSLayoutXAxisAnchor *)leadingAnchor { return (id)[self _uiAnchor:NSLayoutAttributeLeading]; } \
- (NSLayoutXAxisAnchor *)trailingAnchor { return (id)[self _uiAnchor:NSLayoutAttributeTrailing]; } \
- (NSLayoutYAxisAnchor *)topAnchor { return (id)[self _uiAnchor:NSLayoutAttributeTop]; } \
- (NSLayoutYAxisAnchor *)bottomAnchor { return (id)[self _uiAnchor:NSLayoutAttributeBottom]; } \
- (NSLayoutXAxisAnchor *)centerXAnchor { return (id)[self _uiAnchor:NSLayoutAttributeCenterX]; } \
- (NSLayoutYAxisAnchor *)centerYAnchor { return (id)[self _uiAnchor:NSLayoutAttributeCenterY]; } \
- (NSLayoutDimension *)widthAnchor { return (id)[self _uiAnchor:NSLayoutAttributeWidth]; } \
- (NSLayoutDimension *)heightAnchor { return (id)[self _uiAnchor:NSLayoutAttributeHeight]; }

@implementation UILayoutGuide
- (id)init
{
  if ((self = [super init])) { _uiAnchors = [NSMutableDictionary new]; _uiConstraintReferences = [NSMutableArray new]; }
  return self;
}
- (void)dealloc
{
  UILayoutInvalidateItem(self, _uiConstraintReferences, _uiAnchors);
  [_uiConstraintReferences release]; [_uiAnchors release]; [_identifier release]; [super dealloc];
}
- (UIView *)owningView { return _owningView; }
- (void)setOwningView:(UIView *)view { _owningView = view; }
- (CGRect)layoutFrame { return _layoutFrame; }
- (void)_setLayoutFrame:(CGRect)frame { _layoutFrame = frame; }
- (NSString *)identifier { return _identifier; }
- (void)setIdentifier:(NSString *)value { ASSIGNCOPY(_identifier, value); }
- (NSMutableArray *)_uiConstraintReferences { return _uiConstraintReferences; }
- (UILayoutAnchor *)_uiAnchor:(NSLayoutAttribute)a { return UILayoutGetAnchor(self, _uiAnchors, a); }
- (void)_uiLayoutChanged { [_owningView _uiLayoutChanged]; }
UIKIT_ANCHORS
@end

@implementation UIView (UILayout)
- (void)_uiInitializeLayout
{
  _translatesAutoresizingMaskIntoConstraints = YES;
  _uiNeedsUpdateConstraints = YES;
  _uiConstraints = [NSMutableArray new]; _uiLayoutGuides = [NSMutableArray new];
  _uiConstraintReferences = [NSMutableArray new]; _uiAnchors = [NSMutableDictionary new];
  _layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8);
  _uiHugging[0] = _uiHugging[1] = UILayoutPriorityDefaultLow;
  _uiCompression[0] = _uiCompression[1] = UILayoutPriorityDefaultHigh;
}
- (void)_uiDestroyLayout
{
  for (UILayoutConstraint *constraint in _uiConstraints) [constraint _installInView:nil];
  [_uiConstraints removeAllObjects];
  UILayoutInvalidateItem(self, _uiConstraintReferences, _uiAnchors);
  for (UILayoutGuide *guide in _uiLayoutGuides) {
    for (NSValue *reference in [[[guide _uiConstraintReferences] copy] autorelease])
      [(UILayoutConstraint *)[reference pointerValue] setActive:NO];
    [guide setOwningView:nil];
  }
  [_uiConstraints release]; [_uiLayoutGuides release]; [_uiConstraintReferences release]; [_uiAnchors release];
}
- (NSMutableArray *)_uiConstraintReferences { return _uiConstraintReferences; }
- (UILayoutAnchor *)_uiAnchor:(NSLayoutAttribute)a { return UILayoutGetAnchor(self, _uiAnchors, a); }
UIKIT_ANCHORS
- (BOOL)translatesAutoresizingMaskIntoConstraints { return _translatesAutoresizingMaskIntoConstraints; }
- (void)setTranslatesAutoresizingMaskIntoConstraints:(BOOL)value
{ _translatesAutoresizingMaskIntoConstraints = value; [self _uiLayoutChanged]; }
- (NSArray *)constraints { return [[_uiConstraints copy] autorelease]; }
- (void)addConstraint:(UILayoutConstraint *)constraint
{
  UIView *common = UILayoutCommonAncestor([constraint firstItem], [constraint secondItem]);
  if (!common || ![common isDescendantOfView:self])
    [NSException raise:NSInvalidArgumentException format:@"Constraint must be installed on a common ancestor"];
  if ([_uiConstraints containsObject:constraint]) return;
  [[constraint retain] autorelease]; [constraint setActive:NO];
  [_uiConstraints addObject:constraint]; [constraint _installInView:self]; [self _uiLayoutChanged];
}
- (void)addConstraints:(NSArray *)constraints { for (UILayoutConstraint *c in constraints) [self addConstraint:c]; }
- (void)removeConstraint:(UILayoutConstraint *)constraint
{
  if (![_uiConstraints containsObject:constraint]) return;
  [constraint _installInView:nil]; [_uiConstraints removeObjectIdenticalTo:constraint]; [self _uiLayoutChanged];
}
- (void)removeConstraints:(NSArray *)constraints
{ for (UILayoutConstraint *c in [[constraints copy] autorelease]) [self removeConstraint:c]; }
- (void)_uiRemoveAncestorConstraints
{
  for (UIView *ancestor = _superview; ancestor; ancestor = [ancestor superview])
    for (UILayoutConstraint *c in [ancestor constraints])
      if ([UILayoutView([c firstItem]) isDescendantOfView:self] || [UILayoutView([c secondItem]) isDescendantOfView:self])
        [ancestor removeConstraint:c];
}
- (NSArray *)layoutGuides { return [[_uiLayoutGuides copy] autorelease]; }
- (void)addLayoutGuide:(UILayoutGuide *)guide
{
  if ([_uiLayoutGuides containsObject:guide]) return;
  [[guide retain] autorelease]; [[guide owningView] removeLayoutGuide:guide];
  [_uiLayoutGuides addObject:guide]; [guide setOwningView:self]; [self _uiLayoutChanged];
}
- (void)removeLayoutGuide:(UILayoutGuide *)guide
{
  if (![_uiLayoutGuides containsObject:guide]) return;
  [[guide retain] autorelease];
  for (NSValue *reference in [[[guide _uiConstraintReferences] copy] autorelease])
    [(UILayoutConstraint *)[reference pointerValue] setActive:NO];
  if (_safeAreaLayoutGuide == guide) _safeAreaLayoutGuide = nil;
  if (_layoutMarginsGuide == guide) _layoutMarginsGuide = nil;
  [guide setOwningView:nil]; [_uiLayoutGuides removeObjectIdenticalTo:guide]; [self _uiLayoutChanged];
}
- (UILayoutGuide *)safeAreaLayoutGuide
{
  if (!_safeAreaLayoutGuide) { _safeAreaLayoutGuide = [[[UILayoutGuide alloc] init] autorelease]; [self addLayoutGuide:_safeAreaLayoutGuide]; }
  return _safeAreaLayoutGuide;
}
- (UILayoutGuide *)layoutMarginsGuide
{
  if (!_layoutMarginsGuide) { _layoutMarginsGuide = [[[UILayoutGuide alloc] init] autorelease]; [self addLayoutGuide:_layoutMarginsGuide]; }
  return _layoutMarginsGuide;
}
- (UIEdgeInsets)safeAreaInsets { return UIEdgeInsetsZero; }
- (UIEdgeInsets)layoutMargins { return _layoutMargins; }
- (void)setLayoutMargins:(UIEdgeInsets)value { _layoutMargins = value; [self _uiLayoutChanged]; }
- (CGSize)intrinsicContentSize { return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric); }
- (void)invalidateIntrinsicContentSize { [self _uiLayoutChanged]; }
- (UILayoutPriority)contentHuggingPriorityForAxis:(UILayoutConstraintAxis)axis { return _uiHugging[axis == UILayoutConstraintAxisVertical]; }
- (void)setContentHuggingPriority:(UILayoutPriority)p forAxis:(UILayoutConstraintAxis)axis
{ _uiHugging[axis == UILayoutConstraintAxisVertical] = p; [self _uiLayoutChanged]; }
- (UILayoutPriority)contentCompressionResistancePriorityForAxis:(UILayoutConstraintAxis)axis { return _uiCompression[axis == UILayoutConstraintAxisVertical]; }
- (void)setContentCompressionResistancePriority:(UILayoutPriority)p forAxis:(UILayoutConstraintAxis)axis
{ _uiCompression[axis == UILayoutConstraintAxisVertical] = p; [self _uiLayoutChanged]; }
- (void)_uiLayoutChanged
{
  UIView *root = self; while ([root superview]) root = [root superview];
  [root setNeedsLayout];
}
- (void)setNeedsUpdateConstraints { _uiNeedsUpdateConstraints = YES; [self _uiLayoutChanged]; }
- (BOOL)needsUpdateConstraints { return _uiNeedsUpdateConstraints; }
- (void)updateConstraints {}
- (void)updateConstraintsIfNeeded
{
  for (UIView *view in [self subviews]) [view updateConstraintsIfNeeded];
  if (_uiNeedsUpdateConstraints) { _uiNeedsUpdateConstraints = NO; [self updateConstraints]; }
}
@end

/* A feasibility tableau for A*x <= b, with each unrestricted coordinate split
   into positive and negative variables. Phase I removes the artificial variable;
   no objective is needed because priorities are admitted in descending order. */
typedef struct { NSUInteger rows, columns; double *cells; NSInteger *basic, *nonbasic; } UILayoutTableau;
#define UI_CELL(t,r,c) ((t)->cells[(r)*((t)->columns+2)+(c)])
static void UILayoutPivot(UILayoutTableau *t, NSUInteger row, NSUInteger column)
{
  double pivot = UI_CELL(t,row,column);
  for (NSUInteger r = 0; r < t->rows+2; r++) if (r != row)
    for (NSUInteger c = 0; c < t->columns+2; c++) if (c != column)
      UI_CELL(t,r,c) -= UI_CELL(t,row,c)*UI_CELL(t,r,column)/pivot;
  for (NSUInteger c = 0; c < t->columns+2; c++) if (c != column) UI_CELL(t,row,c) /= pivot;
  for (NSUInteger r = 0; r < t->rows+2; r++) if (r != row) UI_CELL(t,r,column) /= -pivot;
  UI_CELL(t,row,column) = 1/pivot;
  NSInteger variable = t->basic[row]; t->basic[row] = t->nonbasic[column]; t->nonbasic[column] = variable;
}
static BOOL UILayoutPhaseOne(UILayoutTableau *t)
{
  const double epsilon = 1e-8;
  for (NSUInteger iteration = 0; iteration < 10000; iteration++) {
    NSInteger entering = -1;
    /* Bland's rule prevents cycling on degenerate constraints. */
    for (NSUInteger c = 0; c <= t->columns; c++)
      if (UI_CELL(t,t->rows+1,c) < -epsilon &&
          (entering < 0 || t->nonbasic[c] < t->nonbasic[entering])) entering = c;
    if (entering < 0) return YES;
    NSInteger leaving = -1;
    for (NSUInteger r = 0; r < t->rows; r++) {
      double divisor = UI_CELL(t,r,entering);
      if (divisor <= epsilon) continue;
      double ratio = UI_CELL(t,r,t->columns+1)/divisor;
      double best = leaving < 0 ? 0 : UI_CELL(t,leaving,t->columns+1)/UI_CELL(t,leaving,entering);
      if (leaving < 0 || ratio < best-epsilon || (fabs(ratio-best) <= epsilon && t->basic[r] < t->basic[leaving])) leaving = r;
    }
    if (leaving < 0) return NO;
    UILayoutPivot(t, leaving, entering);
  }
  return NO;
}
static BOOL UILayoutFeasible(NSArray *rows, NSUInteger variables, double *solution)
{
  UILayoutTableau t = { [rows count], variables*2, NULL, NULL, NULL };
  t.cells = calloc((t.rows+2)*(t.columns+2), sizeof(double));
  t.basic = calloc(t.rows, sizeof(NSInteger)); t.nonbasic = calloc(t.columns+1, sizeof(NSInteger));
  if (!t.cells || !t.basic || !t.nonbasic) { free(t.cells); free(t.basic); free(t.nonbasic); return NO; }
  NSInteger lowest = -1;
  for (NSUInteger r = 0; r < t.rows; r++) {
    const double *row = [[rows objectAtIndex:r] bytes];
    for (NSUInteger c = 0; c < variables; c++) { UI_CELL(&t,r,c*2) = row[c]; UI_CELL(&t,r,c*2+1) = -row[c]; }
    t.basic[r] = t.columns+r; UI_CELL(&t,r,t.columns) = -1; UI_CELL(&t,r,t.columns+1) = row[variables];
    if (lowest < 0 || row[variables] < UI_CELL(&t,lowest,t.columns+1)) lowest = r;
  }
  for (NSUInteger c = 0; c < t.columns; c++) t.nonbasic[c] = c;
  t.nonbasic[t.columns] = -1; UI_CELL(&t,t.rows+1,t.columns) = 1;
  BOOL feasible = YES;
  if (lowest >= 0 && UI_CELL(&t,lowest,t.columns+1) < -1e-8) {
    UILayoutPivot(&t, lowest, t.columns);
    feasible = UILayoutPhaseOne(&t) && fabs(UI_CELL(&t,t.rows+1,t.columns+1)) < 1e-7;
  }
  if (feasible) {
    memset(solution, 0, variables*sizeof(double));
    for (NSUInteger r = 0; r < t.rows; r++)
      if (t.basic[r] >= 0 && t.basic[r] < t.columns)
        solution[t.basic[r]/2] += (t.basic[r]%2 ? -1 : 1)*UI_CELL(&t,r,t.columns+1);
  }
  free(t.cells); free(t.basic); free(t.nonbasic); return feasible;
}

@interface _UILayoutEquation : NSObject
{
@public
  NSMutableData *coefficients;
  NSLayoutRelation relation;
  double priority;
  NSUInteger order;
}
@end
@implementation _UILayoutEquation
- (void)dealloc { [coefficients release]; [super dealloc]; }
@end
static _UILayoutEquation *UILayoutEquation(NSMutableArray *equations, NSUInteger variables, double constant, NSLayoutRelation relation, double priority)
{
  _UILayoutEquation *equation = [[_UILayoutEquation alloc] init];
  equation->coefficients = [[NSMutableData alloc] initWithLength:(variables+1)*sizeof(double)];
  ((double *)[equation->coefficients mutableBytes])[variables] = constant;
  equation->order = [equations count];
  equation->priority = priority; equation->relation = relation;
  [equations addObject:equation]; [equation release]; return equation;
}
static void UILayoutAttribute(double *row, NSUInteger item, NSLayoutAttribute attribute, double multiplier)
{
  NSUInteger base = item*4;
  switch (attribute) {
    case NSLayoutAttributeLeft: case NSLayoutAttributeLeading: row[base] += multiplier; break;
    case NSLayoutAttributeRight: case NSLayoutAttributeTrailing: row[base] += multiplier; row[base+2] += multiplier; break;
    case NSLayoutAttributeTop: row[base+1] += multiplier; break;
    case NSLayoutAttributeBottom: row[base+1] += multiplier; row[base+3] += multiplier; break;
    case NSLayoutAttributeCenterX: row[base] += multiplier; row[base+2] += multiplier/2; break;
    case NSLayoutAttributeCenterY: row[base+1] += multiplier; row[base+3] += multiplier/2; break;
    case NSLayoutAttributeWidth: row[base+2] += multiplier; break;
    case NSLayoutAttributeHeight: row[base+3] += multiplier; break;
    default: break;
  }
}
static NSInteger UILayoutEquationCompare(id a, id b, void *context)
{
  double first = ((_UILayoutEquation *)a)->priority, second = ((_UILayoutEquation *)b)->priority;
  if (first != second) return first > second ? NSOrderedAscending : NSOrderedDescending;
  NSUInteger x = ((_UILayoutEquation *)a)->order, y = ((_UILayoutEquation *)b)->order;
  return x < y ? NSOrderedAscending : x > y ? NSOrderedDescending : NSOrderedSame;
}
static void UILayoutCollect(UIView *view, NSMutableArray *items, NSMutableArray *constraints)
{
  [items addObject:view]; [items addObjectsFromArray:[view layoutGuides]];
  [constraints addObjectsFromArray:[view constraints]];
  for (UIView *child in [view subviews]) UILayoutCollect(child, items, constraints);
}

@implementation UIView (UILayoutSolver)
- (void)_uiSolveLayout
{
  NSMutableArray *items = [NSMutableArray array], *constraints = [NSMutableArray array];
  UILayoutCollect(self, items, constraints);
  BOOL hasGuides = NO;
  for (id item in items) if ([item isKindOfClass:[UILayoutGuide class]]) { hasGuides = YES; break; }
  if (![constraints count] && !hasGuides) return;
  /* Frame-only decoration is not part of the constraint system. Keep items
     participating in constraints, intrinsic sizing or guides, plus their ancestry.
     This prevents a small constrained control from solving every label/cell in
     its window, while retaining the coordinate chains for nested relationships. */
  NSMutableSet *participants = [NSMutableSet setWithObject:self];
  for (UILayoutConstraint *constraint in constraints) {
    [participants addObject:[constraint firstItem]];
    if ([constraint secondItem]) [participants addObject:[constraint secondItem]];
  }
  for (id item in items)
    if ([item isKindOfClass:[UILayoutGuide class]] || ![(UIView *)item translatesAutoresizingMaskIntoConstraints])
      [participants addObject:item];
  for (id item in [participants allObjects])
    for (UIView *view = UILayoutView(item); view; view = [view superview]) [participants addObject:view];
  for (NSInteger i = (NSInteger)[items count]-1; i >= 0; i--)
    if (![participants containsObject:[items objectAtIndex:i]]) [items removeObjectAtIndex:i];
  NSUInteger variables = [items count]*4;
  NSMutableArray *equations = [NSMutableArray array];
  NSMutableDictionary *indices = [NSMutableDictionary dictionary];
  for (NSUInteger i = 0; i < [items count]; i++)
    [indices setObject:[NSNumber numberWithUnsignedInteger:i] forKey:[NSValue valueWithPointer:[items objectAtIndex:i]]];
  for (NSUInteger i = 0; i < [items count]; i++) {
    id item = [items objectAtIndex:i];
    BOOL guide = [item isKindOfClass:[UILayoutGuide class]];
    UIView *parent = guide ? [(UILayoutGuide *)item owningView] : [(UIView *)item superview];
    CGRect frame = guide ? [item layoutFrame] : item == self ? [self bounds] : [item frame];
    NSUInteger p = [[indices objectForKey:[NSValue valueWithPointer:parent]] unsignedIntegerValue];
    BOOL fixed = item == self || (!guide && [item translatesAutoresizingMaskIntoConstraints]);
    BOOL systemGuide = guide && (item == parent->_safeAreaLayoutGuide || item == parent->_layoutMarginsGuide);
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (systemGuide) insets = item == parent->_safeAreaLayoutGuide ? [parent safeAreaInsets] : [parent layoutMargins];
    double values[] = { frame.origin.x, frame.origin.y, frame.size.width, frame.size.height };
    for (NSUInteger c = 0; c < 4; c++) {
      double constant = values[c];
      if (parent && c < 2) constant -= c == 0 ? [parent bounds].origin.x : [parent bounds].origin.y;
      if (systemGuide) constant = c == 0 ? insets.left : c == 1 ? insets.top : c == 2 ? -insets.left-insets.right : -insets.top-insets.bottom;
      _UILayoutEquation *e = UILayoutEquation(equations, variables, constant, NSLayoutRelationEqual, fixed || systemGuide ? 2000 : 1);
      double *row = [e->coefficients mutableBytes]; row[i*4+c] = 1;
      if (parent && (c < 2 || systemGuide)) row[p*4+c] -= 1;
    }
    for (NSUInteger c = 2; c < 4; c++) {
      _UILayoutEquation *e = UILayoutEquation(equations, variables, 0, NSLayoutRelationGreaterThanOrEqual, 2000);
      ((double *)[e->coefficients mutableBytes])[i*4+c] = 1;
    }
    if (!guide && !fixed) {
      CGSize size = [item intrinsicContentSize];
      double dimensions[] = { size.width, size.height };
      for (NSUInteger axis = 0; axis < 2; axis++) if (dimensions[axis] >= 0) {
        _UILayoutEquation *hug = UILayoutEquation(equations, variables, dimensions[axis], NSLayoutRelationLessThanOrEqual, [item contentHuggingPriorityForAxis:axis]);
        _UILayoutEquation *compression = UILayoutEquation(equations, variables, dimensions[axis], NSLayoutRelationGreaterThanOrEqual, [item contentCompressionResistancePriorityForAxis:axis]);
        ((double *)[hug->coefficients mutableBytes])[i*4+2+axis] = 1;
        ((double *)[compression->coefficients mutableBytes])[i*4+2+axis] = 1;
      }
    }
  }
  for (UILayoutConstraint *constraint in constraints) {
    _UILayoutEquation *e = UILayoutEquation(equations, variables, [constraint constant], [constraint relation], [constraint priority]);
    double *row = [e->coefficients mutableBytes];
    NSUInteger first = [[indices objectForKey:[NSValue valueWithPointer:[constraint firstItem]]] unsignedIntegerValue];
    UILayoutAttribute(row, first, [constraint firstAttribute], 1);
    if ([constraint secondItem]) {
      NSUInteger second = [[indices objectForKey:[NSValue valueWithPointer:[constraint secondItem]]] unsignedIntegerValue];
      UILayoutAttribute(row, second, [constraint secondAttribute], -[constraint multiplier]);
    }
  }
  [equations sortUsingFunction:UILayoutEquationCompare context:NULL];
  NSMutableArray *accepted = [NSMutableArray array];
  double *solution = calloc(variables, sizeof(double)), *candidate = calloc(variables, sizeof(double));
  if (!solution || !candidate) { free(solution); free(candidate); return; }
  /* Start with the current geometry. Layout and native drawing can request
     another pass after cells or decoration are added. Re-solving from zero
     needlessly rebuilds the simplex tableau for already-satisfied constraints. */
  for (NSUInteger i = 0; i < items.count; i++) {
    id item = [items objectAtIndex:i]; BOOL guide = [item isKindOfClass:[UILayoutGuide class]];
    UIView *parent = guide ? [(UILayoutGuide *)item owningView] : [(UIView *)item superview];
    CGRect frame = guide ? [item layoutFrame] : item == self ? [self bounds] : [item frame];
    solution[i*4] = frame.origin.x; solution[i*4+1] = frame.origin.y;
    solution[i*4+2] = frame.size.width; solution[i*4+3] = frame.size.height;
    if (parent) {
      NSUInteger p = [[indices objectForKey:[NSValue valueWithPointer:parent]] unsignedIntegerValue];
      solution[i*4] += solution[p*4]-parent.bounds.origin.x;
      solution[i*4+1] += solution[p*4+1]-parent.bounds.origin.y;
    }
  }
  for (_UILayoutEquation *e in equations) {
    NSUInteger previous = [accepted count];
    if (e->relation <= 0) [accepted addObject:e->coefficients];
    if (e->relation >= 0) {
      NSMutableData *negative = [[e->coefficients mutableCopy] autorelease];
      double *row = [negative mutableBytes]; for (NSUInteger c = 0; c <= variables; c++) row[c] = -row[c];
      [accepted addObject:negative];
    }
    /* The current solution already satisfies all accepted equations. Avoid
       rebuilding the tableau if it also satisfies the new equation. */
    const double *coefficients = [e->coefficients bytes];
    double residual = -coefficients[variables];
    for (NSUInteger c = 0; c < variables; c++) residual += coefficients[c]*solution[c];
    BOOL satisfied = e->relation == NSLayoutRelationEqual ? fabs(residual) < 1e-8 :
      e->relation == NSLayoutRelationLessThanOrEqual ? residual <= 1e-8 : residual >= -1e-8;
    if (satisfied) continue;
    if (UILayoutFeasible(accepted, variables, candidate)) memcpy(solution, candidate, variables*sizeof(double));
    else {
      [accepted removeObjectsInRange:NSMakeRange(previous, [accepted count]-previous)];
      if (e->priority >= 1000) NSLog(@"UIKit: breaking an unsatisfiable required layout equation");
    }
  }
  for (NSUInteger i = 1; i < [items count]; i++) {
    id item = [items objectAtIndex:i]; BOOL guide = [item isKindOfClass:[UILayoutGuide class]];
    UIView *parent = guide ? [(UILayoutGuide *)item owningView] : [(UIView *)item superview];
    NSUInteger p = [[indices objectForKey:[NSValue valueWithPointer:parent]] unsignedIntegerValue];
    CGRect frame = CGRectMake(solution[i*4]-solution[p*4]+[parent bounds].origin.x,
      solution[i*4+1]-solution[p*4+1]+[parent bounds].origin.y, MAX(0,solution[i*4+2]), MAX(0,solution[i*4+3]));
    if (guide) {
      if (!NSEqualRects([item layoutFrame], frame)) [parent setNeedsLayout];
      [item _setLayoutFrame:frame];
    }
    else if (![item translatesAutoresizingMaskIntoConstraints]) {
      CGRect old = [item frame];
      if (fabs(old.origin.x-frame.origin.x) > 1e-7 || fabs(old.origin.y-frame.origin.y) > 1e-7 ||
          fabs(old.size.width-frame.size.width) > 1e-7 || fabs(old.size.height-frame.size.height) > 1e-7)
        [item setFrame:frame];
    }
  }
  free(solution); free(candidate);
}
- (void)_uiLayoutPass
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(layoutIfNeeded) object:nil];
  if (_uiNeedsLayout) { _uiNeedsLayout = NO; [self layoutSubviews]; }
  for (UIView *view in [self subviews]) [view _uiLayoutPass];
}
@end
