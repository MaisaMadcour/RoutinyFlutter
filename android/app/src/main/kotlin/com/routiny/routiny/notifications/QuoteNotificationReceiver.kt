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

class QuoteNotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        NotificationScheduler.scheduleQuote(context)

        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        if (!prefs.getBoolean("flutter.notif_tips_enabled", true)) return
        if (!prefs.getBoolean("flutter.notif_all_enabled", true)) return

        ensureChannel(context)

        val dayIndex = System.currentTimeMillis() / (24L * 60L * 60L * 1000L)
        val quote = QUOTES[(dayIndex % QUOTES.size).toInt()]

        val contentIntent = PendingIntent.getActivity(
            context, NOTIF_ID,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_heart)
            .setColor(ContextCompat.getColor(context, R.color.routiny_orange))
            .setContentTitle("لكِ يا جميلة 💗")
            .setContentText(quote)
            .setStyle(NotificationCompat.BigTextStyle().bigText(quote))
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
                    NotificationChannel(CHANNEL_ID, "كوتات يومية", NotificationManager.IMPORTANCE_HIGH)
                        .apply { description = "كوتة عشوائية كل ١٢ ساعة" }
                )
            }
        }
    }

    companion object {
        const val CHANNEL_ID = "routiny_quote_notif"
        const val NOTIF_ID = 82011

        private val QUOTES = listOf(
            "أنتِ كافية تماماً كما أنتِ الآن.",
            "الاهتمام بنفسك ليس أنانية — هو ضرورة.",
            "كلّ يوم هو فرصة لتبدئي من جديد.",
            "قيمتك لا تُقاس بإنجازاتك فقط.",
            "الراحة ليست كسلاً — هي وقود الاستمرار.",
            "أنتِ تستحقين الحب الذي تمنحينه للآخرين.",
            "خطواتك الصغيرة تصنع فارقاً كبيراً.",
            "لا بأس أن تأخذي وقتك في الشفاء.",
            "جمالك يسكن في كل تفصيلة منك.",
            "اختاري نفسك دائماً — أنتِ الأولوية.",
            "دقيقة واحدة من الهدوء تصنع معجزات.",
            "يكفيكِ أن تكوني أنتِ كل يوم.",
            "نفسك تستحق منك نفس الرحمة التي تمنحينها للآخرين.",
            "لا تقارني رحلتك برحلة غيرك.",
            "أنتِ أقوى مما تتخيلين.",
            "حاضرك هو الهدية — عيشيه بإحساس.",
            "الشكر الصغير يفتح أبواباً كبيرة للسعادة.",
            "نبضك يعني أن هناك أملاً جديداً.",
            "اعتني بجسدك — هو بيتك الوحيد.",
            "أنتِ قادرة على تجاوز كل ما يؤلمك."
        )
    }
}
