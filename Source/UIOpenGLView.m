#import <UIKit/UIOpenGLView.h>
#import <objc/runtime.h>

typedef void (*UIKitLockFocusIMP)(id, SEL, NSGraphicsContext *, NSRect);

@interface NSOpenGLView (GNUstepUIKitPrivate)
- (void)_lockFocusInContext:(NSGraphicsContext *)context inRect:(NSRect)rect;
@end

@implementation UIOpenGLView
- (void)_disableOpenGLContext
{
  [glcontext clearDrawable];
  [self clearGLContext];
  prepared = NO;
}

- (void)_attachOpenGLContextIfPossible
{
  NSRect bounds;

  bounds = [self bounds];
  if (glcontext != nil
      && [self window] != nil
      && NSIsEmptyRect(bounds) == NO
      && [glcontext view] != self)
    {
      [glcontext setView:self];
    }
}

- (void)_prepareOpenGLIfNeeded
{
  if (!prepared)
    {
      prepared = YES;
      [self prepareOpenGL];
      [self reshape];
    }
}

- (void)viewDidMoveToWindow
{
  [super viewDidMoveToWindow];

  if ([self window] == nil)
    {
      [glcontext clearDrawable];
      prepared = NO;
      return;
    }

  [self _attachOpenGLContextIfPossible];
  if ([self makeCurrentOpenGLContext])
    {
      [self update];
      [self reshape];
      [self setNeedsDisplay:YES];
    }
}

- (void)_frameChanged:(NSNotification *)notification
{
  (void)notification;

  if (prepared && [self makeCurrentOpenGLContext])
    {
      [self update];
      [self reshape];
    }
}

- (void)_lockFocusInContext:(NSGraphicsContext *)context inRect:(NSRect)rect
{
  UIKitLockFocusIMP lockFocus;

  lockFocus = (UIKitLockFocusIMP)class_getMethodImplementation([NSView class], _cmd);
  if (lockFocus != NULL)
    lockFocus(self, _cmd, context, rect);

  if ([self makeCurrentOpenGLContext] == NO)
    return;

  [self _prepareOpenGLIfNeeded];
}

- (void)update
{
  if (glcontext != nil && [glcontext view] == self)
    [glcontext update];
}

- (BOOL)makeCurrentOpenGLContext
{
  NSOpenGLContext *context;
  BOOL madeCurrent;

  if ([self window] == nil || NSIsEmptyRect([self bounds]))
    return NO;

  context = [self openGLContext];
  if (context == nil)
    return NO;

  [self _attachOpenGLContextIfPossible];
  if ([context view] != self)
    return NO;

  madeCurrent = YES;
  NS_DURING
    {
      [context makeCurrentContext];
    }
  NS_HANDLER
    {
      NSLog(@"Unable to make OpenGL context current: %@", localException);
      [self _disableOpenGLContext];
      madeCurrent = NO;
    }
  NS_ENDHANDLER

  if (madeCurrent)
    [self _prepareOpenGLIfNeeded];

  return madeCurrent;
}

- (id)initWithFrame:(CGRect)frame
{
  return [self initWithFrame:frame pixelFormat:[NSOpenGLView defaultPixelFormat]];
}

- (id)initWithFrame:(CGRect)frame pixelFormat:(NSOpenGLPixelFormat *)format
{
  return [super initWithFrame:frame pixelFormat:format];
}

- (NSOpenGLContext *)openGLContext
{
  if (glcontext == nil)
    {
      NSOpenGLContext *context;

      context = [[NSOpenGLContext alloc] initWithFormat:pixel_format
                                           shareContext:nil];
      [self setOpenGLContext:context];
      [context release];
    }

  [self _attachOpenGLContextIfPossible];

  return glcontext;
}
@end
