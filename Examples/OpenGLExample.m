#import <UIKit/UIKit.h>

#if defined(__APPLE__)
#import <OpenGL/gl.h>
#else
#import <GL/gl.h>
#endif

@interface OpenGLDemoView : UIOpenGLView
{
  NSTimer *_animationTimer;
  GLfloat _rotationAngle;
}
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
  [_animationTimer invalidate];
  [_animationTimer release];
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

- (void)advanceAnimation:(NSTimer *)timer
{
  (void)timer;

  _rotationAngle += 1.0f;
  if (_rotationAngle >= 360.0f)
    _rotationAngle -= 360.0f;

  [self setNeedsDisplay:YES];
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

  glFlush();
  if ([self makeCurrentOpenGLContext])
    [[self openGLContext] flushBuffer];
}
@end

@interface OpenGLExampleAppDelegate : NSObject <UIApplicationDelegate>
{
  UIWindow *_window;
  OpenGLDemoView *_openGLView;
}
@end

@implementation OpenGLExampleAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
  (void)application;

  _window = [[UIWindow alloc] initWithFrame:CGRectMake(120, 120, 480, 360)];
  _openGLView = [[OpenGLDemoView alloc] initWithFrame:[[_window contentView] bounds]];

  [_window setTitle:@"GNUstep UIKit OpenGL Example"];
  [[_window contentView] addSubview:_openGLView];
  [_window makeKeyAndVisible];
  [_openGLView setNeedsDisplay:YES];
}

- (void)dealloc
{
  [_openGLView release];
  [_window release];
  [super dealloc];
}
@end

int
main(int argc, char **argv)
{
  return UIApplicationMain(argc, argv, nil, @"OpenGLExampleAppDelegate");
}
