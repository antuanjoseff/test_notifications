import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationsService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;

  static Future _backgroundHandler(RemoteMessage message) async {
    debugPrint('background handler ${message.messageId}');
  }

  static Future _onMessageHandler(RemoteMessage message) async {
    debugPrint('onMessage handler ${message.messageId}');
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    debugPrint('onMessageOpenApp handler ${message.messageId}');
  }

  static Future intializeApp() async {
    //push Notifications
    await Firebase.initializeApp();
    token = await FirebaseMessaging.instance.getToken();
    debugPrint('Device token $token');

    // Handlers
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageHandler);
    //local notifications
  }
}
