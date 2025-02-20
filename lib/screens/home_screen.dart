import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_notifications/models/ChatList.dart';
import 'package:test_notifications/models/User.dart';
import 'package:test_notifications/models/UserCubit.dart';
import 'package:test_notifications/models/Usuari.dart';
import 'package:test_notifications/screens/message_screen.dart';
import 'package:test_notifications/services/PushNotifications.dart';
import '../config/config.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String? token;
  late UserCubit userCubit;
  Map<String, Usuari> usersMap = {};
  List<String> allMessages = [];
  AppLifecycleState? _notification;
  List<Usuari> users = [];
  List<ChatList> chatList = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('--------->>>  $state');
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _notification = state;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    getUsers().then((response) async {
      String utf8Response = Utf8Decoder().convert(response.bodyBytes);

      users = usuariFromJson(utf8Response);

      users.forEach((u) {
        usersMap[u.pk.toString()] = u;
      });

      getChatList().then((response) {
        String utf8Response = Utf8Decoder().convert(response.bodyBytes);

        List<ChatList> chatList = chatListFromJson(utf8Response);
        setState(() {});
      });
    });

    if (kIsWeb) {
      PushNotifications.getFCMToken().then((value) {
        token = value;
        userCubit.setUser(User(username: 'u8839485', token: token));
      });
    } else {
      getTokenFromStorage().then((value) {
        debugPrint('UPDATE CUBIT FROM TOKEN IN STORAGE $value');
        setState(() {
          token = value;
          userCubit.setUser(User(username: 'u8839485', token: token));
        });
        // userCubit.setUser(User(username: 'u8839485', token: value));
      });
    }

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<http.Response> getUsers() {
    return http.get(
        Uri.parse('https://sigserver4.udg.edu/apps/carpool/api/user/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Token bc34e344633b5970aa350aa25a1909ce46a9556b957b47bb1220cf54d3d15019'
        });
  }

  Future<http.Response> getChatList() {
    return http.get(
        Uri.parse('https://sigserver4.udg.edu/apps/carpool/api/chats/mine/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Token bc34e344633b5970aa350aa25a1909ce46a9556b957b47bb1220cf54d3d15019'
        });
  }

  @override
  Widget build(BuildContext context) {
    String? token;
    userCubit = context.watch<UserCubit>();
    Stream<String> messagesStream = PushNotifications.messageStream;
    ScrollController scrollController = ScrollController();

    return BlocBuilder<UserCubit, User>(
        builder: (BuildContext context, User state) {
      return Scaffold(
          appBar: AppBar(
              title: SelectionArea(
                  child: Text(
                      'Home. this is the token: ${userCubit.state.token}'))),
          body: Center(
            child: SizedBox(
              height: 400,
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
                                      username: 'u8839485',
                                      token: '$newToken'));
                                } else {
                                  debugPrint('notifications not authorized');
                                }
                              },
                              child: Text('Accept notifications!'),
                            )
                          ],
                        )
                      : SelectionArea(
                          child: Text('Token : ${userCubit.state.token}')),
                  Text('test notifications home screen'),
                  ElevatedButton(
                    onPressed: () {
                      router.pushNamed('message');
                    },
                    child: Text('Go message!!!'),
                  ),
                  Expanded(
                    child: StreamBuilder(
                        stream: messagesStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          }
                          if (snapshot.hasError) {
                            return const Text('Error');
                          } else {
                            allMessages.add(snapshot.data.toString());
                            setMessagesToStorage('u8839485', allMessages);
                            // return Text('${snapshot.data.toString()}');
                            return ListView.builder(
                                controller: scrollController,
                                itemCount: allMessages.length +
                                    1, //one extra element to do something
                                itemBuilder: (context, index) {
                                  if (index == allMessages.length) {
                                    if (index != 1) {
                                      scrollController.animateTo(
                                          scrollController
                                              .position.maxScrollExtent,
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeOut);
                                    }
                                    return Container(
                                      height: 70,
                                    );
                                  } else {
                                    return ListTile(
                                        title: Text(allMessages[index]));
                                  }
                                });
                          }
                        }),
                  )
                ],
              ),
            ),
          ));
    });
  }
}

class AllMessages extends StatefulWidget {
  List<String> all_messages;
  AllMessages({super.key, required this.all_messages});

  @override
  State<AllMessages> createState() => _AllMessagesState();
}

class _AllMessagesState extends State<AllMessages> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.all_messages.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(widget.all_messages[index]));
        });
  }
}
