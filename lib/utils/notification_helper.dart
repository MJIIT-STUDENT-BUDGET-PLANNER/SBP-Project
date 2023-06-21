// ignore_for_file: deprecated_member_use

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NotificationHelper {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationHelper(this.flutterLocalNotificationsPlugin);

 Future<void> scheduleDailyNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDateTime,
}) async {
  tz.initializeTimeZones();
  final String timeZoneName = tz.local.name;
  final location = tz.getLocation(timeZoneName);

  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledDateTime, location),
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
}