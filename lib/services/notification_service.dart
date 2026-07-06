import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  Future<void> scheduleReminder({
    required String noteId,
    required String title,
    required String description,
    required DateTime scheduleDateTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
        'note_reminders', 'note_reminders',
        channelDescription: 'Reminder for your notes',
        importance: Importance.high,
        priority: Priority.high);

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
        id: noteId.hashCode,
        title: title,
        body: description,
        scheduledDate: tz.TZDateTime.from(scheduleDateTime, tz.local),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

   Future<void> cancelReminder(String noteId) async {
    await _plugin.cancel(id: noteId.hashCode);
  }
}
