#import <UIKit/UIKit.h>

#if defined(__APPLE__)
#import <OpenGL/gl.h>
#else
#import <GL/gl.h>
#endif

@interface OpenGLDemoView : UIOpenGLView
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
    }

  return self;
}

- (void)prepareOpenGL
{
  [super prepareOpenGL];
  glClearColor(0.07f, 0.09f, 0.12f, 1.0f);
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
  glOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glBegin(GL_TRIANGLES);
    glColor3f(0.95f, 0.27f, 0.22f);
    glVertex2f(0.0f, 0.72f);
    glColor3f(0.16f, 0.68f, 0.92f);
    glVertex2f(-0.72f, -0.54f);
    glColor3f(0.30f, 0.78f, 0.38f);
    glVertex2f(0.72f, -0.54f);
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
