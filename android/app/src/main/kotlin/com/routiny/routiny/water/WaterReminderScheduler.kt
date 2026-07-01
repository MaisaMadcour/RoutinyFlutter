package com.routiny.routiny.water

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.Calendar

object WaterReminderScheduler {

    private const val FLUTTER_PREFS = "FlutterSharedPreferences"
    private const val REQUEST_CODE = 91011

    fun scheduleNext(context: Context) {
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val enabled = prefs.getBoolean("flutter.water_reminder_enabled", true)
        if (!enabled) return

        // Flutter stores ints as Long in SharedPreferences
        val all = prefs.all
        val intervalMin = ((all["flutter.water_reminder_interval_min"] as? Long)?.toInt() ?: 120).coerceIn(30, 240)
        val startHour = ((all["flutter.water_reminder_start_hour"] as? Long)?.toInt() ?: 8).coerceIn(0, 23)
        val endHour = ((all["flutter.water_reminder_end_hour"] as? Long)?.toInt() ?: 22).coerceIn(0, 23)

        var triggerAt = System.currentTimeMillis() + intervalMin * 60_000L
        val cal = Calendar.getInstance().apply { timeInMillis = triggerAt }
        val hour = cal.get(Calendar.HOUR_OF_DAY)

        when {
            hour < startHour -> {
                cal.set(Calendar.HOUR_OF_DAY, startHour)
                cal.set(Calendar.MINUTE, 0)
                cal.set(Calendar.SECOND, 0)
                triggerAt = cal.timeInMillis
            }
            hour >= endHour -> {
                cal.add(Calendar.DAY_OF_YEAR, 1)
                cal.set(Calendar.HOUR_OF_DAY, startHour)
                cal.set(Calendar.MINUTE, 0)
                cal.set(Calendar.SECOND, 0)
                triggerAt = cal.timeInMillis
            }
        }

        val pi = buildPendingIntent(context) ?: return
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pi)
        } else {
            am.setExact(AlarmManager.RTC_WAKEUP, triggerAt, pi)
        }
    }

    fun cancel(context: Context) {
        buildPendingIntent(context)?.let {
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(it)
        }
    }

    private fun buildPendingIntent(context: Context): PendingIntent? {
        val intent = Intent(context, WaterReminderReceiver::class.java).apply {
            action = WaterReminderReceiver.ACTION_REMIND
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        else PendingIntent.FLAG_UPDATE_CURRENT
        return PendingIntent.getBroadcast(context, REQUEST_CODE, intent, flags)
    }
}
