package com.routiny.routiny

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.routiny.routiny.focus.FocusService
import com.routiny.routiny.notifications.NotificationScheduler

class MainActivity : FlutterActivity() {

    private val channelName = "com.routiny.routiny/focus"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        NotificationScheduler.scheduleAll(this)
        requestNotificationPermission()
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = ContextCompat.checkSelfPermission(
                this, Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
            if (!granted) {
                requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1001)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val i = Intent(this, FocusService::class.java).apply {
                            action = FocusService.ACTION_START
                            putExtra(FocusService.EXTRA_MINUTES, call.argument<Int>("minutes") ?: 25)
                            putExtra(FocusService.EXTRA_TASK_TITLE, call.argument<String>("taskTitle") ?: "تركيز")
                            putExtra(FocusService.EXTRA_POMODORO_NUMBER, call.argument<Int>("pomodoroNumber") ?: 1)
                        }
                        startFg(i)
                        result.success(null)
                    }
                    "update" -> {
                        val i = Intent(this, FocusService::class.java).apply {
                            action = FocusService.ACTION_UPDATE
                            putExtra(FocusService.EXTRA_SECONDS, call.argument<Int>("seconds") ?: 0)
                            putExtra(FocusService.EXTRA_TASK_TITLE, call.argument<String>("taskTitle") ?: "تركيز")
                            putExtra(FocusService.EXTRA_POMODORO_NUMBER, call.argument<Int>("pomodoroNumber") ?: 1)
                        }
                        startFg(i)
                        result.success(null)
                    }
                    "stop" -> {
                        startService(Intent(this, FocusService::class.java).apply {
                            action = FocusService.ACTION_STOP
                        })
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startFg(intent: Intent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
}
