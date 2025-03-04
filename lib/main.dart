import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:onmessage/onmessage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_notifications/blocs/unread_notifications_cubit.dart';
import 'package:test_notifications/config/router.dart';
import 'package:test_notifications/models/User.dart';
import 'package:test_notifications/blocs/UserCubit.dart';
import 'package:test_notifications/models/api.dart';
import 'package:test_notifications/models/models.dart';
import 'package:test_notifications/services/PushNotifications.dart';
import 'package:test_notifications/utils/lib.dart';
import './config/secure_storage.dart';

// import 'package:test_notifications/services/push_notifications_service.dart';
import 'firebase_options.dart';

String initRouterPath = '/';

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
  String? token = await getAuthtokenFromStorage();

  if (token != null) {
    initRouterPath = '/message';
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.instance.onTokenRefresh.listen((devicetoken) async {
    debugPrint('REFRESH TOKEN $devicetoken');
    String? oldtoken = await getAuthtokenFromStorage();
    // if oldtoken then unregister it
    await saveDeviceToken(devicetoken);
    String? authtoken = await getAuthtokenFromStorage();
    if (authtoken != null) {
      ApiData apidata =
          await API(authtoken: authtoken).registerDevice(devicetoken!);
      if (!(apidata is Success)) {
        showError(apidata);
      }
    }
  }).onError((err) {
    // Error getting token.
  });

  PushNotifications.init();

  primaryStream.stream.listen((message) {
    final unreadNotificationsCubit =
        navigatiorKey.currentContext!.read<UnreadNotificationsCubit>();

    int key = message.sender;
    Map<int, int> unread = unreadNotificationsCubit.state.unread;

    if (!unread.keys.contains(key)) {
      unread[key] = 1;
    } else {
      int old = unread[key] ?? 0;
      unread[key] = old + 1;
    }

    unreadNotificationsCubit
        .setNotifications(UnreadNotificationsModel(unread: unread));
  });

  web.window.onMessage.listen((web.MessageEvent event) {
    // Handle.

    final unreadNotificationsCubit =
        navigatiorKey.currentContext!.read<UnreadNotificationsCubit>();

    try {
      final data = jsonDecode(event.data.toString());
      if (kIsWeb) {
        Map<String, dynamic> data = jsonDecode(event.data.toString());
        int key = int.parse(data['data']['sender']);
        Map<int, int> unread = unreadNotificationsCubit.state.unread;

        if (!unread.keys.contains(key)) {
          unread[key] = 1;
        } else {
          int old = unread[key] ?? 0;
          unread[key] = old + 1;
        }

        unreadNotificationsCubit
            .setNotifications(UnreadNotificationsModel(unread: unread));
      }
    } catch (e) {
      return;
    }
  });

  //   OnMessage.instance.stream.listen((MessageEvent event) {
  //   try {
  //     final unreadNotificationsCubit =
  //         navigatiorKey.currentContext!.read<UnreadNotificationsCubit>();

  //     try {
  //       final data = jsonDecode(event.data.toString());
  //       if (kIsWeb) {
  //         Map<String, dynamic> data = jsonDecode(event.data.toString());
  //         int key = int.parse(data['data']['sender']);
  //         Map<int, int> unread = unreadNotificationsCubit.state.unread;

  //         debugPrint('2 ${data}');
  //         debugPrint('2 ${key}');
  //         debugPrint('2 ${unread}');

  //         if (!unread.keys.contains(key)) {
  //           unread[key] = 1;
  //         } else {
  //           int old = unread[key] ?? 0;
  //           unread[key] = old + 1;
  //         }

  //         unreadNotificationsCubit
  //             .setNotifications(UnreadNotificationsModel(unread: unread));
  //       }
  //     } catch (e) {
  //       debugPrint('Error parsing json ${event.data.toString()} . Message: $e');
  //       return;
  //     }
  //   } catch (e) {
  //     debugPrint('$e');
  //   }
  // });

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
        ),
        BlocProvider(
          create: (context) =>
              UnreadNotificationsCubit(UnreadNotificationsModel(unread: {})),
        ),
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
