#!/usr/bin/env bash
# 一键生成 GLM 额度悬浮窗的完整 Android 工程
# GitHub Actions 里执行：bash gen.sh
set -e

rm -rf app build.gradle settings.gradle gradle.properties
mkdir -p .github/workflows
mkdir -p app/src/main/java/com/yuanbao/zhipuquota
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/drawable

# ---------------- gradle 配置 ----------------
cat > settings.gradle <<'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "ZhipuQuota"
include ':app'
EOF

cat > build.gradle <<'EOF'
plugins {
    id 'com.android.application' version '8.1.4' apply false
}
EOF

cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
EOF

cat > app/build.gradle <<'EOF'
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.yuanbao.zhipuquota'
    compileSdk 34

    defaultConfig {
        applicationId "com.yuanbao.zhipuquota"
        minSdk 23
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    lint {
        abortOnError false
        checkReleaseBuilds false
    }
}
EOF

# ---------------- Manifest ----------------
cat > app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application
        android:allowBackup="true"
        android:icon="@drawable/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/AppTheme">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:screenOrientation="portrait">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".FloatingService"
            android:enabled="true"
            android:exported="false" />

        <receiver
            android:name=".BootReceiver"
            android:enabled="true"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>

    </application>

</manifest>
EOF

# ---------------- 资源 ----------------
cat > app/src/main/res/values/strings.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">GLM 额度悬浮窗</string>
    <string name="tip_payg">说明：智谱按量付费账号没有公开的余额接口。本应用按「账户余额 → 额度窗口 → 速率余量」三级顺序探测，拿到哪个显示哪个，不会编造数字。</string>
</resources>
EOF

cat > app/src/main/res/values/colors.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#FF0288D1</color>
    <color name="bg">#FF101418</color>
    <color name="accent">#FF4FC3F7</color>
</resources>
EOF

cat > app/src/main/res/values/themes.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="AppTheme" parent="android:Theme.Material.Light.NoActionBar">
        <item name="android:windowBackground">@color/bg</item>
        <item name="android:statusBarColor">#FF101418</item>
        <item name="android:windowNoTitle">true</item>
    </style>
</resources>
EOF

cat > app/src/main/res/drawable/bg_input.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#FF1B2329" />
    <stroke android:width="1dp" android:color="#FF2C3A45" />
    <corners android:radius="8dp" />
</shape>
EOF

cat > app/src/main/res/drawable/bg_overlay.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#CC16202A" />
    <stroke android:width="1dp" android:color="#FF31424F" />
    <corners android:radius="12dp" />
</shape>
EOF

cat > app/src/main/res/drawable/bg_dot_ok.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="#FF66BB6A" />
</shape>
EOF

cat > app/src/main/res/drawable/ic_launcher.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="#FF0288D1" />
    <size android:width="48dp" android:height="48dp" />
</shape>
EOF

cat > app/src/main/res/layout/activity_main.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="20dp"
    android:background="#FF101418">

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="@string/app_name"
        android:textColor="#FF4FC3F7"
        android:textSize="22sp"
        android:textStyle="bold"
        android:layout_marginBottom="4dp" />

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="智谱 GLM 额度悬浮窗"
        android:textColor="#FF8A9BA8"
        android:textSize="13sp"
        android:layout_marginBottom="20dp" />

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="API Key"
        android:textColor="#FFB0BEC5"
        android:textSize="13sp"
        android:layout_marginBottom="6dp" />

    <EditText
        android:id="@+id/etKey"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="粘贴智谱 API Key"
        android:textColorHint="#FF546E7A"
        android:textColor="#FFFFFFFF"
        android:textSize="14sp"
        android:inputType="textVisiblePassword"
        android:background="@drawable/bg_input"
        android:padding="12dp"
        android:singleLine="true" />

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="刷新间隔"
        android:textColor="#FFB0BEC5"
        android:textSize="13sp"
        android:layout_marginTop="18dp"
        android:layout_marginBottom="6dp" />

    <Spinner
        android:id="@+id/spinInterval"
        android:layout_width="match_parent"
        android:layout_height="48dp"
        android:background="@drawable/bg_input" />

    <Button
        android:id="@+id/btnSave"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="保存并开启悬浮窗"
        android:layout_marginTop="24dp"
        android:backgroundTint="#FF0288D1"
        android:textColor="#FFFFFFFF" />

    <Button
        android:id="@+id/btnTest"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="测试连接"
        android:layout_marginTop="10dp"
        android:backgroundTint="#FF37474F"
        android:textColor="#FFFFFFFF" />

    <TextView
        android:id="@+id/tvStatus"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text=""
        android:textColor="#FF81C784"
        android:textSize="12sp"
        android:layout_marginTop="16dp"
        android:lineSpacingExtra="3dp" />

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="@string/tip_payg"
        android:textColor="#FF607D8B"
        android:textSize="11sp"
        android:layout_marginTop="18dp"
        android:lineSpacingExtra="4dp" />

