package com.routiny.routiny.focus

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.os.Build
import android.os.CountDownTimer
import android.os.IBinder
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import com.routiny.routiny.MainActivity
import com.routiny.routiny.R

/**
 * Foreground service that keeps a live timer notification on the status bar
 * and lock screen while a focus / pomodoro session runs.
 *
 * Rebuilt from scratch: uses a plain (non-RemoteViews) notification so it
 * renders reliably everywhere, with a fresh channel that is lock-screen
 * public. Driven from Flutter through a MethodChannel (start/update/stop).
 */
class FocusService : Service() {

    private var timer: CountDownTimer? = null
    private var remainingMs: Long = 0
    private var taskTitle: String = "تركيز"
    private var pomodoroNumber: Int = 1
    private var isPomodoro: Boolean = true
    private var isFinalPhase: Boolean = true
    private var wakeLock: android.os.PowerManager.WakeLock? = null
    private var montserrat: Typeface? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START, ACTION_UPDATE -> {
                val seconds = intent.getIntExtra(EXTRA_SECONDS, 0)
                taskTitle = intent.getStringExtra(EXTRA_TASK_TITLE) ?: taskTitle
                pomodoroNumber =
                    intent.getIntExtra(EXTRA_POMODORO_NUMBER, pomodoroNumber)
                isPomodoro = intent.getBooleanExtra(EXTRA_IS_POMODORO, isPomodoro)
                isFinalPhase = intent.getBooleanExtra(EXTRA_IS_FINAL, isFinalPhase)
                startOrUpdate(seconds, foreground = intent.action == ACTION_START)
            }
            ACTION_COMPLETE -> {
                postCompletion(intent.getBooleanExtra(EXTRA_IS_POMODORO, true))
                stopEverything()
            }
            // Stop initiated by the user from the notification button → also tell
            // Flutter so it ends the in-app session (not just the service).
            ACTION_STOP_FROM_NOTIFICATION -> {
                android.os.Handler(android.os.Looper.getMainLooper()).post {
                    runCatching {
                        MainActivity.focusChannel?.invokeMethod(
                            "stoppedFromNotification", null)
                    }
                }
                stopEverything()
            }
            ACTION_STOP -> stopEverything()
        }
        return START_NOT_STICKY
    }

    private fun startOrUpdate(seconds: Int, foreground: Boolean) {
        ensureChannel()
        acquireWakeLock()
        remainingMs = seconds * 1000L

        if (foreground) {
            val ok = runCatching {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    startForeground(
                        NOTIFICATION_ID, buildNotification(),
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                    )
                } else {
                    startForeground(NOTIFICATION_ID, buildNotification())
                }
            }.isSuccess
            if (!ok) { stopSelf(); return }
        }

        timer?.cancel()
        timer = object : CountDownTimer(remainingMs.coerceAtLeast(0), 1000L) {
            override fun onTick(ms: Long) {
                remainingMs = ms
                notifyManager().notify(NOTIFICATION_ID, buildNotification())
            }
            override fun onFinish() {
                remainingMs = 0
                notifyManager().notify(NOTIFICATION_ID, buildNotification())
                // Fire the "time's up" alert autonomously — works even when the
                // screen is locked and the Flutter engine is suspended.
                if (isFinalPhase) {
                    postCompletion(isPomodoro)
                    stopEverything()
                }
            }
        }.start()
    }

    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == true) return
        runCatching {
            val pm = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
            wakeLock = pm.newWakeLock(
                android.os.PowerManager.PARTIAL_WAKE_LOCK,
                "routiny:focus_timer"
            ).also { it.acquire(4 * 60 * 60 * 1000L) /* 4h safety cap */ }
        }
    }

    private fun releaseWakeLock() {
        runCatching { if (wakeLock?.isHeld == true) wakeLock?.release() }
        wakeLock = null
    }

    private fun stopEverything() {
        timer?.cancel(); timer = null
        releaseWakeLock()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    /**
     * Posts a heads-up "time's up" notification (separate high-importance
     * channel, sound + vibration) when the session finishes. Mirrors the
     * Kotlin app's postCompletionReminder.
     */
    private fun postCompletion(isPomodoro: Boolean) {
        runCatching {
            val nm = notifyManager()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (nm.getNotificationChannel(COMPLETION_CHANNEL_ID) == null) {
                    val ch = NotificationChannel(
                        COMPLETION_CHANNEL_ID,
                        "انتهاء جلسة التركيز",
                        NotificationManager.IMPORTANCE_HIGH
                    ).apply {
                        description = "ينبثق عند انتهاء البومودورو أو المؤقت"
                        enableVibration(true)
                        setShowBadge(true)
                        lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    }
                    nm.createNotificationChannel(ch)
                }
            }
            val openIntent = PendingIntent.getActivity(
                this, 2,
                Intent(this, MainActivity::class.java)
                    .apply { flags = Intent.FLAG_ACTIVITY_SINGLE_TOP },
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            val title = if (isPomodoro) "خلصت جلسة البومودورو 🍅" else "خلص التايم ⏱️"
            val notif = NotificationCompat.Builder(this, COMPLETION_CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_focus_lightning)
                .setColor(ContextCompat.getColor(this, R.color.routiny_primary))
                .setContentTitle(title)
                .setContentText("أحسنت! خد استراحة قصيرة دلوقتي.")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setAutoCancel(true)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setContentIntent(openIntent)
                .build()
            nm.notify(COMPLETION_NOTIFICATION_ID, notif)
        }
    }

    private fun notifyManager() =
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = notifyManager()
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                val ch = NotificationChannel(
                    CHANNEL_ID, "مؤقّت التركيز", NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "يعرض الوقت المتبقي لجلسة التركيز على شاشة القفل"
                    setShowBadge(false)
                    enableVibration(false)
                    setSound(null, null)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
                nm.createNotificationChannel(ch)
            }
        }
    }

    private fun buildNotification(): Notification {
        val totalSec = (remainingMs / 1000L).toInt().coerceAtLeast(0)
        val time = String.format("%02d:%02d", totalSec / 60, totalSec % 60)
        val info = "🍅 $pomodoroNumber • $taskTitle"

        val openIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java)
                .apply { flags = Intent.FLAG_ACTIVITY_SINGLE_TOP },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stopIntent = PendingIntent.getService(
            this, 1,
            Intent(this, FocusService::class.java)
                .apply { action = ACTION_STOP_FROM_NOTIFICATION },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Custom body: big Montserrat coloured digits + a stop pill beside them.
        val timeBitmap = renderTimeBitmap(time)
        fun rv() = RemoteViews(packageName, R.layout.notif_timer).apply {
            setImageViewBitmap(R.id.notifTime, timeBitmap)
            setTextViewText(R.id.notifInfo, info)
            setTextColor(R.id.notifInfo, Color.parseColor("#8E7366"))
            setOnClickPendingIntent(R.id.notifStop, stopIntent)
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_focus_lightning)
            .setColor(ContextCompat.getColor(this, R.color.routiny_primary))
            .setContentTitle("$time ⏳") // fallback for OSes ignoring custom view
            .setContentText(info)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setContentIntent(openIntent)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(rv())
            .setCustomBigContentView(rv())
            .build()
    }

    /**
     * Renders "MM:SS" into a bitmap with the Montserrat-Black typeface and the
     * exact in-app digit colours: minutes/seconds first digit pink, second
     * digit teal, the colon white-ish — so the lock-screen / status-bar numbers
     * match the big clock inside the app.
     */
    private fun renderTimeBitmap(time: String): Bitmap {
        if (montserrat == null) {
            montserrat = runCatching {
                ResourcesCompat.getFont(this, R.font.montserrat_black)
            }.getOrNull() ?: Typeface.DEFAULT_BOLD
        }
        val pink = Color.parseColor("#E8607E")
        val teal = Color.parseColor("#3FA89B")
        val colon = Color.parseColor("#6B5A4F")
        val chars = time.toCharArray()
        // colour per index for "MM:SS": 0=pink 1=teal 2=colon 3=pink 4=teal
        fun colorFor(i: Int, c: Char): Int =
            if (c == ':') colon else if (i <= 1) (if (i == 0) pink else teal)
            else (if (i == 3) pink else teal)

        val density = resources.displayMetrics.density
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            typeface = montserrat
            textSize = 46f * density
            textAlign = Paint.Align.LEFT
        }
        val spacing = 1f * density
        val widths = FloatArray(chars.size) { paint.measureText(chars[it].toString()) }
        val totalW = widths.sum() + spacing * (chars.size - 1).coerceAtLeast(0)
        val fm = paint.fontMetrics
        val totalH = fm.bottom - fm.top
        val bmp = Bitmap.createBitmap(
            Math.ceil(totalW.toDouble()).toInt().coerceAtLeast(1),
            Math.ceil(totalH.toDouble()).toInt().coerceAtLeast(1),
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bmp)
        var x = 0f
        val baseline = -fm.top
        for (i in chars.indices) {
            paint.color = colorFor(i, chars[i])
            canvas.drawText(chars[i].toString(), x, baseline, paint)
            x += widths[i] + spacing
        }
        return bmp
    }

    override fun onDestroy() {
        timer?.cancel()
        releaseWakeLock()
        super.onDestroy()
    }

    companion object {
        const val CHANNEL_ID = "routiny_timer_v3"
        const val NOTIFICATION_ID = 2001
        const val COMPLETION_CHANNEL_ID = "routiny_timer_done_v1"
        const val COMPLETION_NOTIFICATION_ID = 2002

        const val ACTION_START = "com.routiny.routiny.TIMER_START"
        const val ACTION_UPDATE = "com.routiny.routiny.TIMER_UPDATE"
        const val ACTION_STOP = "com.routiny.routiny.TIMER_STOP"
        const val ACTION_STOP_FROM_NOTIFICATION = "com.routiny.routiny.TIMER_STOP_NOTIF"
        const val ACTION_COMPLETE = "com.routiny.routiny.TIMER_COMPLETE"

        const val EXTRA_SECONDS = "extra_seconds"
        const val EXTRA_TASK_TITLE = "extra_task_title"
        const val EXTRA_POMODORO_NUMBER = "extra_pomodoro_number"
        const val EXTRA_IS_POMODORO = "extra_is_pomodoro"
        const val EXTRA_IS_FINAL = "extra_is_final"
    }
}
