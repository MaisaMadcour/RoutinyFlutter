package com.routiny.routiny.notifications

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object NotificationLogger {
    private const val PREFS_NAME = "FlutterSharedPreferences"
    private const val KEY = "flutter.notification_history"
    private const val MAX_ENTRIES = 50

    fun log(context: Context, title: String, body: String, type: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val existing = try {
            JSONArray(prefs.getString(KEY, "[]") ?: "[]")
        } catch (_: Exception) {
            JSONArray()
        }
        val entry = JSONObject().apply {
            put("title", title)
            put("body", body)
            put("type", type)
            put("ts", System.currentTimeMillis())
        }
        val updated = JSONArray()
        updated.put(entry)
        for (i in 0 until minOf(existing.length(), MAX_ENTRIES - 1)) {
            updated.put(existing.getJSONObject(i))
        }
        prefs.edit().putString(KEY, updated.toString()).apply()
    }
}