</LinearLayout>
EOF

cat > app/src/main/res/layout/overlay_view.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/overlayRoot"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:background="@drawable/bg_overlay"
    android:padding="10dp"
    android:minWidth="130dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center_vertical">

        <View
            android:id="@+id/dot"
            android:layout_width="7dp"
            android:layout_height="7dp"
            android:background="@drawable/bg_dot_ok" />

        <TextView
            android:id="@+id/tvTitle"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="GLM"
            android:textColor="#FFECEFF1"
            android:textSize="11sp"
            android:textStyle="bold"
            android:layout_marginStart="6dp" />

        <TextView
            android:id="@+id/btnHide"
            android:layout_width="20dp"
            android:layout_height="20dp"
            android:text="-"
            android:textColor="#FF90A4AE"
            android:textSize="15sp"
            android:gravity="center" />

    </LinearLayout>

    <TextView
        android:id="@+id/tvMain"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="--"
        android:textColor="#FF4FC3F7"
        android:textSize="19sp"
        android:textStyle="bold"
        android:layout_marginTop="4dp" />

    <TextView
        android:id="@+id/tvSub"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="读取中"
        android:textColor="#FFB0BEC5"
        android:textSize="11sp"
        android:layout_marginTop="2dp" />

    <TextView
        android:id="@+id/tvTime"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text=""
        android:textColor="#FF607D8B"
        android:textSize="9sp"
        android:layout_marginTop="3dp" />

</LinearLayout>
EOF

# ---------------- Java ----------------
P=app/src/main/java/com/yuanbao/zhipuquota

cat > $P/Prefs.java <<'EOF'
package com.yuanbao.zhipuquota;

import android.content.Context;
import android.content.SharedPreferences;

public class Prefs {
    private static final String F = "zq";
    private static final String K_KEY = "api_key";
    private static final String K_INTERVAL = "interval_ms";
    private static final String K_X = "win_x";
    private static final String K_Y = "win_y";

    private final SharedPreferences sp;

    Prefs(Context c) {
        sp = c.getSharedPreferences(F, Context.MODE_PRIVATE);
    }

    String getKey() { return sp.getString(K_KEY, ""); }
    void setKey(String v) { sp.edit().putString(K_KEY, v).apply(); }

    long getInterval() { return sp.getLong(K_INTERVAL, 600000L); }
    void setInterval(long v) { sp.edit().putLong(K_INTERVAL, v).apply(); }

    int getX() { return sp.getInt(K_X, -1); }
    int getY() { return sp.getInt(K_Y, -1); }
    void setPos(int x, int y) { sp.edit().putInt(K_X, x).putInt(K_Y, y).apply(); }
}
EOF

cat > $P/QuotaFetcher.java <<'EOF'
package com.yuanbao.zhipuquota;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;

public class QuotaFetcher {

    public static class Result {
        public String source = "none";
        public String main = "--";
        public String sub = "读取中";
        public boolean ok = false;
        public String err = "";
    }

    private static final String BASE = "https://open.bigmodel.cn";

