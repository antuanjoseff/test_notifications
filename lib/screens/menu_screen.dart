import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_notifications/config/router.dart';
import 'package:test_notifications/config/secure_storage.dart';
import 'package:test_notifications/models/api.dart';
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
  bool dataReady = false;
  @override
  void initState() {
    saveUsername(widget.username).then((_) {
      debugPrint('widget username ${widget.username}');
      saveAuthToken(widget.authtoken).then((_) {
        debugPrint('widget authtoken ${widget.authtoken}');
        dataReady = true;
        setState(() {});
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
          height: 150,
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(50), topLeft: Radius.circular(50)),
            // boxShadow: [
            //   BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
            // ],
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.search, size: 50),
                Icon(Icons.notification_add_rounded, size: 50),
                Icon(Icons.add_a_photo_rounded, size: 50),
                Icon(Icons.assistant_navigation, size: 50),
                Icon(Icons.people, size: 50),
              ],
            )),
          )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            kIsWeb
                ? ElevatedButton(
                    onPressed: !dataReady
                        ? null
                        : () async {
                            AuthorizationStatus status =
                                await PushNotifications.initialize();
                            if (status == AuthorizationStatus.authorized) {
                              String? devicetoken =
                                  await getDeviceTokenFromStorage();
                              //TODO:API Register device
                              if (devicetoken != null) {
                                API(authtoken: widget.authtoken)
                                    .registerDevice(devicetoken!);
                              }
                            }
                          },
                    child: !dataReady
                        ? CircularProgressIndicator()
                        : Text('Allow notifications'))
                : Container(),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  router.go('/chats');
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       settings: RouteSettings(name: '/chats'),
                  //       builder: (context) => ChatPage()),
                  // );
                },
                child: Text('Chats page')),
          ],
        ),
      ),
    );
  }
}
