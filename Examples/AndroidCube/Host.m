#import <UIKit/GNUstepUIKit.h>
#import "UIKitAndroid.h"
#include <stdlib.h>
#include <android/log.h>
extern int gnustep_base_user_main(int, char **);
static BOOL started;
static unsigned SmokeFrame;
static void Report(NSException *exception)
{
  __android_log_print(ANDROID_LOG_FATAL, "UIKit", "%s", [[exception description] UTF8String]);
  abort();
}
JNIEXPORT void JNICALL Java_org_gnustep_uikit_UIKitActivity_boot(JNIEnv *env, jobject host, jstring files, jint w, jint h)
{
  const char *directory = (*env)->GetStringUTFChars(env, files, NULL);
  setenv("HOME", directory, 1);
  (*env)->ReleaseStringUTFChars(env, files, directory);
  if (!started) GSInitializeProcessAndroid(env, host);
  @try {
    @autoreleasepool {
      UIKitAndroidAttach(env, host, w, h);
      SmokeFrame = 0;
      if (!started) {
        char *argv[] = { "UIKitCube", NULL };
        gnustep_base_user_main(1, argv);
        started = YES;
      }
      UIKitAndroidResize(w, h);
    }
  } @catch (NSException *e) { Report(e); }
}
JNIEXPORT void JNICALL Java_org_gnustep_uikit_UIKitActivity_frame(JNIEnv *env, jobject host)
{ @try { @autoreleasepool { UIKitAndroidFrame(env, host); } } @catch (NSException *e) { Report(e); } }
JNIEXPORT void JNICALL Java_org_gnustep_uikit_UIKitActivity_resize(JNIEnv *env, jobject host, jint w, jint h)
{ @try { @autoreleasepool { UIKitAndroidResize(w, h); } } @catch (NSException *e) { Report(e); } }
JNIEXPORT void JNICALL Java_org_gnustep_uikit_UIKitActivity_touch(JNIEnv *env, jobject host, jint action, jfloat x, jfloat y)
{ @try { @autoreleasepool { UIKitAndroidTouch(action, x, y); } } @catch (NSException *e) { Report(e); } }
JNIEXPORT void JNICALL Java_org_gnustep_uikit_UIKitActivity_activate(JNIEnv *env, jobject host, jboolean active)
{ @try { @autoreleasepool { UIKitAndroidActive(active); } } @catch (NSException *e) { Report(e); } }
JNIEXPORT void JNICALL Java_org_gnustep_uikit_UIKitActivity_detach(JNIEnv *env, jobject host)
{ @try { @autoreleasepool { UIKitAndroidDetach(env, host); } } @catch (NSException *e) { Report(e); } }

/* Backend integration fixture, intentionally outside the shared application. */
#import <GLES/gl.h>
@protocol CubeSmokeSelectors
- (BOOL)isPaused;
- (GLfloat)rotationAngle;
- (BOOL)makeCurrentOpenGLContext;
@end
static GLfloat PausedAngle;
static void Tap(UIView *view, UIWindow *window)
{
  CGPoint point = [view convertPoint:CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2) toView:window];
  UIKitAndroidTouch(0, point.x, point.y);
  UIKitAndroidTouch(1, point.x, point.y);
}
JNIEXPORT jboolean JNICALL Java_org_gnustep_uikit_UIKitActivity_smokeStep(JNIEnv *env, jobject host)
{
  @try { @autoreleasepool {
    id delegate = [[UIApplication sharedApplication] delegate];
    id<CubeSmokeSelectors> cube = [delegate valueForKey:@"openGLView"];
    UIWindow *window = [delegate valueForKey:@"window"];
    UIButton *pause = [delegate valueForKey:@"pauseButton"];
    UIView *container = [delegate valueForKey:@"host"];
    SmokeFrame++;
    if (SmokeFrame == 3) {
      NSCAssert([cube rotationAngle] > 0, @"Cube timer did not advance");
      NSCAssert([cube makeCurrentOpenGLContext], @"Cube has no current EGL context");
      GLint viewport[4]; GLubyte pixel[4];
      glGetIntegerv(GL_VIEWPORT, viewport);
      glReadPixels(viewport[2] / 2, viewport[3] / 2, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, pixel);
      NSCAssert(glGetError() == GL_NO_ERROR, @"Cube GL error");
      NSCAssert(pixel[0] > 80 || pixel[1] > 80 || pixel[2] > 80, @"Cube center has no colored pixels");
      NSCAssert(window.subviews.count == 4 && container.subviews.count == 0, @"Native views leaked into UIKit hierarchy");
      Tap(pause, window);
      NSCAssert([cube isPaused], @"Android tap did not invoke UIKit pause action");
      PausedAngle = [cube rotationAngle];
    } else if (SmokeFrame == 6) {
      NSCAssert([cube rotationAngle] == PausedAngle, @"Paused cube advanced");
      CGPoint center = [pause convertPoint:CGPointMake(20, 15) toView:window];
      UIKitAndroidTouch(0, center.x, center.y); UIKitAndroidTouch(3, center.x, center.y);
      NSCAssert([cube isPaused], @"Cancelled touch invoked an action");
      Tap([window viewWithTag:100], window);
      NSCAssert([cube rotationAngle] == 0, @"Reset action failed");
      CGSize size = window.bounds.size;
      UIKitAndroidResize(size.width + 40, size.height + 30);
      NSCAssert(NSEqualSizes(window.bounds.size, NSMakeSize(size.width + 40, size.height + 30)), @"Window resize failed");
      NSCAssert(NSEqualSizes([UIScreen mainScreen].bounds.size, window.bounds.size), @"Screen bounds did not update");
      NSCAssert(NSEqualRects([(NSView *)cube frame], container.bounds), @"Cube failed to follow UIKit layout");
      UIKitAndroidResize(size.width, size.height);
      Tap(pause, window);
      NSCAssert(![cube isPaused], @"Resume action failed");
    } else if (SmokeFrame >= 9) {
      NSCAssert([cube rotationAngle] > 0, @"Resumed cube did not advance");
      __android_log_print(ANDROID_LOG_INFO, "UIKit", "PASS: Android cube pixels, animation, pause, reset, resume, cancellation, hierarchy and resize");
      return JNI_TRUE;
    }
  } } @catch (NSException *e) { Report(e); }
  return JNI_FALSE;
}
