#import <UIKit/UIOpenGLView.h>
#import <UIKit/GNUstepUIKit.h>
#include <math.h>

#if defined(__APPLE__)
#import <OpenGL/gl.h>
#else
#import <GL/gl.h>
#endif

@interface OpenGLDemoView : UIOpenGLView
{
  NSTimer *_animationTimer;
  GLfloat _rotationAngle;
  NSTimeInterval _lastTick;
  BOOL _paused, _smoke, _renderedCube;
  NSUInteger _frameCount;
}
- (void)stopAnimation;
- (void)setPaused:(BOOL)paused;
- (BOOL)isPaused;
- (void)resetRotation;
- (GLfloat)rotationAngle;
- (void)verifyRendering;
@end

@implementation OpenGLDemoView
- (id)initWithFrame:(CGRect)frame
{
  NSOpenGLPixelFormatAttribute attributes[] = {
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFAColorSize, 24,
    NSOpenGLPFADepthSize, 16,
    0
  };
  NSOpenGLPixelFormat *pixelFormat;

  pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
  self = [super initWithFrame:frame pixelFormat:pixelFormat];
  [pixelFormat release];

  if (self != nil)
    {
      [self setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      _lastTick = [NSDate timeIntervalSinceReferenceDate];
      _smoke = [[[NSProcessInfo processInfo] arguments] containsObject:@"--smoke"];
      _animationTimer = [[NSTimer scheduledTimerWithTimeInterval:(1.0 / 60.0)
                                                          target:self
                                                        selector:@selector(advanceAnimation:)
                                                        userInfo:nil
                                                         repeats:YES] retain];
    }

  return self;
}

- (void)dealloc
{
  [self stopAnimation];
  [super dealloc];
}

- (void)prepareOpenGL
{
  [super prepareOpenGL];
  glClearColor(0.07f, 0.09f, 0.12f, 1.0f);
  glEnable(GL_DEPTH_TEST);
  glDepthFunc(GL_LEQUAL);
  glShadeModel(GL_SMOOTH);
}

- (void)stopAnimation
{
  [_animationTimer invalidate];
  [_animationTimer release];
  _animationTimer = nil;
}

- (BOOL)isPaused { return _paused; }
- (GLfloat)rotationAngle { return _rotationAngle; }
- (void)setPaused:(BOOL)paused
{
  _paused = paused;
  _lastTick = [NSDate timeIntervalSinceReferenceDate];
}

- (void)resetRotation
{
  _rotationAngle = 0;
  _lastTick = [NSDate timeIntervalSinceReferenceDate];
  [self setNeedsDisplay:YES];
}

- (void)advanceAnimation:(NSTimer *)timer
{
  NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
  NSTimeInterval elapsed = MAX(0, MIN(now - _lastTick, 0.1));
  _lastTick = now;
  if (_paused) return;
  _rotationAngle = fmod(_rotationAngle + elapsed * 60.0, 360.0);
  [self setNeedsDisplay:YES];
}

- (void)verifyRendering
{
  NSAssert(_frameCount >= 2 && _rotationAngle > 0, @"Cube did not animate");
  NSAssert(_renderedCube, @"OpenGL did not render a colored cube");
  NSAssert(_paused, @"UIKit pause button did not pause animation");
  GLfloat angle = _rotationAngle;
  [self advanceAnimation:nil];
  NSAssert(angle == _rotationAngle, @"Paused cube moved");
}

- (void)reshape
{
  NSRect bounds;

  [super reshape];
  if ([self makeCurrentOpenGLContext] == NO)
    return;

  bounds = [self bounds];
  glViewport(0, 0, (GLsizei)NSWidth(bounds), (GLsizei)NSHeight(bounds));
}

- (void)drawRect:(NSRect)dirtyRect
{
  (void)dirtyRect;

  if ([self makeCurrentOpenGLContext] == NO)
    return;

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  {
    NSRect bounds = [self bounds];
    GLdouble width = NSWidth(bounds);
    GLdouble height = NSHeight(bounds);
    GLdouble aspect = (height > 0.0) ? (width / height) : 1.0;
    GLdouble nearPlane = 1.0;
    GLdouble farPlane = 20.0;
    GLdouble top = 0.58;
    GLdouble right = top * aspect;

    glFrustum(-right, right, -top, top, nearPlane, farPlane);
  }

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glTranslatef(0.0f, 0.0f, -4.0f);
  glRotatef(_rotationAngle, 1.0f, 1.0f, 0.0f);
  glRotatef(_rotationAngle * 0.6f, 0.0f, 1.0f, 1.0f);

  glBegin(GL_QUADS);
    glColor3f(0.95f, 0.18f, 0.16f);
    glVertex3f(-1.0f, -1.0f,  1.0f);
    glVertex3f( 1.0f, -1.0f,  1.0f);
    glVertex3f( 1.0f,  1.0f,  1.0f);
    glVertex3f(-1.0f,  1.0f,  1.0f);

    glColor3f(0.16f, 0.47f, 0.95f);
    glVertex3f( 1.0f, -1.0f, -1.0f);
    glVertex3f(-1.0f, -1.0f, -1.0f);
    glVertex3f(-1.0f,  1.0f, -1.0f);
    glVertex3f( 1.0f,  1.0f, -1.0f);

    glColor3f(0.18f, 0.78f, 0.32f);
    glVertex3f(-1.0f,  1.0f,  1.0f);
    glVertex3f( 1.0f,  1.0f,  1.0f);
    glVertex3f( 1.0f,  1.0f, -1.0f);
    glVertex3f(-1.0f,  1.0f, -1.0f);

    glColor3f(0.98f, 0.74f, 0.18f);
    glVertex3f(-1.0f, -1.0f, -1.0f);
    glVertex3f( 1.0f, -1.0f, -1.0f);
    glVertex3f( 1.0f, -1.0f,  1.0f);
    glVertex3f(-1.0f, -1.0f,  1.0f);

    glColor3f(0.82f, 0.26f, 0.88f);
    glVertex3f( 1.0f, -1.0f,  1.0f);
    glVertex3f( 1.0f, -1.0f, -1.0f);
    glVertex3f( 1.0f,  1.0f, -1.0f);
    glVertex3f( 1.0f,  1.0f,  1.0f);

    glColor3f(0.12f, 0.78f, 0.82f);
    glVertex3f(-1.0f, -1.0f, -1.0f);
    glVertex3f(-1.0f, -1.0f,  1.0f);
    glVertex3f(-1.0f,  1.0f,  1.0f);
    glVertex3f(-1.0f,  1.0f, -1.0f);
  glEnd();

  if (_smoke)
    {
      GLint viewport[4];
      GLubyte pixel[3];
      glGetIntegerv(GL_VIEWPORT, viewport);
      glReadPixels(viewport[2] / 2, viewport[3] / 2, 1, 1,
                   GL_RGB, GL_UNSIGNED_BYTE, pixel);
      _renderedCube = pixel[0] > 80 || pixel[1] > 80 || pixel[2] > 80;
      NSAssert(glGetError() == GL_NO_ERROR, @"OpenGL rendering error");
    }
  _frameCount++;
  glFlush();
  if ([self makeCurrentOpenGLContext])
    [[self openGLContext] flushBuffer];
}
@end

/* UIOpenGLView is an explicit desktop extension (an NSOpenGLView).
   Keep it inside a UIKit host; the controls use the logical UIKit hierarchy. */
@interface CubeHostView : UIView
@end
@implementation CubeHostView
- (void)layoutSubviews
{
  [super layoutSubviews];
  for (NSView *peer in [[self _nativeView] subviews])
    [peer setFrame:[[self _nativeView] bounds]];
}
@end

@interface OpenGLExampleAppDelegate : NSObject <UIApplicationDelegate>
{
  UIWindow *_window;
  OpenGLDemoView *_openGLView;
  UIButton *_pauseButton;
  CubeHostView *_host;
}
@end

@implementation OpenGLExampleAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
  _window = [[UIWindow alloc] initWithFrame:CGRectMake(120, 120, 640, 520)];
  [[_window _nativeWindow] setTitle:@"UIKit · Spinning Cube"];
  [[_window _nativeWindow] setMinSize:NSMakeSize(360, 320)];
  [_window setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1]];

  UILabel *heading = [[[UILabel alloc] initWithFrame:CGRectMake(20, 12, 400, 30)] autorelease];
  [heading setText:@"UIKit / 3D Cube"];
  [heading setTextColor:[UIColor colorWithWhite:0.15 alpha:1]];
  [heading setFont:[UIFont boldSystemFontOfSize:22]];
  [_window addSubview:heading];

  _host = [[CubeHostView alloc] initWithFrame:CGRectMake(16, 52, 608, 400)];
  [_host setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_window addSubview:_host];
  _openGLView = [[OpenGLDemoView alloc] initWithFrame:[[_host _nativeView] bounds]];
  [[_host _nativeView] addSubview:_openGLView];

  _pauseButton = [UIButton buttonWithType:0];
  [_pauseButton setFrame:CGRectMake(16, 468, 110, 32)];
  [_pauseButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
  [_pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
  [_pauseButton addTarget:self action:@selector(togglePause:) forControlEvents:UIControlEventTouchUpInside];
  [_window addSubview:_pauseButton];

  UIButton *reset = [UIButton buttonWithType:0];
  [reset setFrame:CGRectMake(138, 468, 110, 32)];
  [reset setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
  [reset setTitle:@"Reset" forState:UIControlStateNormal];
  [reset addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
  [reset setTag:100];
  [_window addSubview:reset];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowClosed:)
    name:NSWindowWillCloseNotification object:[_window _nativeWindow]];
  [_window makeKeyAndVisible];
  if ([[[NSProcessInfo processInfo] arguments] containsObject:@"--smoke"])
    [self performSelector:@selector(smoke) withObject:nil afterDelay:1.0];
}

- (void)togglePause:(id)sender
{
  [_openGLView setPaused:![_openGLView isPaused]];
  [_pauseButton setTitle:([_openGLView isPaused] ? @"Resume" : @"Pause") forState:UIControlStateNormal];
}
- (void)reset:(id)sender { [_openGLView resetRotation]; }
- (void)windowClosed:(NSNotification *)notification
{
  [_openGLView stopAnimation];
  [[UIApplication sharedApplication] terminate:self];
}
- (void)smoke
{
  @try
    {
      [_pauseButton sendActionsForControlEvents:UIControlEventTouchUpInside];
      [_openGLView verifyRendering];
      [(UIControl *)[_window viewWithTag:100] sendActionsForControlEvents:UIControlEventTouchUpInside];
      NSAssert([_openGLView rotationAngle] == 0, @"UIKit reset button failed");
      [[_window _nativeWindow] setContentSize:NSMakeSize(800, 600)];
      [_window layoutIfNeeded];
      [_host layoutIfNeeded];
      [[_window _nativeWindow] display];
      NSAssert(NSEqualRects([_openGLView frame], [[_host _nativeView] bounds]), @"Cube did not resize");
      [_pauseButton sendActionsForControlEvents:UIControlEventTouchUpInside];
      NSAssert(![_openGLView isPaused], @"UIKit resume button failed");
      NSLog(@"PASS: cube rendered, animated, paused, reset and resized");
      [_window close];
    }
  @catch (NSException *exception)
    {
      NSLog(@"FAIL: cube %@", exception);
      exit(1);
    }
}
- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_openGLView stopAnimation];
  [_openGLView release];
  [_host release];
  [_window release];
  [super dealloc];
}
@end

int main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  int result = UIApplicationMain(argc, argv, nil, @"OpenGLExampleAppDelegate");
  [pool drain];
  return result;
}
