import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

import 'main.dart' as App;

class PushNotification {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static String? _token;

  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    _token = await _firebaseMessaging.getToken();

    print("device token : $_token");
  }
  static Future localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    // final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(onDidReceiveLocalNotification: (id, title, body, payload) => null);
    final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onNotificationTap,
    onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  static void onNotificationTap(NotificationResponse notificationResponse) {
    App.navigatorKey.currentState!
        .pushNamed('/message', arguments:notificationResponse);
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
}) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails('pomo_timer_alarm_1', 'pomo_timer_alarm',
    channelDescription: '',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker');
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
    .show(0, title, body, notificationDetails, payload: payload);
  }

  static Future<void> send({required String title, required String message}) async {
    final jsonCredentials = await rootBundle.loadString('assets/data/auth.json');
    final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);
    final client = await auth.clientViaServiceAccount(
      creds,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );

    final notificationData = {
      'message': {
        'token': _token,
        'data': {
          'via': 'FlutterFire cloud Messaging!!',
        },
        'notification': {
          'title': title,
          'body': message,
        }
      },
    };
    final response = await client.post(
      Uri.parse(
        'https://fcm.googleapis.com/v1/projects/${798822824658}/messages:send'
      ),
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode(notificationData),
    );

    client.close();
    if(response.statusCode == 200) {
      debugPrint('FCM notification sent with status code: ${response.statusCode}');
    } else {
      debugPrint(
        '${response.statusCode}, ${response.reasonPhrase}, ${response.body}'
      );
    }
  }
}