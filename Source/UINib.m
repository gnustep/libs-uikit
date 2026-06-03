#import "UIKitPrivate.h"

@interface _UIKitXIBParser : NSObject
{
  id _owner;
  NSBundle *_bundle;
  NSMutableArray *_objectStack;
  NSMutableArray *_topLevelObjects;
  NSMutableDictionary *_objectsByID;
  NSMutableArray *_pendingOutlets;
  NSMutableArray *_pendingActions;
}
- (id)initWithOwner:(id)owner bundle:(NSBundle *)bundle;
- (NSArray *)parseFile:(NSString *)path;
@end

@implementation _UIKitXIBParser
- (id)initWithOwner:(id)owner bundle:(NSBundle *)bundle
{
  self = [super init];
  if (self != nil)
    {
      _owner = owner;
      _bundle = [bundle retain];
      _objectStack = [[NSMutableArray alloc] init];
      _topLevelObjects = [[NSMutableArray alloc] init];
      _objectsByID = [[NSMutableDictionary alloc] init];
      _pendingOutlets = [[NSMutableArray alloc] init];
      _pendingActions = [[NSMutableArray alloc] init];
    }
  return self;
}
- (void)dealloc
{
  [_bundle release];
  [_objectStack release];
  [_topLevelObjects release];
  [_objectsByID release];
  [_pendingOutlets release];
  [_pendingActions release];
  [super dealloc];
}
- (NSString *)_classNameForElement:(NSString *)element attributes:(NSDictionary *)attributes
{
  NSString *className = [attributes objectForKey:@"customClass"];
  if (className == nil)
    className = [attributes objectForKey:@"class"];
  if (className != nil)
    return className;

  if ([element isEqualToString:@"view"])
    return @"UIView";
  if ([element isEqualToString:@"label"])
    return @"UILabel";
  if ([element isEqualToString:@"button"])
    return @"UIButton";
  if ([element isEqualToString:@"imageView"])
    return @"UIImageView";
  if ([element isEqualToString:@"textField"])
    return @"UITextField";
  if ([element isEqualToString:@"textView"])
    return @"UITextView";
  if ([element isEqualToString:@"slider"])
    return @"UISlider";
  if ([element isEqualToString:@"switch"])
    return @"UISwitch";
  if ([element isEqualToString:@"segmentedControl"])
    return @"UISegmentedControl";
  if ([element isEqualToString:@"scrollView"])
    return @"UIScrollView";
  if ([element isEqualToString:@"tableView"])
    return @"UITableView";
  if ([element isEqualToString:@"tableViewCell"])
    return @"UITableViewCell";
  if ([element isEqualToString:@"activityIndicatorView"])
    return @"UIActivityIndicatorView";
  if ([element isEqualToString:@"viewController"])
    return @"UIViewController";
  if ([element isEqualToString:@"navigationController"])
    return @"UINavigationController";
  if ([element isEqualToString:@"tabBarController"])
    return @"UITabBarController";

  return nil;
}
- (BOOL)_isObjectElement:(NSString *)element attributes:(NSDictionary *)attributes
{
  if ([element isEqualToString:@"placeholder"])
    return YES;
  return [self _classNameForElement:element attributes:attributes] != nil;
}
- (CGRect)_rectFromAttributes:(NSDictionary *)attributes defaultRect:(CGRect)defaultRect
{
  NSString *x = [attributes objectForKey:@"x"];
  NSString *y = [attributes objectForKey:@"y"];
  NSString *width = [attributes objectForKey:@"width"];
  NSString *height = [attributes objectForKey:@"height"];

  if (width == nil || height == nil)
    return defaultRect;

  return NSMakeRect(x == nil ? 0 : [x doubleValue],
                    y == nil ? 0 : [y doubleValue],
                    [width doubleValue],
                    [height doubleValue]);
}
- (UIColor *)_colorFromAttributes:(NSDictionary *)attributes
{
  NSString *white = [attributes objectForKey:@"white"];
  NSString *red = [attributes objectForKey:@"red"];
  NSString *green = [attributes objectForKey:@"green"];
  NSString *blue = [attributes objectForKey:@"blue"];
  NSString *alpha = [attributes objectForKey:@"alpha"];

  if (alpha == nil)
    alpha = @"1";
  if (white != nil)
    return [UIColor colorWithWhite:[white doubleValue] alpha:[alpha doubleValue]];
  if (red != nil && green != nil && blue != nil)
    return [UIColor _colorWithNSColor:UIKitNSColorFromRGBA([red doubleValue], [green doubleValue], [blue doubleValue], [alpha doubleValue])];
  return nil;
}
- (id)_objectForElement:(NSString *)element attributes:(NSDictionary *)attributes
{
  NSString *placeholder = [attributes objectForKey:@"placeholderIdentifier"];
  NSString *className;
  Class classObject;
  id object = nil;
  CGRect frame = [self _rectFromAttributes:attributes defaultRect:NSMakeRect(0, 0, 320, 480)];

  if ([element isEqualToString:@"placeholder"] && [placeholder isEqualToString:@"IBFilesOwner"])
    object = _owner;
  else
    {
      className = [self _classNameForElement:element attributes:attributes];
      classObject = NSClassFromString(className);
      if (classObject == Nil)
        return nil;

      if ([classObject instancesRespondToSelector:@selector(initWithFrame:)])
        object = [[[classObject alloc] initWithFrame:frame] autorelease];
      else
        object = [[[classObject alloc] init] autorelease];
    }

  if (object != nil)
    {
      NSString *objectID = [attributes objectForKey:@"id"];
      NSString *tag = [attributes objectForKey:@"tag"];
      NSString *text = [attributes objectForKey:@"text"];
      NSString *title = [attributes objectForKey:@"title"];
      NSString *placeholderText = [attributes objectForKey:@"placeholder"];
      NSString *alignment = [attributes objectForKey:@"textAlignment"];
      NSString *image = [attributes objectForKey:@"image"];
      NSString *value = [attributes objectForKey:@"value"];
      NSString *minimumValue = [attributes objectForKey:@"minValue"];
      NSString *maximumValue = [attributes objectForKey:@"maxValue"];
      NSString *on = [attributes objectForKey:@"on"];

      if (objectID != nil)
        [_objectsByID setObject:object forKey:objectID];
      if (tag != nil && [object respondsToSelector:@selector(setTag:)])
        [object setTag:[tag integerValue]];
      if (text != nil && [object respondsToSelector:@selector(setText:)])
        [object setText:text];
      if (title != nil && [object respondsToSelector:@selector(setTitle:forState:)])
        [object setTitle:title forState:UIControlStateNormal];
      if (placeholderText != nil && [object respondsToSelector:@selector(setPlaceholder:)])
        [object setPlaceholder:placeholderText];
      if (alignment != nil && [object respondsToSelector:@selector(setTextAlignment:)])
        [object setTextAlignment:UIKitTextAlignmentFromString(alignment)];
      if (image != nil && [object respondsToSelector:@selector(setImage:)])
        [object setImage:[UIImage imageNamed:image]];
      if (minimumValue != nil && [object respondsToSelector:@selector(setMinimumValue:)])
        [object setMinimumValue:[minimumValue floatValue]];
      if (maximumValue != nil && [object respondsToSelector:@selector(setMaximumValue:)])
        [object setMaximumValue:[maximumValue floatValue]];
      if (value != nil && [object isKindOfClass:[UISlider class]])
        [(UISlider *)object setValue:[value floatValue]];
      if (on != nil && [object respondsToSelector:@selector(setOn:)])
        [object setOn:([on boolValue] || [on isEqualToString:@"YES"] || [on isEqualToString:@"true"])];
    }

  return object;
}
- (void)_connectPendingReferences
{
  NSEnumerator *enumerator;
  NSDictionary *connection;

  enumerator = [_pendingOutlets objectEnumerator];
  while ((connection = [enumerator nextObject]) != nil)
    {
      id source = [connection objectForKey:@"source"];
      id destination = [_objectsByID objectForKey:[connection objectForKey:@"destination"]];
      NSString *property = [connection objectForKey:@"property"];

      if (source != nil && destination != nil && property != nil)
        {
          NS_DURING
            [source setValue:destination forKey:property];
          NS_HANDLER
          NS_ENDHANDLER
        }
    }

  enumerator = [_pendingActions objectEnumerator];
  while ((connection = [enumerator nextObject]) != nil)
    {
      id source = [connection objectForKey:@"source"];
      id destination = [_objectsByID objectForKey:[connection objectForKey:@"destination"]];
      SEL selector = NSSelectorFromString([connection objectForKey:@"selector"]);

      if ([source isKindOfClass:[UIControl class]] && destination != nil && selector != NULL)
        [(UIControl *)source addTarget:destination action:selector forControlEvents:UIControlEventTouchUpInside | UIControlEventValueChanged];
    }
}
- (NSArray *)parseFile:(NSString *)path
{
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSXMLParser *parser;

  if (data == nil)
    return [NSArray array];

  parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
  [parser setDelegate:self];
  if ([parser parse] == NO)
    return [NSArray array];

  [self _connectPendingReferences];

  if (_owner != nil && [_owner respondsToSelector:@selector(setView:)])
    {
      NSEnumerator *enumerator = [_topLevelObjects objectEnumerator];
      id object;
      while ((object = [enumerator nextObject]) != nil)
        {
          if ([object isKindOfClass:[UIView class]])
            {
              [_owner setView:object];
              break;
            }
        }
    }

  return _topLevelObjects;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
  id parent = [_objectStack lastObject];

  if ([self _isObjectElement:elementName attributes:attributeDict])
    {
      id object = [self _objectForElement:elementName attributes:attributeDict];
      if (object != nil)
        {
          if ([parent isKindOfClass:[UIView class]] && [object isKindOfClass:[UIView class]])
            [(UIView *)parent addSubview:object];
          else if (object != _owner)
            [_topLevelObjects addObject:object];
          [_objectStack addObject:object];
        }
      return;
    }

  if ([elementName isEqualToString:@"rect"] && [parent respondsToSelector:@selector(setFrame:)])
    {
      NSString *key = [attributeDict objectForKey:@"key"];
      if (key == nil || [key isEqualToString:@"frame"])
        [parent setFrame:[self _rectFromAttributes:attributeDict defaultRect:[parent frame]]];
    }
  else if ([elementName isEqualToString:@"color"])
    {
      NSString *key = [attributeDict objectForKey:@"key"];
      UIColor *color = [self _colorFromAttributes:attributeDict];
      if (color != nil)
        {
          if ((key == nil || [key isEqualToString:@"backgroundColor"]) && [parent respondsToSelector:@selector(setBackgroundColor:)])
            [parent setBackgroundColor:color];
          else if ([key isEqualToString:@"textColor"] && [parent respondsToSelector:@selector(setTextColor:)])
            [parent setTextColor:color];
        }
    }
  else if ([elementName isEqualToString:@"fontDescription"] && [parent respondsToSelector:@selector(setFont:)])
    {
      NSString *pointSize = [attributeDict objectForKey:@"pointSize"];
      if (pointSize != nil)
        [parent setFont:[UIFont systemFontOfSize:[pointSize doubleValue]]];
    }
  else if ([elementName isEqualToString:@"state"] && [parent respondsToSelector:@selector(setTitle:forState:)])
    {
      NSString *title = [attributeDict objectForKey:@"title"];
      if (title != nil)
        [parent setTitle:title forState:UIControlStateNormal];
    }
  else if ([elementName isEqualToString:@"outlet"])
    {
      NSString *property = [attributeDict objectForKey:@"property"];
      NSString *destination = [attributeDict objectForKey:@"destination"];
      if (parent != nil && property != nil && destination != nil)
        [_pendingOutlets addObject:[NSDictionary dictionaryWithObjectsAndKeys:parent, @"source", property, @"property", destination, @"destination", nil]];
    }
  else if ([elementName isEqualToString:@"action"])
    {
      NSString *selector = [attributeDict objectForKey:@"selector"];
      NSString *destination = [attributeDict objectForKey:@"destination"];
      if (parent != nil && selector != nil && destination != nil)
        [_pendingActions addObject:[NSDictionary dictionaryWithObjectsAndKeys:parent, @"source", selector, @"selector", destination, @"destination", nil]];
    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  if ([self _isObjectElement:elementName attributes:[NSDictionary dictionary]] && [_objectStack count] > 0)
    [_objectStack removeLastObject];
}
@end

@implementation UINib
+ (UINib *)nibWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
  return [[[self alloc] initWithNibName:name bundle:bundle] autorelease];
}
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
  self = [super init];
  if (self != nil)
    {
      _nibName = [name copy];
      _bundle = [(bundle == nil ? [NSBundle mainBundle] : bundle) retain];
    }
  return self;
}
- (void)dealloc
{
  [_nibName release];
  [_bundle release];
  [super dealloc];
}
- (NSArray *)_instantiateXMLXibAtPath:(NSString *)path owner:(id)owner
{
  _UIKitXIBParser *parser = [[[_UIKitXIBParser alloc] initWithOwner:owner bundle:_bundle] autorelease];
  return [parser parseFile:path];
}
- (NSArray *)instantiateWithOwner:(id)owner options:(NSDictionary *)options
{
  NSString *path;
  NSMutableArray *topLevelObjects = [NSMutableArray array];

  path = [_bundle pathForResource:_nibName ofType:@"xib"];
  if (path != nil)
    return [self _instantiateXMLXibAtPath:path owner:owner];

  if ([_bundle respondsToSelector:@selector(loadNibNamed:owner:topLevelObjects:)])
    {
      if ([_bundle loadNibNamed:_nibName owner:owner topLevelObjects:&topLevelObjects])
        return topLevelObjects;
    }

  path = [_bundle pathForResource:_nibName ofType:@"nib"];
  if (path != nil)
    {
      NSNib *nib = [[[NSNib alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]] autorelease];
      NSArray *objects = nil;
      if ([nib instantiateNibWithOwner:owner topLevelObjects:&objects])
        return objects;
    }

  return [NSArray array];
}
@end
