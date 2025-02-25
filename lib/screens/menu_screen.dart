import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_notifications/config/router.dart';
import 'package:test_notifications/config/secure_storage.dart';
import 'package:test_notifications/screens/chat_page.dart';
import 'package:test_notifications/services/PushNotifications.dart';
import '../models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuPage extends StatefulWidget {
  String username;
  String authtoken;
  MenuPage({super.key, required this.username, required this.authtoken});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    saveUsername(widget.username);
    saveAuthToken(widget.authtoken);
    if (kIsWeb) {
      PushNotifications.getFCMToken().then((devicetoken) {
        saveDeviceToken(devicetoken);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: RouteSettings(name: '/chats'),
                      builder: (context) => ChatPage()),
                );
              },
              child: Text('Chats page'))
        ],
      ),
    );
  }
}
