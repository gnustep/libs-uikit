#ifndef GNUSTEP_UIKIT_UIFONTDESCRIPTOR_H
#define GNUSTEP_UIKIT_UIFONTDESCRIPTOR_H
#import <Foundation/Foundation.h>
@interface UIFontDescriptor : NSObject <NSCopying>
{ NSString *_fontName; CGFloat _pointSize; }
+ (UIFontDescriptor *)fontDescriptorWithName:(NSString *)name size:(CGFloat)size;
@property(nonatomic, readonly, copy) NSString *postscriptName;
@property(nonatomic, readonly) CGFloat pointSize;
@end
#endif
