#ifndef GNUSTEP_UIKIT_UIREFERENCELIBRARYVIEWCONTROLLER_H
#define GNUSTEP_UIKIT_UIREFERENCELIBRARYVIEWCONTROLLER_H
#import <UIKit/UIViewController.h>
@interface UIReferenceLibraryViewController : UIViewController { NSString *_term; }
+ (BOOL)dictionaryHasDefinitionForTerm:(NSString *)term;
- (id)initWithTerm:(NSString *)term;
@end
#endif
