#if defined(UIKIT_ANDROID_HOST)
/* Minimal Android GNUstep display backend for UIKit's single-window cube host.
   AppKit peers remain private; Android supplies Canvas, fonts and EGL surfaces. */
#import "UIKitPrivate.h"
#import "UIKitAndroid.h"
#import <GNUstepGUI/GSDisplayServer.h>
#import <GNUstepGUI/GSFontInfo.h>
#import "gsc/GSContext.h"
#import "headless/HeadlessGState.h"
#import <EGL/egl.h>
#import <GLES/gl.h>
#import <android/log.h>

static JNIEnv *UIEnv;
static jobject UIHost;
static jmethodID PathMethod, TextMethod, MeasureMethod, PixelsMethod;
static int ScreenWidth = 640, ScreenHeight = 520;
static UIControl *TrackingControl;
static BOOL Active = YES;

static void CheckJava(void)
{
  if ((*UIEnv)->ExceptionCheck(UIEnv)) {
    (*UIEnv)->ExceptionDescribe(UIEnv);
    (*UIEnv)->ExceptionClear(UIEnv);
    [NSException raise:NSInternalInconsistencyException format:@"Android host callback failed"];
  }
}
static jstring JavaString(NSString *s)
{
  NSUInteger n = [s length];
  unichar *chars = malloc(MAX(1, n) * sizeof(unichar));
  [s getCharacters:chars range:NSMakeRange(0, n)];
  jstring result = (*UIEnv)->NewString(UIEnv, chars, n);
  free(chars);
  return result;
}
static float TextWidth(NSString *text, float size, BOOL bold)
{
  jstring s = JavaString(text);
  float width = (*UIEnv)->CallFloatMethod(UIEnv, UIHost, MeasureMethod, s, size, (jboolean)bold);
  (*UIEnv)->DeleteLocalRef(UIEnv, s); CheckJava();
  return width;
}
static jint PixelColor(device_color_t color)
{
  gsColorToRGB(&color);
  return ((unsigned)(MAX(0, MIN(1, color.field[AINDEX])) * 255) << 24) |
    ((unsigned)(MAX(0, MIN(1, color.field[0])) * 255) << 16) |
    ((unsigned)(MAX(0, MIN(1, color.field[1])) * 255) << 8) |
    (unsigned)(MAX(0, MIN(1, color.field[2])) * 255);
}

@interface UIKitAndroidFonts : GSFontEnumerator @end
@implementation UIKitAndroidFonts
- (void)enumerateFontsAndFamilies
{
  allFontNames = [@[@"AndroidSans", @"AndroidSans-Bold"] retain];
  allFontFamilies = [@{@"AndroidSans": @[@[@"AndroidSans", @"Regular", @5, @0],
    @[@"AndroidSans-Bold", @"Bold", @9, @(NSBoldFontMask)]]} mutableCopy];
}
- (NSString *)defaultSystemFontName { return @"AndroidSans"; }
- (NSString *)defaultBoldSystemFontName { return @"AndroidSans-Bold"; }
- (NSString *)defaultFixedPitchFontName { return @"AndroidSans"; }
@end
@interface UIKitAndroidFont : GSFontInfo @end
@implementation UIKitAndroidFont
- (id)initWithFontName:(NSString *)name matrix:(const CGFloat *)m screenFont:(BOOL)screen
{
  self = [super init];
  if (self) {
    fontName = [name copy]; familyName = [@"AndroidSans" copy]; memcpy(matrix, m, sizeof(matrix));
    CGFloat size = fabs(m[0]);
    ascender = size * .93; descender = -size * .24; capHeight = size * .72;
    xHeight = size * .54; underlinePosition = -size * .1; underlineThickness = MAX(1, size / 16);
    fontBBox = NSMakeRect(0, descender, size, ascender - descender);
    maximumAdvancement = NSMakeSize(size, 0); numberOfGlyphs = 65536;
    traits = [name hasSuffix:@"-Bold"] ? NSBoldFontMask : 0;
    weight = traits ? 9 : 5;
    mostCompatibleStringEncoding = NSUTF8StringEncoding;
  }
  return self;
}
- (NSGlyph)glyphForCharacter:(unichar)c { return c; }
- (BOOL)glyphIsEncoded:(NSGlyph)g { return g < 65536; }
- (NSSize)advancementForGlyph:(NSGlyph)g {
  unichar c = g;
  return NSMakeSize(TextWidth([NSString stringWithCharacters:&c length:1], fabs(matrix[0]), traits != 0), 0);
}
- (NSRect)boundingRectForGlyph:(NSGlyph)g { NSRect r = fontBBox; r.size.width = [self advancementForGlyph:g].width; return r; }
- (CGFloat)widthOfString:(NSString *)s { return TextWidth(s, fabs(matrix[0]), traits != 0); }
- (CGFloat)defaultLineHeightForFont { return ascender - descender; }
@end

