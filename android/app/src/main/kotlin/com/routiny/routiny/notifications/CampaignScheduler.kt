package com.routiny.routiny.notifications

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Schedules a single one-off campaign notification at an exact [triggerAtMillis]
 * (epoch). Idempotent: same [id] + FLAG_UPDATE_CURRENT just updates the alarm.
 * Past times are ignored by the caller so nothing fires late.
 */
object CampaignScheduler {

    fun schedule(context: Context, id: Int, title: String, body: String, triggerAtMillis: Long) {
        if (triggerAtMillis <= System.currentTimeMillis()) return

        val intent = Intent(context, CampaignReceiver::class.java).apply {
            putExtra(CampaignReceiver.EXTRA_TITLE, title)
            putExtra(CampaignReceiver.EXTRA_BODY, body)
            putExtra(CampaignReceiver.EXTRA_NOTIFICATION_ID, id)
        }
        val pending = PendingIntent.getBroadcast(
            context, id, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !am.canScheduleExactAlarms()) {
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pending)
        } else {
            try {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pending)
            } catch (_: SecurityException) {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pending)
            }
        }
    }
}