    interface SimpleHttp {
        int code();
        String body();
        String header(String name);
    }

    private static SimpleHttp get(String url, String key) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setRequestMethod("GET");
        c.setRequestProperty("Authorization", "Bearer " + key);
        c.setRequestProperty("Accept", "application/json");
        c.setConnectTimeout(12000);
        c.setReadTimeout(12000);
        int code = c.getResponseCode();
        String body = read(code >= 400 ? c.getErrorStream() : c.getInputStream());
        return new SimpleHttp() {
            public int code() { return code; }
            public String body() { return body; }
            public String header(String n) { return c.getHeaderField(n); }
        };
    }

    private static SimpleHttp probe(String key) throws Exception {
        HttpURLConnection c = (HttpURLConnection)
                new URL(BASE + "/api/paas/v4/chat/completions").openConnection();
        c.setRequestMethod("POST");
        c.setRequestProperty("Authorization", "Bearer " + key);
        c.setRequestProperty("Content-Type", "application/json");
        c.setConnectTimeout(12000);
        c.setReadTimeout(20000);
        c.setDoOutput(true);
        String payload = "{\"model\":\"glm-4.5-flash\","
                + "\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],"
                + "\"max_tokens\":1,\"stream\":false}";
        try (OutputStream os = c.getOutputStream()) {
            os.write(payload.getBytes(StandardCharsets.UTF_8));
        }
        int code = c.getResponseCode();
        String body = read(code >= 400 ? c.getErrorStream() : c.getInputStream());
        return new SimpleHttp() {
            public int code() { return code; }
            public String body() { return body; }
            public String header(String n) { return c.getHeaderField(n); }
        };
    }

    private static String read(InputStream in) {
        if (in == null) return "";
        StringBuilder sb = new StringBuilder();
        try (BufferedReader r = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
            String l;
            while ((l = r.readLine()) != null) sb.append(l).append('\n');
        } catch (Exception ignored) {}
        return sb.toString();
    }

    public static Result fetch(String key) {
        Result r = new Result();
        if (key == null || key.trim().isEmpty()) {
            r.err = "未填 API Key";
            r.sub = "去 App 里填 Key";
            return r;
        }
        key = key.trim();

        try {
            SimpleHttp h = get(BASE + "/api/paas/v4/user/balance", key);
            if (h.code() == 200) {
                JSONObject j = new JSONObject(h.body());
                Double v = digNumber(j, "balance");
                if (v == null) v = digNumber(j, "available");
                if (v == null) v = digNumber(j, "remaining");
                if (v != null) {
                    r.source = "balance";
                    r.main = "￥" + fmt(v);
                    r.sub = "账户余额";
                    r.ok = true;
                    return r;
                }
            }
        } catch (Exception ignored) {}

        try {
            SimpleHttp h = get(BASE + "/api/monitor/usage/quota/limit", key);
            if (h.code() == 200) {
                JSONObject j = new JSONObject(h.body());
                JSONObject d = j.optJSONObject("data");
                JSONArray arr = d != null ? d.optJSONArray("limits") : null;
                if (arr != null && arr.length() > 0) {
                    JSONObject first = arr.optJSONObject(0);
                    if (first != null) {
                        int pct = first.optInt("percentage", -1);
                        long remain = first.optLong("remaining", -1);
                        long usage = first.optLong("usage", -1);
                        String type = first.optString("type", "");
                        if (pct >= 0 || remain >= 0) {
                            r.source = "quota";
                            r.main = (remain >= 0 ? (num(remain) + " 剩余")
                                    : (pct + "% 已用"));
                            r.sub = typeDesc(type) + (usage > 0 ? " · 总量 " + num(usage) : "");
                            r.ok = true;
                            return r;
                        }
                    }
                }
            }
        } catch (Exception ignored) {}

        try {
            SimpleHttp h = probe(key);
            String tok = h.header("X-RateLimit-Remaining-Tokens");
            String req = h.header("X-RateLimit-Remaining-Requests");
            if (h.code() == 200 && (tok != null || req != null)) {
                r.source = "ratelimit";
                r.main = (tok != null ? num(safeLong(tok)) : "-");
                r.sub = "剩余 Token 额度"
                        + (req != null ? " · 请求 " + num(safeLong(req)) : "");
                r.ok = true;
                return r;
            }
            if (h.code() == 401 || h.code() == 403) {
                r.err = "Key 无效 (" + h.code() + ")";
                r.sub = r.err;
                return r;
            }
            if (h.code() == 402) {
                r.err = "余额不足 (402)";
                r.main = "￥0";
                r.sub = "账户需充值";
                r.ok = true;
                return r;
            }
            r.err = "HTTP " + h.code();
        } catch (Exception e) {
            r.err = "网络失败";
        }

        if (!r.ok && "读取中".equals(r.sub)) r.sub = "无公开接口";
        return r;
    }

    private static String typeDesc(String t) {
        if ("TOKENS_LIMIT".equals(t)) return "Token 窗口";
        if ("TIME_LIMIT".equals(t)) return "时间窗口";
        if ("CREDIT_LIMIT".equals(t)) return "积分";
        return t.isEmpty() ? "额度" : t;
    }

    private static long safeLong(String s) {
        try { return Long.parseLong(s.trim()); } catch (Exception e) { return -1; }
    }

    private static String num(long v) {
        if (v >= 100000000) return (v / 100000000) + "." + ((v / 10000000) % 10) + "亿";
        if (v >= 10000) return String.format("%.1f万", v / 10000.0);
        return String.valueOf(v);
    }

    private static String fmt(double v) {
        if (v >= 1000) return String.format("%.0f", v);
        return String.format("%.2f", v);
    }

    private static Double digNumber(Object node, String target) {
        if (node == null) return null;
        if (node instanceof JSONObject) {
            JSONObject o = (JSONObject) node;
            Iterator<String> it = o.keys();
            while (it.hasNext()) {
                String k = it.next();
                Object v = o.opt(k);
                if (k.equalsIgnoreCase(target) && v instanceof Number) {
                    return ((Number) v).doubleValue();
                }
                if (k.equalsIgnoreCase(target) && v instanceof String) {
                    try { return Double.parseDouble(((String) v).trim()); }
                    catch (Exception ignored) {}
                }
            }
            it = o.keys();
            while (it.hasNext()) {
                Double d = digNumber(o.opt(it.next()), target);
                if (d != null) return d;
            }
        } else if (node instanceof JSONArray) {
            JSONArray a = (JSONArray) node;
            for (int i = 0; i < a.length(); i++) {
                Double d = digNumber(a.opt(i), target);
                if (d != null) return d;
            }
        }
        return null;
    }
}
EOF