@interface UIKitAndroidState : HeadlessGState { NSRect _clip; }
@end
@implementation UIKitAndroidState
- (id)initWithDrawContext:(GSContext *)context
{
  self = [super initWithDrawContext:context];
  if (self) _clip = NSMakeRect(0, 0, ScreenWidth, ScreenHeight);
  return self;
}
- (id)copyWithZone:(NSZone *)zone { UIKitAndroidState *copy = [super copyWithZone:zone]; copy->_clip = _clip; return copy; }
- (void)DPSinitclip { _clip = NSMakeRect(0, 0, ScreenWidth, ScreenHeight); }
- (void)DPSclip { _clip = NSIntersectionRect(_clip, [path bounds]); }
- (void)DPSeoclip { [self DPSclip]; }
- (void)_paintPath:(ctxt_object_t)type
{
  NSUInteger count = [path elementCount];
  if (!count) return;
  jfloat *points = malloc(count * 7 * sizeof(jfloat));
  NSUInteger n = 0;
  for (NSUInteger i = 0; i < count; i++) {
    NSPoint p[3]; NSBezierPathElement e = [path elementAtIndex:i associatedPoints:p];
    points[n++] = e;
    NSUInteger length = e == NSCurveToBezierPathElement ? 3 : e == NSClosePathBezierPathElement ? 0 : 1;
    for (NSUInteger j = 0; j < length; j++) {
      points[n++] = p[j].x;
      points[n++] = ScreenHeight - p[j].y;
    }
  }
  jfloatArray data = (*UIEnv)->NewFloatArray(UIEnv, n);
  (*UIEnv)->SetFloatArrayRegion(UIEnv, data, 0, n, points); free(points);
  CGFloat width = 1; [self DPScurrentlinewidth:&width];
  (*UIEnv)->CallVoidMethod(UIEnv, UIHost, PathMethod, data,
    PixelColor(type == path_stroke ? strokeColor : fillColor), (jfloat)width, (jboolean)(type == path_stroke),
    (jfloat)NSMinX(_clip), (jfloat)(ScreenHeight - NSMaxY(_clip)), (jfloat)NSMaxX(_clip), (jfloat)(ScreenHeight - NSMinY(_clip)));
  (*UIEnv)->DeleteLocalRef(UIEnv, data); CheckJava();
}
- (void)DPSfill { [self _paintPath:path_fill]; [self DPSnewpath]; }
- (void)DPSeofill { [self DPSfill]; }
- (void)DPSstroke { [self _paintPath:path_stroke]; [self DPSnewpath]; }
- (void)compositerect:(NSRect)r op:(NSCompositingOperation)op
{ [self DPSrectfill:r.origin.x :r.origin.y :r.size.width :r.size.height]; }
- (void)GSShowGlyphsWithAdvances:(const NSGlyph *)glyphs :(const NSSize *)advances :(size_t)length
{
  NSPoint origin = [path elementCount] ? [path currentPoint] : [ctm transformPoint:NSZeroPoint];
  NSPoint position = NSZeroPoint;
  for (size_t i = 0; i < length; i++) {
    NSAffineTransformStruct transform = [ctm transformStruct];
    NSPoint p = NSMakePoint(origin.x + transform.m11 * position.x + transform.m21 * position.y,
      origin.y + transform.m12 * position.x + transform.m22 * position.y);
    unichar character = glyphs[i];
    jstring text = (*UIEnv)->NewString(UIEnv, &character, 1);
    (*UIEnv)->CallVoidMethod(UIEnv, UIHost, TextMethod, text, (jfloat)p.x,
      (jfloat)(ScreenHeight - p.y), (jfloat)fabs([font matrix][0]), (jboolean)(([font traits] & NSBoldFontMask) != 0), PixelColor(fillColor),
      (jfloat)NSMinX(_clip), (jfloat)(ScreenHeight - NSMaxY(_clip)), (jfloat)NSMaxX(_clip), (jfloat)(ScreenHeight - NSMinY(_clip)));
    (*UIEnv)->DeleteLocalRef(UIEnv, text); CheckJava();
    position.x += advances[i].width; position.y += advances[i].height;
  }
}
@end
@interface UIKitAndroidContext : GSContext @end
@implementation UIKitAndroidContext
+ (Class)GStateClass { return [UIKitAndroidState class]; }
- (BOOL)isDrawingToScreen { return YES; }
- (void)flushGraphics {}
- (void)GSSetDevice:(void *)device :(int)x :(int)y { [gstate setOffset:NSMakePoint(x, y)]; [gstate DPSinitclip]; }
- (void)GSCurrentDevice:(void **)device :(int *)x :(int *)y { if (device) *device = NULL; if (x) *x = 0; if (y) *y = ScreenHeight; }
@end

