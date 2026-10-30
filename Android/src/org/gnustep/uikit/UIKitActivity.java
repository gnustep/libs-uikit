package org.gnustep.uikit;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.*;
import android.view.*;

/** Android owns scheduling and surfaces; application objects live in libs-uikit. */
public class UIKitActivity extends Activity {
    static { System.loadLibrary("UIKitCube"); }
    private HostView host;
    private boolean active;
    private native void boot(String files, int width, int height);
    private native void frame();
    private native void resize(int width, int height);
    private native void touch(int action, float x, float y);
    private native void activate(boolean active);
    private native void detach();
    private native boolean smokeStep();
    private Canvas canvas;
    private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Path path = new Path();

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        new java.io.File(getFilesDir(), "uikit-ready").delete();
        new java.io.File(getFilesDir(), "uikit-smoke").delete();
        host = new HostView();
        setContentView(host);
    }
    @Override public void onResume() {
        super.onResume(); active = true;
        if (host.started) activate(true);
        host.postInvalidateOnAnimation();
    }
    @Override public void onPause() {
        active = false;
        if (host.started) activate(false);
        super.onPause();
    }
    @Override public void onDestroy() {
        if (host.started) detach();
        super.onDestroy();
    }
    private final class HostView extends View {
        boolean started, ready, smokeDone;
        final float density = getResources().getDisplayMetrics().density;
        HostView() { super(UIKitActivity.this); setLayerType(View.LAYER_TYPE_SOFTWARE, null); }
        @Override protected void onSizeChanged(int w, int h, int oldw, int oldh) {
            if (w <= 0 || h <= 0) return;
            int width = Math.round(w / density), height = Math.round(h / density);
            if (!started) { boot(getFilesDir().getAbsolutePath(), width, height); started = true; activate(active); }
            else resize(width, height);
        }
        @Override protected void onDraw(Canvas c) {
            canvas = c;
            c.drawColor(Color.WHITE);
            c.save(); c.scale(density, density);
            if (started && active) {
                frame();
                if (getIntent().getBooleanExtra("smoke", false) && !smokeDone && smokeStep()) {
                    try (java.io.FileOutputStream stream = openFileOutput("uikit-smoke", MODE_PRIVATE)) {
                        stream.write("PASS".getBytes("UTF-8"));
                        smokeDone = true;
                    } catch (java.io.IOException error) { throw new RuntimeException(error); }
                }
                if (!ready) {
                    try (java.io.FileOutputStream stream = openFileOutput("uikit-ready", MODE_PRIVATE)) {
                        stream.write(Integer.toString(android.os.Process.myPid()).getBytes("UTF-8"));
                        ready = true;
                    } catch (java.io.IOException error) { throw new RuntimeException(error); }
                }
            }
            c.restore();
            canvas = null;
            if (active) postInvalidateOnAnimation();
        }
        @Override public boolean onTouchEvent(MotionEvent e) {
            if (started) touch(e.getActionMasked(), e.getX() / density, e.getY() / density);
            return true;
        }
    }
    // Coordinates have already been transformed by GNUstep's graphics state.
    public void drawPath(float[] points, int color, float width, boolean stroke,
                         float left, float top, float right, float bottom) {
        if (canvas == null) return;
        path.reset();
        for (int i = 0; i < points.length;) {
            int op = (int)points[i++];
            if (op == 0) { path.moveTo(points[i++], points[i++]); }
            else if (op == 1) { path.lineTo(points[i++], points[i++]); }
            else if (op == 2) { path.cubicTo(points[i++], points[i++], points[i++], points[i++], points[i++], points[i++]); }
            else path.close();
        }
        paint.setColor(color); paint.setStrokeWidth(width);
        paint.setStyle(stroke ? Paint.Style.STROKE : Paint.Style.FILL);
        canvas.save(); canvas.clipRect(left, top, right, bottom);
        canvas.drawPath(path, paint); canvas.restore();
    }
    public float measure(String text, float size, boolean bold) {
        paint.setTextSize(size); paint.setTypeface(bold ? Typeface.DEFAULT_BOLD : Typeface.DEFAULT);
        return paint.measureText(text);
    }
    public void text(String text, float x, float y, float size, boolean bold, int color,
                     float left, float top, float right, float bottom) {
        if (canvas == null) return;
        paint.setStyle(Paint.Style.FILL); paint.setColor(color);
        paint.setTextSize(size); paint.setTypeface(bold ? Typeface.DEFAULT_BOLD : Typeface.DEFAULT);
        canvas.save(); canvas.clipRect(left, top, right, bottom);
        canvas.drawText(text, x, y, paint); canvas.restore();
    }
    public void pixels(int[] rgba, int width, int height, float x, float y) {
        if (canvas != null) canvas.drawBitmap(rgba, 0, width, x, y, width, height, false, null);
    }
}