cat > $P/FloatingService.java <<'EOF'
package com.yuanbao.zhipuquota;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class FloatingService extends Service {

    private static final String CH = "zq_ch";
    private static final int NOTI_ID = 9001;

    private WindowManager wm;
    private View root;
    private WindowManager.LayoutParams lp;
    private final ExecutorService pool = Executors.newSingleThreadExecutor();
    private final Handler ui = new Handler(Looper.getMainLooper());
    private Prefs prefs;

    private final Runnable tick = new Runnable() {
        @Override public void run() {
            refresh();
            ui.postDelayed(this, prefs.getInterval());
        }
    };

    @Override public void onCreate() {
        super.onCreate();
        prefs = new Prefs(this);
        startForegroundNoti();
        buildWindow();
        refresh();
        ui.postDelayed(tick, prefs.getInterval());
    }

    private void startForegroundNoti() {
        NotificationManager nm = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel c = new NotificationChannel(
                    CH, "额度悬浮窗", NotificationManager.IMPORTANCE_LOW);
            nm.createNotificationChannel(c);
        }
        Notification.Builder b;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            b = new Notification.Builder(this, CH);
        } else {
            b = new Notification.Builder(this);
        }
        b.setContentTitle("GLM 额度悬浮窗运行中")
         .setContentText("下拉可停止")
         .setSmallIcon(android.R.drawable.stat_notify_sync);
        startForeground(NOTI_ID, b.build());
    }

    @SuppressLint("InflateParams")
    private void buildWindow() {
        wm = (WindowManager) getSystemService(WINDOW_SERVICE);
        LayoutInflater inf = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        root = inf.inflate(R.layout.overlay_view, null);

        int type = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                ? WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                : WindowManager.LayoutParams.TYPE_PHONE;

        lp = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                type,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                        | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT);
        lp.gravity = Gravity.TOP | Gravity.START;

        int sx = prefs.getX(), sy = prefs.getY();
        lp.x = sx >= 0 ? sx : 24;
        lp.y = sy >= 0 ? sy : 160;

        attachDrag();

        root.findViewById(R.id.btnHide).setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                root.setVisibility(View.GONE);
                ui.postDelayed(new Runnable() {
                    @Override public void run() {
                        root.setVisibility(View.VISIBLE);
                    }
                }, 60000);
            }
        });

        root.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) { refresh(); }
        });

        try {
            wm.addView(root, lp);
        } catch (Exception ignored) {}
    }

    @SuppressLint("ClickableViewAccessibility")
    private void attachDrag() {
        final float[] start = new float[2];
        final int[] origin = new int[2];
        root.setOnTouchListener(new View.OnTouchListener() {
            @Override public boolean onTouch(View v, MotionEvent e) {
                switch (e.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        start[0] = e.getRawX();
                        start[1] = e.getRawY();
                        origin[0] = lp.x;
                        origin[1] = lp.y;
                        return false;
                    case MotionEvent.ACTION_MOVE:
                        lp.x = origin[0] + (int) (e.getRawX() - start[0]);
                        lp.y = origin[1] + (int) (e.getRawY() - start[1]);
                        try { wm.updateViewLayout(root, lp); } catch (Exception ignored) {}
                        return true;
                    case MotionEvent.ACTION_UP:
                        prefs.setPos(lp.x, lp.y);
                        return Math.abs(e.getRawX() - start[0]) > 8
                                || Math.abs(e.getRawY() - start[1]) > 8;
                }
                return false;
            }
        });
    }

    private void refresh() {
        final String key = prefs.getKey();
        pool.execute(new Runnable() {
            @Override public void run() {
                final QuotaFetcher.Result r = QuotaFetcher.fetch(key);
                ui.post(new Runnable() {
                    @Override public void run() { apply(r); }
                });
            }
        });
    }

    private void apply(QuotaFetcher.Result r) {
        if (root == null) return;
        TextView tvMain = root.findViewById(R.id.tvMain);
        TextView tvSub = root.findViewById(R.id.tvSub);
        TextView tvTime = root.findViewById(R.id.tvTime);
        View dot = root.findViewById(R.id.dot);

        tvMain.setText(r.main);
        tvSub.setText(r.sub);

        int color = r.ok ? 0xFF66BB6A : 0xFFEF5350;
        dot.setBackgroundTintList(ColorStateList.valueOf(color));

        if (r.main.length() > 6) {
            tvMain.setTextSize(TypedValue.COMPLEX_UNIT_SP, 15);
        } else {
            tvMain.setTextSize(TypedValue.COMPLEX_UNIT_SP, 19);
        }

        String t = new SimpleDateFormat("HH:mm:ss", Locale.CHINA).format(new Date());
        tvTime.setText("更新 " + t + ("none".equals(r.source) ? "" : " · " + r.source));
    }

    @Override public int onStartCommand(Intent i, int f, int s) { return START_STICKY; }

    @Override public void onDestroy() {
        ui.removeCallbacks(tick);
        pool.shutdownNow();
        try { if (root != null && wm != null) wm.removeView(root); } catch (Exception ignored) {}
        super.onDestroy();
    }

    @Override public IBinder onBind(Intent i) { return null; }
}
EOF

