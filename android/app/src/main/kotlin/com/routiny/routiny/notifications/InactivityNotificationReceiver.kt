package com.routiny.routiny.notifications

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.routiny.routiny.MainActivity
import com.routiny.routiny.R

class InactivityNotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        NotificationScheduler.scheduleInactivity(context)

        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        if (!prefs.getBoolean("flutter.notif_inactivity_enabled", true)) return
        if (!prefs.getBoolean("flutter.notif_all_enabled", true)) return

        ensureChannel(context)

        val dayIndex = System.currentTimeMillis() / (24L * 60L * 60L * 1000L)
        val message = MESSAGES[(dayIndex % MESSAGES.size).toInt()]

        val contentIntent = PendingIntent.getActivity(
            context, NOTIF_ID,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.launch_background)
            .setContentTitle("وحشتينا 💗")
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setAutoCancel(true)
            .setContentIntent(contentIntent)
            .build()

        (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .notify(NOTIF_ID, notification)
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                nm.createNotificationChannel(
                    NotificationChannel(CHANNEL_ID, "تذكير العودة", NotificationManager.IMPORTANCE_HIGH)
                        .apply { description = "إشعار يظهر لو عدّت ٢٤ ساعة بدون فتح التطبيق" }
                )
            }
        }
    }

    companion object {
        const val CHANNEL_ID = "routiny_inactivity_notif"
        const val NOTIF_ID = 82012

        private val MESSAGES = listOf(
            "وحشتينا النهاردة... دقيقة واحدة منك لنفسك هتفرق جدًا، افتحي التطبيق وكملي رحلتك.",
            "لسه يومك مستني منك خطوة صغيرة، افتحي التطبيق وخدي جرعتك اليومية من الاهتمام بنفسك.",
            "مفتحتيش التطبيق النهاردة، مع إن دقائق بسيطة جواه ممكن تغير مود يومك كله.",
            "جمالك وراحتك محتاجين منك دقائق، افتحي التطبيق وسيبي لنفسك مساحة حلوة النهاردة.",
            "يوم جديد بدأ، متنسيش إن عندك روتين صغير هنا مستنيك يهتم بيكي.",
            "غيابك النهاردة ملحوظ، افتحي التطبيق وارجعي لخطواتك الجميلة واحدة واحدة.",
            "حتى لو يومك زحمة، خدي دقيقة لنفسك وافتحي التطبيق... تستاهلي اللحظة دي.",
            "روتينك مش محتاج وقت كبير، محتاج منك بس فتحة صغيرة النهاردة.",
            "مفيش أحلى من إحساس إنك مهتمة بنفسك، افتحي التطبيق وخلي النهاردة مختلف.",
            "كل يوم بتفتحي فيه التطبيق هو خطوة أقرب للنسخة اللي بتحلمي بيها."
        )
    }
}
