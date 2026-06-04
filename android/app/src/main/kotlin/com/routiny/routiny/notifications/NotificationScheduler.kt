package com.routiny.routiny.notifications

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

object NotificationScheduler {

    private const val RC_QUOTE = 82001
    private const val RC_INACTIVITY = 82002

    private const val QUOTE_INTERVAL_MS = 12L * 60L * 60L * 1000L       // 12 hours
    private const val INACTIVITY_INTERVAL_MS = 24L * 60L * 60L * 1000L  // 24 hours

    fun scheduleAll(context: Context) {
        scheduleQuote(context)
        scheduleInactivity(context)
    }

    fun scheduleQuote(context: Context) {
        val now = System.currentTimeMillis()
        val slot = QUOTE_INTERVAL_MS
        val triggerAt = ((now / slot) + 1) * slot
        schedule(context, RC_QUOTE, Intent(context, QuoteNotificationReceiver::class.java), triggerAt)
    }

    fun scheduleInactivity(context: Context) {
        val triggerAt = System.currentTimeMillis() + INACTIVITY_INTERVAL_MS
        schedule(context, RC_INACTIVITY, Intent(context, InactivityNotificationReceiver::class.java), triggerAt)
    }

    private fun schedule(context: Context, requestCode: Int, intent: Intent, triggerAt: Long) {
        val pending = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !am.canScheduleExactAlarms()) {
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pending)
        } else {
            try {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pending)
            } catch (_: SecurityException) {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pending)
            }
        }
    }
}
