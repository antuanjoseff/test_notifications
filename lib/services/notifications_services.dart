import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationService {
  Future<void> listenNotifications() async {
    FirebaseMessaging.onMessage.listen(_showFlutterNotification);
  }

  void _showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    // Fluttertoast .successToast(notification?.body);
    // Feel free to add UI according to your preference, I am just using a custom Toast.
    Fluttertoast.showToast(
        msg: "${notification?.title ?? 'no title'}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<String> getToken() async {
    return await FirebaseMessaging.instance.getToken() ?? '';
  }
}
