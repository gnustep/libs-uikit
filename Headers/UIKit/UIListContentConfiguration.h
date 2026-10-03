#ifndef GNUSTEP_UIKIT_UILISTCONTENTCONFIGURATION_H
#define GNUSTEP_UIKIT_UILISTCONTENTCONFIGURATION_H
#import <UIKit/UIContentConfiguration.h>
@class UIImage;
@interface UIListContentConfiguration : NSObject <UIContentConfiguration>
{ NSString *_text, *_secondaryText; UIImage *_image; }
+ (instancetype)cellConfiguration;
+ (instancetype)subtitleCellConfiguration;
+ (instancetype)plainHeaderConfiguration;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *secondaryText;
@property(nonatomic, retain) UIImage *image;
@end
#endif
