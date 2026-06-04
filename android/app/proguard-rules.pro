# Flutter / engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Play Core (deferred components) — referenced by Flutter, may be absent
-dontwarn com.google.android.play.core.**

# Keep native notification/boot receivers (referenced from manifest)
-keep class com.routiny.routiny.notifications.** { *; }
-keep class com.routiny.routiny.boot.** { *; }
-keep class com.routiny.routiny.MainActivity { *; }
