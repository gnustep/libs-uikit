/* Desktop fixed-function subset used by the GNUstep cube, translated to ES 1. */
#ifndef UIKIT_ANDROID_GL_H
#define UIKIT_ANDROID_GL_H
#include <GLES/gl.h>
typedef double GLdouble;
#define GL_QUADS 0x0007
void UIKitGLBegin(GLenum mode);
void UIKitGLColor3f(GLfloat r, GLfloat g, GLfloat b);
void UIKitGLVertex3f(GLfloat x, GLfloat y, GLfloat z);
void UIKitGLEnd(void);
#define glBegin UIKitGLBegin
#define glColor3f UIKitGLColor3f
#define glVertex3f UIKitGLVertex3f
#define glEnd UIKitGLEnd
#define glFrustum glFrustumf
#endif
