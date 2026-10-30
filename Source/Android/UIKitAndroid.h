/* Private Android host interface. All calls run on the Activity UI thread. */
#import <jni.h>
void UIKitAndroidAttach(JNIEnv *env, jobject host, int width, int height);
void UIKitAndroidFrame(JNIEnv *env, jobject host);
void UIKitAndroidResize(int width, int height);
void UIKitAndroidTouch(int action, float x, float y);
void UIKitAndroidActive(BOOL active);
void UIKitAndroidDetach(JNIEnv *env, jobject host);
