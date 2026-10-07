# PawTether release ProGuard / R8 rules.
# Consumer rules shipped inside plugin AARs cover the plugins themselves;
# these keeps cover the Flutter embedding entry points that R8 cannot see
# (reflection / JNI / manifest wiring).

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Flutter engine references Play Core (deferred components) without shipping it.
# We don't use deferred components — silence, don't bundle.
-dontwarn com.google.android.play.core.**

# Keep manifest-wired entry points R8 cannot trace.
-keep class * extends android.app.Activity
-keep class * extends android.app.Service
-keep class * extends android.content.BroadcastReceiver
-keep class * extends android.content.ContentProvider
