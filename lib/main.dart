import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_notifications/config/router.dart';
import 'package:test_notifications/models/User.dart';
import 'package:test_notifications/models/UserCubit.dart';
import 'package:test_notifications/services/PushNotifications.dart';
import './config/secure_storage.dart';

// import 'package:test_notifications/services/push_notifications_service.dart';
import 'firebase_options.dart';

String initRouterPath = '/';

@pragma('vm:entry-point')
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    debugPrint('Some notification received in background....');
  }
}

// to handle notfifications on foreground on web platform
void showNotification({required String title, required String body}) {
  showDialog(
    context: navigatiorKey.currentContext!,
    builder: (context) =>
        AlertDialog(title: Text(title), content: Text(body), actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('OK'),
      )
    ]),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? token = await getTokenFromStorage();

  debugPrint('TOKEN: $token');
  if (token != null) {
    initRouterPath = '/message';
  }
  debugPrint('INITIAL ROUTE $initRouterPath');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    debugPrint('new token $fcmToken');
  }).onError((err) {
    // Error getting token.
  });

  if (!kIsWeb) {
    // initialize firebase messaging
    await PushNotifications.initialize();
  }
  // initialize local notifications
  await PushNotifications.localNotiInit();

  // Listen to background notifications

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

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
    String payloadData = jsonEncode(message.data);
    debugPrint(
        'Got a messsage in foreground. Notification is null = ${message.notification == null}');
    if (message.notification != null) {
      if (kIsWeb) {
        showNotification(
            title: message.notification!.title!,
            body: message.notification!.body!);
      } else {
        PushNotifications.showSimpleNotification(message);
      }
      // router.pushNamed('message');
    }
  });

  // to handle in terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    debugPrint('Message: Launched from terminated state');
    Future.delayed(Duration(seconds: 1), () {
      router.pushNamed('message');
    });
  }

  runApp(BlocProviders());
}

class BlocProviders extends StatefulWidget {
  const BlocProviders({super.key});

  @override
  State<BlocProviders> createState() => _BlocProvidersState();
}

class _BlocProvidersState extends State<BlocProviders> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserCubit(User()),
        )
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  bool requestPermission = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
