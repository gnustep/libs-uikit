#ifndef GNUSTEP_UIKIT_UIOPENGLVIEW_H
#define GNUSTEP_UIKIT_UIOPENGLVIEW_H

#import <UIKit/GNUstepUIKit.h>

@interface UIOpenGLView : NSOpenGLView
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame pixelFormat:(NSOpenGLPixelFormat *)format;
- (BOOL)makeCurrentOpenGLContext;
@end

#endif
