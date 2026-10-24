import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void initializeTimeZones() { tzdata.initializeTimeZones(); }
class Reminder {
  final int id;
  final String title, description, zone, repeat, sound;
  final DateTime at;
  final bool enabled, vibration;
  final int snoozeMinutes;
  const Reminder({required this.id, required this.title, required this.at, required this.zone,
    this.description = '', this.repeat = 'none', this.sound = 'alarm', this.enabled = true,
    this.vibration = true, this.snoozeMinutes = 10});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'description': description,
    'at': at.millisecondsSinceEpoch, 'zone': zone, 'repeat': repeat, 'sound': sound,
    'enabled': enabled, 'vibration': vibration, 'snoozeMinutes': snoozeMinutes};
  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(id: j['id'], title: j['title'],
    at: DateTime.fromMillisecondsSinceEpoch(j['at']), zone: j['zone'], description: j['description'] ?? '',
    repeat: j['repeat'] ?? 'none', sound: j['sound'] ?? 'alarm', enabled: j['enabled'] ?? true,
    vibration: j['vibration'] ?? true, snoozeMinutes: j['snoozeMinutes'] ?? 10);
  Reminder withEnabled(bool value) => Reminder.fromJson({...toJson(), 'enabled': value});
}

/// Fixed IANA-zone wall time: changing the device zone does not change a farm reminder.
DateTime reminderInstant(String zone, DateTime day, int hour, int minute) {
  final value = tz.TZDateTime(tz.getLocation(zone), day.year, day.month, day.day, hour, minute);
  // Reject local times skipped by a spring DST transition instead of silently moving them.
  if (value.hour != hour || value.minute != minute) throw const FormatException('That time does not exist because of daylight saving. Choose another time.');
  return value.toUtc();
}
class ReminderStore {
  static const channel = MethodChannel('com.ecosusrural/reminders');
  static bool get android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  Future<List<Reminder>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = android ? await channel.invokeMethod<String>('load') : prefs.getString('ecosus.reminders');
    return ((jsonDecode(raw ?? '[]')) as List).map((j) => Reminder.fromJson(Map<String, dynamic>.from(j))).toList();
  }
  Future<String> save(List<Reminder> reminders) async {
    final raw = jsonEncode(reminders.map((r) => r.toJson()).toList());
    if (android) return await channel.invokeMethod<String>('save', raw) ?? 'Saved';
    final prefs = await SharedPreferences.getInstance(); await prefs.setString('ecosus.reminders', raw);
    return 'Saved locally. Background notifications are supported on Android only.';
  }
  Future<String> permissions({bool exact = false}) async {
    if (!android) return 'Android notification scheduling is unavailable on this platform.';
    return await channel.invokeMethod<String>(exact ? 'exactPermission' : 'notificationPermission') ?? 'Check system settings';
  }
}
