import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test_notifications/config/router.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  Map payload = {};

  @override
  Widget build(BuildContext context) {
    // To get data from ...
    final data = ModalRoute.of(context)!.settings.arguments;

    // for background and terminated state
    if (data is RemoteMessage) {
      payload = data.data;
    }

    // for foreground state
    if (data is NotificationResponse) {
      payload = jsonDecode(data.payload!);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Message')),
      body: Center(
        child: Column(
          children: [
            Text(
              payload.toString(),
              style: TextStyle(fontSize: 30),
            ),
            ElevatedButton(
              onPressed: () {
                router.pushNamed('login');
              },
              child: Text('Go home!!!'),
            ),
          ],
        ),
      ),
    );
  }
}
