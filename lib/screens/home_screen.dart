import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_notifications/models/User.dart';
import 'package:test_notifications/models/UserCubit.dart';
import 'package:test_notifications/screens/message_screen.dart';
import 'package:test_notifications/services/PushNotifications.dart';
import '../config/config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? token;
  late UserCubit userCubit;

  @override
  void initState() {
    // Check if token is in storage. If so, update cubit
    getTokenFromStorage().then((value) {
      debugPrint('UPDATE CUBIT FROM TOKEN IN STORAGE $value');
      setState(() {
        token = value;
        userCubit.setUser(User(username: 'u8839485', token: token));
      });
      // userCubit.setUser(User(username: 'u8839485', token: value));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? token;
    userCubit = context.watch<UserCubit>();

    return BlocBuilder<UserCubit, User>(
        builder: (BuildContext context, User state) {
      return Scaffold(
          appBar: AppBar(
              title: Text('Home. this is the token: ${userCubit.state.token}')),
          body: Center(
            child: Column(
              children: [
                state.token == null
                    ? Column(
                        children: [
                          Text('Platform is web. So...'),
                          ElevatedButton(
                            onPressed: () async {
                              AuthorizationStatus authorized =
                                  await PushNotifications.initialize();
                              // Get token from storage and update cubit
                              if (authorized ==
                                  AuthorizationStatus.authorized) {
                                String newToken =
                                    await getTokenFromStorage() ?? '';
                                userCubit.setUser(User(
                                    username: 'u8839485', token: '$newToken'));
                              } else {
                                debugPrint('notifications not authorized');
                              }
                            },
                            child: Text('Accept notifications!'),
                          )
                        ],
                      )
                    : Text('Token : ${userCubit.state.token}'),
                Text('test notifications home screen'),
                ElevatedButton(
                  onPressed: () {
                    router.pushNamed('message');
                  },
                  child: Text('Go message!!!'),
                )
              ],
            ),
          ));
    });
  }
}
