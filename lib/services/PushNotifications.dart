import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/config.dart';
import '../config/secure_storage.dart';
import '../config/config.dart';

@pragma('vm:entry-point')
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    debugPrint('add element to stream!');
    PushNotifications.messageController
        .add(message.notification?.body ?? 'no-title');

    List<String> allMessages = await getMessageFromStorage('u8839485');
    debugPrint('all messages $allMessages');
    allMessages.add(message.notification?.title ?? 'no-title');
    await setMessagesToStorage('u8839485', allMessages);
  }
}

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static String? token;

  static StreamController<String> messageController =
      StreamController.broadcast();

  static Stream<String> get messageStream => messageController.stream;

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
  );

  // Request notifications permissions
  static Future<AuthorizationStatus> initialize() async {
    debugPrint('inside initialize notifications');
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

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get device token
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
      // Storage token
      await setTokenToStorage(token);
    }
    return settings.authorizationStatus;
  }

  static Future getFCMToken({int maxRetires = 3}) async {
    try {
      String? token;
      if (kIsWeb) {
        debugPrint('now call getToken with validKey');
        try {
          token = await _firebaseMessaging.getToken(
              vapidKey:
                  'BPGQYfo5HmjnXOHSLXbpAlCXOswPWPWl3Guy34NRg7LzvZXzTsYfKvlLsgrBK3URH_R3JG_66V03LdcnuzSqTFg');
        } catch (e) {
          debugPrint('$e');
        }

        debugPrint("Device on web token $token");
      } else {
        token = await _firebaseMessaging.getToken();
        debugPrint("Device on cel token $token");
      }
      return token;
    } catch (e) {
      debugPrint("failed to get device token: $e");
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

  static void init() async {
    if (!kIsWeb) {
      // initialize firebase messaging
      await PushNotifications.initialize();
    }
    // initialize local notifications
    await PushNotifications.localNotiInit();

    // on background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        debugPrint('Message: Notification tapped');
        router.pushNamed('message');
        // navigatiorKey.currentState!.pushNamed('/message', arguments: message);
      }
    });

    // to handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      messageController.add(message.notification?.title ?? 'no-title');
      debugPrint(
          'Got a messsage in foreground. Notification is null = ${message.notification == null}');
      if (message.notification != null) {
        if (kIsWeb) {
          debugPrint('message from foreground');
          // showNotification(
          //     title: message.notification!.title!,
          //     body: message.notification!.body!);
        } else {
          PushNotifications.showSimpleNotification(message);
        }
        // router.pushNamed('message');
      }
    });

    //background notifications
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

    // to handle in terminated state
    final RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      debugPrint('Message: Launched from terminated state');
      Future.delayed(Duration(seconds: 1), () {
        router.pushNamed('message');
      });
    }
  }

  static closeStreams() {
    messageController.close();
  }
}
