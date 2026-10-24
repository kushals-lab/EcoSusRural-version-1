package com.example.eco_sus_rural

import android.Manifest
import android.app.*
import android.content.*
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar
import java.util.TimeZone

/** Local source of truth, also read by the Flutter editor. No server is needed. */
object ReminderScheduler {
    private const val HORIZON = 30L * 86400000
    private const val MAINTENANCE = 2000000001
    private fun prefs(c: Context) = c.getSharedPreferences("ecosus_reminders", Context.MODE_PRIVATE)
    fun load(c: Context): String = prefs(c).getString("records", "[]") ?: "[]"
    private fun records(c: Context): List<JSONObject> {
        val array = JSONArray(load(c))
        return (0 until array.length()).map { array.getJSONObject(it) }
    }
    private fun pending(c: Context, id: Int, action: String = "fire"): PendingIntent = PendingIntent.getBroadcast(
        c, id, Intent(c, ReminderReceiver::class.java).setAction(action).putExtra("id", id),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    private fun manager(c: Context) = c.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    fun exact(c: Context) = Build.VERSION.SDK_INT < 31 || manager(c).canScheduleExactAlarms()
    fun notifications(c: Context) = Build.VERSION.SDK_INT < 33 || c.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    fun save(c: Context, raw: String): String {
        val array = JSONArray(raw)
        require(array.length() <= 1000) { "Maximum 1000 saved reminders" }
        for (i in 0 until array.length()) {
            val r = array.getJSONObject(i)
            require(r.getInt("id") in 0 until MAINTENANCE && r.getString("title").length in 1..120)
            require(TimeZone.getAvailableIDs().contains(r.getString("zone")))
        }
        records(c).forEach { manager(c).cancel(pending(c, it.getInt("id"))) }
        check(prefs(c).edit().putString("records", raw).commit()) { "Unable to persist reminders" }
        reschedule(c)
        return when {
            !notifications(c) -> "Saved, but notifications are denied. Enable them in Android settings."
            exact(c) -> "Saved. Upcoming reminders scheduled with exact alarm access; distant reminders remain stored. Android restrictions can still delay delivery."
            else -> "Saved with inexact scheduling. Android may delay delivery. Exact access is optional in Alarms & reminders settings."
        }
    }
    private fun schedule(c: Context, id: Int, at: Long, action: String = "fire", useExact: Boolean = true) {
        val alarm = manager(c)
        val intent = pending(c, id, action)
        try {
            if (useExact && exact(c)) alarm.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, intent)
            else alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, intent)
        } catch (_: SecurityException) { alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, intent) }
    }
    fun reschedule(c: Context) {
        val now = System.currentTimeMillis()
        val list = records(c)
        // Only the next 40 alarms occupy OS slots; a daily checkpoint refills the horizon.
        val upcoming = list.filter { it.optBoolean("enabled", true) && it.getLong("at") > now }
            .sortedBy { it.getLong("at") }
        upcoming.filter { it.getLong("at") <= now + HORIZON }.take(40).forEach {
            schedule(c, it.getInt("id"), it.getLong("at"))
        }
        if (upcoming.isNotEmpty()) schedule(c, MAINTENANCE, now + 86400000, "maintenance", false)
        else manager(c).cancel(pending(c, MAINTENANCE, "maintenance"))
    }
    private fun persist(c: Context, list: List<JSONObject>) {
        check(prefs(c).edit().putString("records", JSONArray(list).toString()).commit())
    }
    private fun advance(r: JSONObject, now: Long) {
        val repeat = r.optString("repeat", "none")
        if (repeat == "none") { r.put("enabled", false); return }
        val calendar = Calendar.getInstance(TimeZone.getTimeZone(r.getString("zone")))
        calendar.timeInMillis = r.getLong("at")
        do { calendar.add(Calendar.DAY_OF_YEAR, if (repeat == "weekly") 7 else 1) } while (calendar.timeInMillis <= now)
        r.put("at", calendar.timeInMillis)
    }
    fun receive(c: Context, intent: Intent) {
        val list = records(c)
        val now = System.currentTimeMillis()
        val id = intent.getIntExtra("id", -1)
        val r = list.firstOrNull { it.getInt("id") == id }
        if (intent.action == "snooze" && r != null) {
            // Separate snooze record preserves the original recurrence.
            val copy = JSONObject(r.toString()).put("id", (now % 1900000000).toInt()).put("repeat", "none")
                .put("enabled", true).put("at", now + r.optInt("snoozeMinutes", 10) * 60000L)
            persist(c, list + copy)
            (c.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(id)
        } else if (intent.action == "fire" && r != null && r.optBoolean("enabled", true)) {
            // Ignore obsolete pending intents after edits.
            if (r.getLong("at") <= now + 1000) { show(c, r); advance(r, now); persist(c, list) }
        } else {
            // Reboot/time change: catch up recently missed reminders once, skip old occurrences.
            list.filter { it.optBoolean("enabled", true) && it.getLong("at") <= now }.forEach {
                if (now - it.getLong("at") < 3600000) show(c, it)
                advance(it, now)
            }
            persist(c, list)
        }
        reschedule(c)
    }
    private fun show(c: Context, r: JSONObject) {
        if (!notifications(c)) return
        val nm = c.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val sound = r.optString("sound", "alarm")
        val vibration = r.optBoolean("vibration", true)
        val channelId = "reminder_${sound}_${vibration}"
        val uri = when (sound) {
            "silent" -> null
            "notification" -> RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            else -> RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        }
        if (Build.VERSION.SDK_INT >= 26) {
            val channel = NotificationChannel(channelId, "Reminders ($sound)", NotificationManager.IMPORTANCE_HIGH)
            channel.enableVibration(vibration)
            channel.setSound(uri, AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_ALARM).build())
            nm.createNotificationChannel(channel)
        }
        val open = PendingIntent.getActivity(c, r.getInt("id"), Intent(c, MainActivity::class.java), PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(c, channelId) else Notification.Builder(c)
        builder.setSmallIcon(android.R.drawable.ic_lock_idle_alarm).setContentTitle(r.getString("title"))
            .setContentText(r.optString("description")).setStyle(Notification.BigTextStyle().bigText(r.optString("description")))
            .setContentIntent(open).setAutoCancel(true).setCategory(Notification.CATEGORY_REMINDER)
            .addAction(Notification.Action.Builder(null, "Snooze ${r.optInt("snoozeMinutes", 10)} min", pending(c, r.getInt("id"), "snooze")).build())
        if (Build.VERSION.SDK_INT < 26) { builder.setSound(uri); if (vibration) builder.setVibrate(longArrayOf(0, 500, 250, 500)) }
        nm.notify(r.getInt("id"), builder.build())
    }
}
class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) { ReminderScheduler.receive(context, intent) }
}