@interface UIKitAndroidPixelFormat : NSOpenGLPixelFormat @end
@implementation UIKitAndroidPixelFormat
- (id)initWithAttributes:(NSOpenGLPixelFormatAttribute *)attributes { return self; }
- (int)numberOfVirtualScreens { return 1; }
- (void)getValues:(int *)values forAttribute:(NSOpenGLPixelFormatAttribute)attribute forVirtualScreen:(int)screen
{ *values = attribute == NSOpenGLPFADepthSize ? 16 : attribute == NSOpenGLPFAColorSize ? 24 : 1; }
@end
@interface UIKitAndroidGLContext : NSOpenGLContext {
  EGLDisplay _display; EGLContext _context; EGLSurface _surface; EGLConfig _config;
  NSView *_view; int _width, _height;
}
@end
static UIKitAndroidGLContext *CurrentGL;
@implementation UIKitAndroidGLContext
- (id)initWithFormat:(NSOpenGLPixelFormat *)format shareContext:(NSOpenGLContext *)share
{
  _display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
  EGLint count, attributes[] = { EGL_SURFACE_TYPE, EGL_PBUFFER_BIT, EGL_RENDERABLE_TYPE, EGL_OPENGL_ES_BIT,
    EGL_RED_SIZE, 8, EGL_GREEN_SIZE, 8, EGL_BLUE_SIZE, 8, EGL_DEPTH_SIZE, 16, EGL_NONE };
  EGLint contextAttributes[] = { EGL_CONTEXT_CLIENT_VERSION, 1, EGL_NONE };
  if (!eglInitialize(_display, NULL, NULL) || !eglChooseConfig(_display, attributes, &_config, 1, &count) || !count)
    [NSException raise:NSInternalInconsistencyException format:@"EGL configuration failed: 0x%x", eglGetError()];
  _context = eglCreateContext(_display, _config, share ? ((UIKitAndroidGLContext *)share)->_context : EGL_NO_CONTEXT, contextAttributes);
  if (_context == EGL_NO_CONTEXT) [NSException raise:NSInternalInconsistencyException format:@"EGL context failed"];
  return self;
}
- (void)clearDrawable
{
  if (CurrentGL == self) [[self class] clearCurrentContext];
  if (_surface != EGL_NO_SURFACE) eglDestroySurface(_display, _surface);
  _surface = EGL_NO_SURFACE; _width = _height = 0; _view = nil;
}
- (void)dealloc { [self clearDrawable]; eglDestroyContext(_display, _context); [super dealloc]; }
- (void)setView:(NSView *)view { _view = view; [self update]; }
- (NSView *)view { return _view; }
- (void)update
{
  int w = MAX(1, NSWidth([_view bounds])), h = MAX(1, NSHeight([_view bounds]));
  if (w == _width && h == _height) return;
  if (CurrentGL == self) [[self class] clearCurrentContext];
  if (_surface != EGL_NO_SURFACE) eglDestroySurface(_display, _surface);
  EGLint attributes[] = { EGL_WIDTH, w, EGL_HEIGHT, h, EGL_NONE };
  _surface = eglCreatePbufferSurface(_display, _config, attributes);
  if (_surface == EGL_NO_SURFACE) [NSException raise:NSInternalInconsistencyException format:@"EGL surface failed"];
  _width = w; _height = h;
}
- (void)makeCurrentContext
{
  [self update];
  if (!eglMakeCurrent(_display, _surface, _surface, _context))
    [NSException raise:NSInternalInconsistencyException format:@"EGL make current failed"];
  CurrentGL = self;
}
+ (id)currentContext { return CurrentGL; }
+ (void)clearCurrentContext { if (CurrentGL) eglMakeCurrent(CurrentGL->_display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT); CurrentGL = nil; }
- (void)flushBuffer
{
  [self makeCurrentContext];
  size_t size = (size_t)_width * _height;
  unsigned char *rgba = malloc(size * 4);
  jint *argb = malloc(size * sizeof(jint));
  glReadPixels(0, 0, _width, _height, GL_RGBA, GL_UNSIGNED_BYTE, rgba);
  for (int y = 0; y < _height; y++) for (int x = 0; x < _width; x++) {
    unsigned char *p = rgba + (((_height - y - 1) * _width + x) * 4);
    argb[y * _width + x] = 0xff000000 | (p[0] << 16) | (p[1] << 8) | p[2];
  }
  jintArray pixels = (*UIEnv)->NewIntArray(UIEnv, size);
  (*UIEnv)->SetIntArrayRegion(UIEnv, pixels, 0, size, argb);
  NSRect r = [_view convertRect:[_view bounds] toView:nil];
  (*UIEnv)->CallVoidMethod(UIEnv, UIHost, PixelsMethod, pixels, _width, _height,
    (jfloat)r.origin.x, (jfloat)(ScreenHeight - NSMaxY(r)));
  (*UIEnv)->DeleteLocalRef(UIEnv, pixels); free(rgba); free(argb); CheckJava();
}
@end

