# Flutter wrapper and engine classes
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Required for method channels
-keep class dev.flutter.pigeon.** { *; }

# path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Hive-related classes
-keep class hive.** { *; }
-keep class com.example.** { *; }  # Replace with your own app's package if needed

# Gson (if used for JSON parsing)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }
-dontwarn sun.misc.**

# Keep custom model classes for Hive (especially if using TypeAdapters)
-keep class **.model.** { *; }

# WebView (used by webview_flutter or flutter_webview_plugin)
-keep class android.webkit.** { *; }

# Prevent obfuscation of all Flutter plugin registrants
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep SharedPreferences plugin (if still used anywhere)
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# General keep-all rule for anything under your app's package (adjust if needed)
-keep class com.fodx.fodxpertooh.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
-keep class io.flutter.plugin.platform.PlatformPlugin { *; }
-keep class io.flutter.plugin.common.MethodChannel { *; }
# Keep Flutter Play Core dependencies
-keep class com.google.android.play.core.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Prevent R8 from stripping method channels and plugin registration
-keep class io.flutter.plugin.common.MethodChannel { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }

# Keep Application class if used
-keep class your.package.name.YourApplicationClass { *; }

# Flutter and plugins
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class dev.flutter.pigeon.** { *; }

# Play Core support for deferred components
-keep class com.google.android.play.core.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Required for permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# Required for path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# General Flutter Plugin registration
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.common.MethodChannel { *; }
-keep class io.flutter.plugin.common.MethodCall { *; }
-keep class io.flutter.plugin.common.MethodCallHandler { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }


# Prevent method obfuscation for Play Core tasks
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }

# Optional: keep listener classes used in reflection
-keep class * implements com.google.android.play.core.listener.StateUpdatedListener { *; }



# Prevent warnings from missing annotations, lambdas, etc.
-dontwarn java.lang.invoke.*
-dontwarn kotlin.Metadata
-dontwarn androidx.lifecycle.**
