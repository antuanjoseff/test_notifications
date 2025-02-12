import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/config.dart';

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static String? token;

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
  );

  // Request notifications permissions
  static Future initialize() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true);

    debugPrint('${settings.authorizationStatus}');
    // String token = await getFCMToken();
    // NotificationSettings settings =
    //     await _firebaseMessaging.requestPermission(provisional: true);

    debugPrint('User granted permission: ${settings.authorizationStatus}');
    debugPrint('token: $token');

    // Get device token
    if (kIsWeb) {
      final token = await _firebaseMessaging.getToken(
          vapidKey:
              'BPGQYfo5HmjnXOHSLXbpAlCXOswPWPWl3Guy34NRg7LzvZXzTsYfKvlLsgrBK3URH_R3JG_66V03LdcnuzSqTFg');
      debugPrint("Device on web token $token");
    } else {
      final token = await _firebaseMessaging.getToken();
      debugPrint("Device on cel token $token");
    }
  }

  static Future getFCMToken({int maxRetires = 3}) async {
    try {
      String? token;
      if (kIsWeb) {
        token = await _firebaseMessaging.getToken(
            vapidKey:
                'BPGQYfo5HmjnXOHSLXbpAlCXOswPWPWl3Guy34NRg7LzvZXzTsYfKvlLsgrBK3URH_R3JG_66V03LdcnuzSqTFg');
        debugPrint("Device on web token $token");
      } else {
        token = await _firebaseMessaging.getToken();
        debugPrint("Device on cel token $token");
      }
      return token;
    } catch (e) {
      debugPrint("failed to get device token");
      if (maxRetires > 0) {
        await Future.delayed(Duration(seconds: 10));
        return getFCMToken(maxRetires: maxRetires - 1);
      } else {
        return null;
      }
    }
  }

  // initialize local notifications
  static Future localNotiInit() async {
    // initialize the plugin app_icon needs to be added as a drawable resource
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permissions for android 13
    // _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation()!.request;

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  // On tap local notification in foreground
  static void onNotificationTap(
      NotificationResponse notificationResponse) async {
    debugPrint('Message: notification tapped');
    router.pushNamed('message');
  }

  // show simple notification
  static Future showSimpleNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: android?.smallIcon,
              // other properties...
            ),
          ));
    }
  }
}