/* The compatibility shim deliberately supports only immediate-mode quads. */
static GLfloat Vertices[12], Colors[16], Color[4] = {1, 1, 1, 1};
static unsigned VertexCount;
void UIKitGLBegin(GLenum mode) { NSCAssert(mode == 0x0007, @"Only GL_QUADS is supported"); VertexCount = 0; }
void UIKitGLColor3f(GLfloat r, GLfloat g, GLfloat b) { Color[0] = r; Color[1] = g; Color[2] = b; }
void UIKitGLVertex3f(GLfloat x, GLfloat y, GLfloat z)
{
  Vertices[VertexCount * 3] = x; Vertices[VertexCount * 3 + 1] = y; Vertices[VertexCount * 3 + 2] = z;
  memcpy(Colors + VertexCount * 4, Color, sizeof(Color));
  if (++VertexCount == 4) {
    static const GLubyte indices[] = {0, 1, 2, 0, 2, 3};
    glEnableClientState(GL_VERTEX_ARRAY); glEnableClientState(GL_COLOR_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, Vertices); glColorPointer(4, GL_FLOAT, 0, Colors);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, indices);
    glDisableClientState(GL_VERTEX_ARRAY); glDisableClientState(GL_COLOR_ARRAY);
    VertexCount = 0;
  }
}
void UIKitGLEnd(void) { NSCAssert(VertexCount == 0, @"Incomplete quad"); }

