import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      int? id = int.tryParse(response.id?.toString() ?? '');

      if (id != null) {
        flutterLocalNotificationsPlugin.cancel(id);
      }
    },
  );

  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
}

Future<void> showNotification(String title, String body) async {
  int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    channelShowBadge: true,
  );

  const DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails();

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: iosNotificationDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    title,
    body,
    notificationDetails,
    payload: notificationId.toString(),
  );
}
