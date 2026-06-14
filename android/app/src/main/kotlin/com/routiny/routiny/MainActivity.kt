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

    companion object {
        // Exposed so FocusService (same process) can call back into Flutter,
        // e.g. when the user taps "stop" on the notification.
        @JvmStatic
        var focusChannel: MethodChannel? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        focusChannel = channel
        channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val minutes = call.argument<Int>("minutes") ?: 25
                        val i = Intent(this, FocusService::class.java).apply {
                            action = FocusService.ACTION_START
                            putExtra(FocusService.EXTRA_SECONDS, minutes * 60)
                            putExtra(FocusService.EXTRA_TASK_TITLE, call.argument<String>("taskTitle") ?: "تركيز")
                            putExtra(FocusService.EXTRA_POMODORO_NUMBER, call.argument<Int>("pomodoroNumber") ?: 1)
                            putExtra(FocusService.EXTRA_IS_POMODORO, call.argument<Boolean>("isPomodoro") ?: true)
                            putExtra(FocusService.EXTRA_IS_FINAL, call.argument<Boolean>("isFinalPhase") ?: true)
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
                            putExtra(FocusService.EXTRA_IS_POMODORO, call.argument<Boolean>("isPomodoro") ?: true)
                            putExtra(FocusService.EXTRA_IS_FINAL, call.argument<Boolean>("isFinalPhase") ?: true)
                        }
                        startFg(i)
                        result.success(null)
                    }
                    "complete" -> {
                        startService(Intent(this, FocusService::class.java).apply {
                            action = FocusService.ACTION_COMPLETE
                            putExtra(FocusService.EXTRA_IS_POMODORO,
                                call.argument<Boolean>("isPomodoro") ?: true)
                        })
                        result.success(null)
                    }
                    "stop" -> {
                        startService(Intent(this, FocusService::class.java).apply {
                            action = FocusService.ACTION_STOP
                        })
                        result.success(null)
                    }
                    "scheduleTaskReminder" -> {
                        com.routiny.routiny.reminder.ReminderScheduler.schedule(
                            this,
                            call.argument<Int>("id") ?: 0,
                            call.argument<String>("title") ?: "تذكير مهمة",
                            call.argument<Int>("hour") ?: 8,
                            call.argument<Int>("minute") ?: 0
                        )
                        result.success(null)
                    }
                    "cancelTaskReminder" -> {
                        com.routiny.routiny.reminder.ReminderScheduler.cancel(
                            this, call.argument<Int>("id") ?: 0)
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
