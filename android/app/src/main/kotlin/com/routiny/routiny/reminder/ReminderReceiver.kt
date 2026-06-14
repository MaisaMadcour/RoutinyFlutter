package com.routiny.routiny.reminder

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.routiny.routiny.MainActivity
import com.routiny.routiny.R

/** Fires at a task's scheduled time and posts a reminder notification. */
class ReminderReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "تذكير مهمة"
        val id = intent.getIntExtra(EXTRA_NOTIFICATION_ID, 1001)

        ensureChannel(context)

        // tapping the notification opens the app (routine tab)
        val contentIntent = PendingIntent.getActivity(
            context, id,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_focus_lightning)
            .setColor(ContextCompat.getColor(context, R.color.routiny_primary))
            .setContentTitle(title)
            .setContentText("حان وقت المهمة ✨")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(contentIntent)
            .build()

        (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .notify(id, notification)
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val m = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (m.getNotificationChannel(CHANNEL_ID) == null) {
                m.createNotificationChannel(
                    NotificationChannel(
                        CHANNEL_ID,
                        "تذكيرات المهام",
                        NotificationManager.IMPORTANCE_HIGH
                    ).apply { description = "تنبيهات المهام اليومية" }
                )
            }
        }
    }

    companion object {
        const val CHANNEL_ID = "routiny_task_reminders"
        const val EXTRA_TITLE = "extra_title"
        const val EXTRA_NOTIFICATION_ID = "extra_notification_id"
    }
}
