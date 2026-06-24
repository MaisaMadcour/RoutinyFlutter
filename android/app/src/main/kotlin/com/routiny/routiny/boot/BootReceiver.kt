package com.routiny.routiny.boot

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.routiny.routiny.notifications.CampaignScheduler
import com.routiny.routiny.notifications.NotificationScheduler
import java.util.Calendar

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        NotificationScheduler.scheduleAll(context)
        // Re-arm one-off campaign alarms (lost on reboot). Past times are ignored.
        rescheduleCampaigns(context)
    }

    private fun rescheduleCampaigns(context: Context) {
        // ليلة عاشوراء — 12 منتصف الليل (25 يونيو 2026)
        CampaignScheduler.schedule(
            context, 7101,
            "عاشوراء يوم مغفرة وصفاء قلب 🤍",
            "لا تفوّتي صيامه ودعواتك الحلوة 🌙 سجّلي نيّتك ومهامك في روتيني 🤍",
            millisAt(2026, Calendar.JUNE, 25, 0, 0)
        )
        // ظهر عاشوراء — 12 الظهر (25 يونيو 2026)
        CampaignScheduler.schedule(
            context, 7102,
            "عاشوراء يوم مبارك 🌿",
            "خصصي لحظة لنفسك… تأمّلي، ادعي، واكتبي نيّتك في روتيني 🤍",
            millisAt(2026, Calendar.JUNE, 25, 12, 0)
        )
    }

    private fun millisAt(year: Int, month: Int, day: Int, hour: Int, minute: Int): Long =
        Calendar.getInstance().apply {
            set(year, month, day, hour, minute, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis
}
