package com.routiny.routiny.water

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import com.routiny.routiny.MainActivity
import com.routiny.routiny.R
import java.util.Calendar

class WaterReminderReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_REMIND = "com.routiny.routiny.WATER_REMIND"
        const val ACTION_LOG_CUP = "com.routiny.routiny.WATER_LOG_CUP"
        const val CHANNEL_ID = "routiny_water_v2"
        const val CHANNEL_ID_SILENT = "routiny_water_silent_v2"
        const val NOTIFICATION_ID = 81011
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_REMIND -> {
                showReminder(context)
                WaterReminderScheduler.scheduleNext(context)
            }
            ACTION_LOG_CUP -> {
                addCup(context)
                val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.cancel(NOTIFICATION_ID)
                WaterReminderScheduler.scheduleNext(context)
            }
        }
    }

    private fun addCup(context: Context) {
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val today = today()
        val todayKey = "flutter.water_ml_$today"
        val lastKey = "flutter.water_last_$today"
        // Flutter stores ints as Long
        val all = prefs.all
        val cupMl = ((all["flutter.water_cup_size_ml"] as? Long)?.toInt() ?: 250)
        val current = ((all[todayKey] as? Long)?.toInt() ?: 0)
        prefs.edit()
            .putLong(todayKey, (current + cupMl).toLong())
            .putLong(lastKey, cupMl.toLong())
            .apply()
    }

    private fun today(): String {
        val cal = Calendar.getInstance()
        val y = cal.get(Calendar.YEAR)
        val m = (cal.get(Calendar.MONTH) + 1).toString().padStart(2, '0')
        val d = cal.get(Calendar.DAY_OF_MONTH).toString().padStart(2, '0')
        return "$y-$m-$d"
    }

    private fun showReminder(context: Context) {
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val soundEnabled = prefs.getBoolean("flutter.water_notification_sound_enabled", true)
        val cupMl = ((prefs.all["flutter.water_cup_size_ml"] as? Long)?.toInt() ?: 250)

        ensureChannels(context, soundEnabled)
        val channelId = if (soundEnabled) CHANNEL_ID else CHANNEL_ID_SILENT

        val tapIntent = PendingIntent.getActivity(
            context, 81010,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
            },
            pendingFlags()
        )

        val logCupIntent = PendingIntent.getBroadcast(
            context, 81012,
            Intent(context, WaterReminderReceiver::class.java).apply {
                action = ACTION_LOG_CUP
            },
            pendingFlags()
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_water_drop)
            .setContentTitle("وقت تشرب ميّة! 💧")
            .setContentText("اشربي $cupMl مل دلوقتي 🌊")
            .setContentIntent(tapIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .addAction(R.drawable.ic_water_drop, "+ أضفت كاسة", logCupIntent)
            .build()

        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, notification)
    }

    private fun ensureChannels(context: Context, soundEnabled: Boolean) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (nm.getNotificationChannel(CHANNEL_ID) == null) {
            val soundRes = context.resources.getIdentifier("water_drop", "raw", context.packageName)
            val soundUri = if (soundRes != 0)
                Uri.parse("android.resource://${context.packageName}/$soundRes")
            else null
            val ch = NotificationChannel(CHANNEL_ID, "تذكيرات الماء", NotificationManager.IMPORTANCE_HIGH).apply {
                description = "تذكير بشرب الماء"
                if (soundUri != null) {
                    setSound(soundUri, AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                        .build())
                }
            }
            nm.createNotificationChannel(ch)
        }

        if (nm.getNotificationChannel(CHANNEL_ID_SILENT) == null) {
            val ch = NotificationChannel(CHANNEL_ID_SILENT, "تذكيرات الماء (صامت)", NotificationManager.IMPORTANCE_DEFAULT).apply {
                description = "تذكير بشرب الماء بدون صوت"
                setSound(null, null)
            }
            nm.createNotificationChannel(ch)
        }
    }

    private fun pendingFlags() =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        else PendingIntent.FLAG_UPDATE_CURRENT
}
