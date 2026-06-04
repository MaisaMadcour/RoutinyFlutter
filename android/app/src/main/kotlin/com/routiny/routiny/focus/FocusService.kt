package com.routiny.routiny.focus

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.CountDownTimer
import android.os.IBinder
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.routiny.routiny.MainActivity
import com.routiny.routiny.R

/**
 * Foreground service that shows the persistent focus-timer notification
 * (lock screen + status bar) while a session runs. Ported 1:1 from the
 * Kotlin app's FocusService — but it only drives the notification; the
 * Flutter side keeps owning the DB + result navigation.
 */
class FocusService : Service() {

    private var timer: CountDownTimer? = null
    private var remainingMs: Long = 0
    private var taskTitle: String = "تركيز"
    private var pomodoroNumber: Int = 1

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val minutes = intent.getIntExtra(EXTRA_MINUTES, 25)
                taskTitle = intent.getStringExtra(EXTRA_TASK_TITLE) ?: "تركيز"
                pomodoroNumber = intent.getIntExtra(EXTRA_POMODORO_NUMBER, 1)
                start(minutes)
            }
            ACTION_UPDATE -> {
                // Flutter pushes the authoritative remaining seconds each phase
                val seconds = intent.getIntExtra(EXTRA_SECONDS, 0)
                taskTitle = intent.getStringExtra(EXTRA_TASK_TITLE) ?: taskTitle
                pomodoroNumber = intent.getIntExtra(EXTRA_POMODORO_NUMBER, pomodoroNumber)
                restartCountdown(seconds)
            }
            ACTION_STOP -> stopEverything()
        }
        return START_NOT_STICKY
    }

    private fun start(minutes: Int) {
        ensureChannel()
        remainingMs = minutes * 60 * 1000L
        val started = runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(
                    NOTIFICATION_ID, buildNotification(),
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH
                )
            } else {
                startForeground(NOTIFICATION_ID, buildNotification())
            }
        }.isSuccess
        if (!started) { stopSelf(); return }
        restartCountdown(minutes * 60)
    }

    private fun restartCountdown(seconds: Int) {
        remainingMs = seconds * 1000L
        timer?.cancel()
        timer = object : CountDownTimer(remainingMs, 1000L) {
            override fun onTick(ms: Long) {
                remainingMs = ms
                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.notify(NOTIFICATION_ID, buildNotification())
            }
            override fun onFinish() {
                remainingMs = 0
                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.notify(NOTIFICATION_ID, buildNotification())
            }
        }.start()
    }

    private fun stopEverything() {
        timer?.cancel(); timer = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                val ch = NotificationChannel(
                    CHANNEL_ID, "جلسات التركيز", NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "يعرض الوقت المتبقي لجلسة التركيز الحالية"
                    setShowBadge(false)
                    enableVibration(false)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
                nm.createNotificationChannel(ch)
            }
        }
    }

    private fun buildNotification(): Notification {
        val openIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stopIntent = PendingIntent.getService(
            this, 1,
            Intent(this, FocusService::class.java).apply { action = ACTION_STOP },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val totalSec = (remainingMs / 1000L).toInt().coerceAtLeast(0)
        val m = totalSec / 60
        val s = totalSec % 60

        val small = RemoteViews(packageName, R.layout.notification_focus_running)
        bindDigits(small, m, s)
        small.setOnClickPendingIntent(R.id.btnNotifStop, stopIntent)

        val big = RemoteViews(packageName, R.layout.notification_focus_running_big)
        bindDigits(big, m, s)
        big.setTextViewText(R.id.tvNotifTaskInfo, "🍅 $pomodoroNumber • $taskTitle")
        big.setOnClickPendingIntent(R.id.btnNotifStop, stopIntent)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_focus_lightning)
            .setColor(ContextCompat.getColor(this, R.color.routiny_primary))
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(small)
            .setCustomBigContentView(big)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setContentIntent(openIntent)
            .build()
    }

    private fun bindDigits(rv: RemoteViews, minutes: Int, seconds: Int) {
        rv.setTextViewText(R.id.tvNotifMinTens, (minutes / 10).toString())
        rv.setTextViewText(R.id.tvNotifMinUnits, (minutes % 10).toString())
        rv.setTextViewText(R.id.tvNotifSecTens, (seconds / 10).toString())
        rv.setTextViewText(R.id.tvNotifSecUnits, (seconds % 10).toString())
    }

    override fun onDestroy() {
        timer?.cancel()
        super.onDestroy()
    }

    companion object {
        const val CHANNEL_ID = "routiny_focus_session"
        const val NOTIFICATION_ID = 2001

        const val ACTION_START = "com.routiny.routiny.FOCUS_START"
        const val ACTION_UPDATE = "com.routiny.routiny.FOCUS_UPDATE"
        const val ACTION_STOP = "com.routiny.routiny.FOCUS_STOP"

        const val EXTRA_MINUTES = "extra_minutes"
        const val EXTRA_SECONDS = "extra_seconds"
        const val EXTRA_TASK_TITLE = "extra_task_title"
        const val EXTRA_POMODORO_NUMBER = "extra_pomodoro_number"
    }
}
