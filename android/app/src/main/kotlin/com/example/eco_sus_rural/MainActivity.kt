package com.example.eco_sus_rural

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ecosusrural.security/drm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.ecosusrural/reminders").setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "load" -> result.success(ReminderScheduler.load(this))
                    "save" -> result.success(ReminderScheduler.save(this, call.arguments as String))
                    "notificationPermission" -> {
                        if (android.os.Build.VERSION.SDK_INT >= 33 && !ReminderScheduler.notifications(this)) {
                            requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 702)
                        }
                        result.success("Check the Android notification permission dialog.")
                    }
                    "exactPermission" -> {
                        if (android.os.Build.VERSION.SDK_INT >= 31 && !ReminderScheduler.exact(this)) {
                            startActivity(android.content.Intent(android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                                android.net.Uri.parse("package:$packageName")))
                        }
                        result.success("Exact access is controlled by Android. Reminders use an inexact fallback if access is unavailable.")
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) { result.error("REMINDER_ERROR", e.message, null) }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "secureScreen" -> {
                    window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
                    result.success("Screen Secured")
                }
                "unsecureScreen" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success("Screen Unsecured")
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        ReminderScheduler.reschedule(this)
    }
}