@interface UIKitAndroidServer : GSDisplayServer { NSMutableDictionary *_frames; int _next; }
@end
@implementation UIKitAndroidServer
- (id)initWithAttributes:(NSDictionary *)attributes { self = [super initWithAttributes:attributes]; if (self) _frames = [NSMutableDictionary new]; return self; }
- (void)dealloc { [_frames release]; [super dealloc]; }
- (NSArray *)screenList { return @[@0]; }
- (NSRect)boundsForScreen:(int)screen { return NSMakeRect(0, 0, ScreenWidth, ScreenHeight); }
- (NSWindowDepth)windowDepthForScreen:(int)screen { return 24; }
- (const NSWindowDepth *)availableDepthsForScreen:(int)screen { NSWindowDepth *depths = calloc(2, sizeof(NSWindowDepth)); depths[0] = 24; return depths; }
- (void *)serverDevice { return NULL; }
- (void *)windowDevice:(int)win { return (void *)(intptr_t)win; }
- (BOOL)handlesWindowDecorations { return YES; }
- (BOOL)appOwnsMiniwindow { return NO; }
- (void)styleoffsets:(float *)l :(float *)r :(float *)t :(float *)b :(unsigned)style { *l = *r = *t = *b = 0; }
- (int)window:(NSRect)frame :(NSBackingStoreType)type :(unsigned)style :(int)screen
{ int win = ++_next; _frames[@(win)] = [NSValue valueWithRect:frame]; [self _setWindowOwnedByServer:win]; return win; }
- (NSRect)windowbounds:(int)win { return [_frames[@(win)] rectValue]; }
- (void)placewindow:(NSRect)frame :(int)win
{
  _frames[@(win)] = [NSValue valueWithRect:frame];
  NSEvent *event = [NSEvent otherEventWithType:NSAppKitDefined location:frame.origin
    modifierFlags:0 timestamp:[NSDate timeIntervalSinceReferenceDate] windowNumber:win
    context:nil subtype:GSAppKitWindowResized data1:frame.size.width data2:frame.size.height];
  [[NSApp windowWithWindowNumber:win] sendEvent:event];
}
- (void)movewindow:(NSPoint)p :(int)win { NSRect frame = [self windowbounds:win]; frame.origin = p; [self placewindow:frame :win]; }
- (void)termwindow:(int)win { [_frames removeObjectForKey:@(win)]; }
- (NSArray *)windowlist { return [_frames allKeys]; }
- (int)windowdepth:(int)win { return 24; }
- (int)windowlevel:(int)win { return 0; }
- (void)setWindowdevice:(int)win forContext:(NSGraphicsContext *)context { [context GSSetDevice:(void *)(intptr_t)win :0 :ScreenHeight]; }
- (void)orderwindow:(int)op :(int)other :(int)win {}
- (void)setinputfocus:(int)win {}
- (void)setinputstate:(int)state :(int)win {}
- (void)setwindowlevel:(int)level :(int)win {}
- (void)stylewindow:(unsigned)style :(int)win {}
- (void)windowbacking:(NSBackingStoreType)type :(int)win {}
- (void)titlewindow:(NSString *)title :(int)win {}
- (void)setminsize:(NSSize)size :(int)win {}
- (void)setmaxsize:(NSSize)size :(int)win {}
- (void)setresizeincrements:(NSSize)size :(int)win {}
- (void)flushwindowrect:(NSRect)rect :(int)win {}
- (void)setalpha:(float)alpha :(int)win {}
- (void)setShadow:(BOOL)shadow :(int)win {}
- (void)docedited:(int)edited :(int)win {}
- (void)beep {}
- (void)standardcursor:(int)style :(void **)cursor { *cursor = NULL; }
- (void)imagecursor:(NSPoint)point :(NSImage *)image :(void **)cursor { *cursor = NULL; }
- (void)setcursor:(void *)cursor {}
- (void)freecursor:(void *)cursor {}
- (void)hidecursor {}
- (void)showcursor {}
- (NSPoint)mouselocation { return NSZeroPoint; }
- (NSPoint)mouseLocationOnScreen:(int)screen window:(int *)win { if (win) *win = 0; return NSZeroPoint; }
- (BOOL)capturemouse:(int)win { return YES; }
- (void)releasemouse {}
- (void)setIgnoreMouse:(BOOL)ignore :(int)win {}
- (id)glContextClass { return [UIKitAndroidGLContext class]; }
- (id)glPixelFormatClass { return [UIKitAndroidPixelFormat class]; }
@end

