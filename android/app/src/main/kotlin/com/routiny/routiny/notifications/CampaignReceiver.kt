package com.routiny.routiny.notifications

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

/**
 * Fires a one-off "campaign" notification (e.g. seasonal greetings) with a
 * custom title + body. Scheduled once via [CampaignScheduler]; uses BigTextStyle
 * so the full Arabic message is visible when expanded.
 */
class CampaignReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "روتيني"
        val body = intent.getStringExtra(EXTRA_BODY) ?: ""
        val id = intent.getIntExtra(EXTRA_NOTIFICATION_ID, 7001)
        post(context, id, title, body)
    }

    companion object {
        const val CHANNEL_ID = "routiny_campaigns"
        const val EXTRA_TITLE = "extra_title"
        const val EXTRA_BODY = "extra_body"
        const val EXTRA_NOTIFICATION_ID = "extra_notification_id"

        /// Posts a campaign-style notification immediately (used for foreground
        /// FCM messages via the method channel).
        fun postNow(context: Context, title: String, body: String) {
            post(context, (System.currentTimeMillis() % 100000).toInt(), title, body)
        }

        private fun post(context: Context, id: Int, title: String, body: String) {
            ensureChannel(context)

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
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
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
                            "مناسبات وتذكيرات",
                            NotificationManager.IMPORTANCE_HIGH
                        ).apply { description = "رسائل وتذكيرات خاصة بالمناسبات" }
                    )
                }
            }
        }
    }
}
