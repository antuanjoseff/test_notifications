import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_notifications/screens/message_screen.dart';
import 'package:test_notifications/services/PushNotifications.dart';
import '../config/config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Home')),
        body: Center(
          child: Column(
            children: [
              kIsWeb
                  ? Column(
                      children: [
                        Text('Platform is web. So...'),
                        ElevatedButton(
                          onPressed: () async {
                            await PushNotifications.initialize();
                          },
                          child: Text('Accept notifications!'),
                        )
                      ],
                    )
                  : Container(),
              Text('test notifications home screen'),
              ElevatedButton(
                onPressed: () {
                  router.pushNamed('message');
                  // navigatiorKey.currentState?.push(
                  //     MaterialPageRoute(builder: (context) => MessageScreen()));
                },
                child: Text('Go message!!!'),
              )
            ],
          ),
        ));
  }
}