cat > $P/BootReceiver.java <<'EOF'
package com.yuanbao.zhipuquota;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.provider.Settings;

public class BootReceiver extends BroadcastReceiver {
    @Override public void onReceive(Context c, Intent i) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(i.getAction())) {
            Prefs p = new Prefs(c);
            if (p.getKey().isEmpty()) return;
            if (!Settings.canDrawOverlays(c)) return;
            Intent s = new Intent(c, FloatingService.class);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                c.startForegroundService(s);
            } else {
                c.startService(s);
            }
        }
    }
}
EOF

cat > $P/MainActivity.java <<'EOF'
package com.yuanbao.zhipuquota;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends Activity {

    private EditText etKey;
    private TextView tvStatus;
    private Prefs prefs;
    private final ExecutorService pool = Executors.newSingleThreadExecutor();

    private final long[] intervals = { 60000L, 300000L, 600000L, 1800000L };
    private final String[] labels = { "1 分钟", "5 分钟", "10 分钟", "30 分钟" };
    private int pickIdx = 2;

    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_main);

        prefs = new Prefs(this);
        etKey = findViewById(R.id.etKey);
        tvStatus = findViewById(R.id.tvStatus);
        Button btnSave = findViewById(R.id.btnSave);
        Button btnTest = findViewById(R.id.btnTest);
        Spinner sp = findViewById(R.id.spinInterval);

        etKey.setText(prefs.getKey());

        sp.setAdapter(new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_dropdown_item, labels));
        long cur = prefs.getInterval();
        for (int i = 0; i < intervals.length; i++) {
            if (intervals[i] == cur) pickIdx = i;
        }
        sp.setSelection(pickIdx);
        sp.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            public void onItemSelected(AdapterView<?> p, View v, int pos, long id) { pickIdx = pos; }
            public void onNothingSelected(AdapterView<?> p) {}
        });

        btnSave.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) { saveAndStart(); }
        });
        btnTest.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) { test(); }
        });
    }

    private void saveAndStart() {
        String key = etKey.getText().toString().trim();
        if (key.isEmpty()) {
            Toast.makeText(this, "先填 API Key", Toast.LENGTH_SHORT).show();
            return;
        }
        prefs.setKey(key);
        prefs.setInterval(intervals[pickIdx]);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
                && !Settings.canDrawOverlays(this)) {
            Toast.makeText(this, "请授权「显示在其他应用上层」", Toast.LENGTH_LONG).show();
            Intent it = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:" + getPackageName()));
            startActivity(it);
            return;
        }
        startSvc();
    }

    private void startSvc() {
        Intent s = new Intent(this, FloatingService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(s);
        } else {
            startService(s);
        }
        tvStatus.setText("悬浮窗已开启，可拖动。" + "\n点一下=立即刷新，减号=收起1分钟。");
    }

    private void test() {
        final String key = etKey.getText().toString().trim();
        if (key.isEmpty()) {
            Toast.makeText(this, "先填 API Key", Toast.LENGTH_SHORT).show();
            return;
        }
        tvStatus.setText("测试中…");
        pool.execute(new Runnable() {
            @Override public void run() {
                final QuotaFetcher.Result r = QuotaFetcher.fetch(key);
                runOnUiThread(new Runnable() {
                    @Override public void run() {
                        StringBuilder sb = new StringBuilder();
                        sb.append("结果：").append(r.ok ? "成功" : "未取到").append("\n");
                        sb.append("来源：").append(srcName(r.source)).append("\n");
                        sb.append("主显示：").append(r.main).append("\n");
                        sb.append("副显示：").append(r.sub);
                        if (!r.err.isEmpty()) sb.append("\n备注：").append(r.err);
                        tvStatus.setText(sb.toString());
                    }
                });
            }
        });
    }

    private String srcName(String s) {
        if ("balance".equals(s)) return "账户余额接口";
        if ("quota".equals(s)) return "额度窗口接口";
        if ("ratelimit".equals(s)) return "速率响应头";
        return "无（按量付费无公开余额接口）";
    }
}
EOF

echo "工程文件生成完毕"