@interface GSUIKitAndroidBackend : NSObject @end
@implementation GSUIKitAndroidBackend
+ (void)initializeBackend
{
  [GSDisplayServer setDefaultServerClass:[UIKitAndroidServer class]];
  [NSGraphicsContext setDefaultContextClass:[UIKitAndroidContext class]];
  [GSFontInfo setDefaultClass:[UIKitAndroidFont class]];
  [GSFontEnumerator setDefaultClass:[UIKitAndroidFonts class]];
}
@end

void UIKitAndroidAttach(JNIEnv *env, jobject host, int width, int height)
{
  UIEnv = env;
  if (UIHost) (*env)->DeleteGlobalRef(env, UIHost);
  UIHost = (*env)->NewGlobalRef(env, host);
  ScreenWidth = width; ScreenHeight = height;
  jclass cls = (*env)->GetObjectClass(env, host);
  PathMethod = (*env)->GetMethodID(env, cls, "drawPath", "([FIFZFFFF)V");
  TextMethod = (*env)->GetMethodID(env, cls, "text", "(Ljava/lang/String;FFFZIFFFF)V");
  MeasureMethod = (*env)->GetMethodID(env, cls, "measure", "(Ljava/lang/String;FZ)F");
  PixelsMethod = (*env)->GetMethodID(env, cls, "pixels", "([IIIFF)V");
  (*env)->DeleteLocalRef(env, cls); CheckJava();
  [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"GSUseFreedesktopThumbnails": @NO,
    @"NSMenuInterfaceStyle": @"NSWindows95InterfaceStyle", @"GSSuppressAppIcon": @YES}];
}
void UIKitAndroidResize(int width, int height)
{
  ScreenWidth = width; ScreenHeight = height;
  [NSScreen resetScreens];
  for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
    [GSCurrentServer() placewindow:NSMakeRect(0, 0, width, height) :[[window _nativeWindow] windowNumber]];
    [window layoutIfNeeded];
  }
}
void UIKitAndroidFrame(JNIEnv *env, jobject host)
{
  UIEnv = env;
  if (!Active) return;
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
  for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
    [window layoutIfNeeded];
    if (![window isHidden]) [[window _nativeWindow] display];
  }
}
void UIKitAndroidTouch(int action, float x, float y)
{
  UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
  UIView *hit = [window hitTest:CGPointMake(x, y) withEvent:nil];
  if (action == 0) {
    [TrackingControl release]; TrackingControl = nil;
    if ([hit isKindOfClass:[UIControl class]] && [(UIControl *)hit isEnabled]) {
      TrackingControl = [(UIControl *)hit retain]; [TrackingControl setHighlighted:YES];
    }
  } else if (action == 1 || action == 3) {
    UIControl *control = [TrackingControl autorelease]; TrackingControl = nil;
    [control setHighlighted:NO];
    if (action == 1 && hit == control) [control sendActionsForControlEvents:UIControlEventTouchUpInside];
  } else if (action == 2) [TrackingControl setHighlighted:hit == TrackingControl];
}
void UIKitAndroidActive(BOOL active)
{
  Active = active;
  if (!active) { [TrackingControl setHighlighted:NO]; [TrackingControl release]; TrackingControl = nil; }
  [[NSNotificationCenter defaultCenter] postNotificationName:active ? NSApplicationDidBecomeActiveNotification : NSApplicationWillResignActiveNotification object:NSApp];
}

void UIKitAndroidDetach(JNIEnv *env, jobject host)
{
  if (UIHost && (*env)->IsSameObject(env, UIHost, host)) {
    UIKitAndroidActive(NO);
    (*env)->DeleteGlobalRef(env, UIHost);
    UIHost = NULL;
  }
}
#endif
