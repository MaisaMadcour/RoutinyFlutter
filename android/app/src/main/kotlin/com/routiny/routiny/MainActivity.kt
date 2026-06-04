package com.routiny.routiny

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import com.routiny.routiny.notifications.NotificationScheduler

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        NotificationScheduler.scheduleAll(this)
    }
}
