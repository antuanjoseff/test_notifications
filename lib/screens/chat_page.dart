import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_notifications/blocs/unread_notifications_cubit.dart';
import 'package:test_notifications/models/api.dart';
import '../config/config.dart';
import '../models/models.dart';
import './chat_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/PushNotifications.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  String? username;
  String? authtoken;
  String? devicetoken;
  Map<String, Usuari> usersMap = {};
  Map<String, dynamic> chatsMap = {};
  List<String> allMessages = [];
  AppLifecycleState? _notification;
  List<Usuari> users = [];
  Usuari? me;
  List<ChatList> chatList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<List<Usuari>> getUsersData() async {
    username = username ?? await getUsernameFromStorage();
    authtoken = authtoken ?? await getAuthtokenFromStorage();

    // if no username/authtoken then go to login page
    if (username == null || authtoken == null) {
      router.pushNamed('login');
    }

    http.Response response = await API(authtoken: authtoken!).getUsers();
    String utf8Response = Utf8Decoder().convert(response.bodyBytes);
    users = usuariFromJson(utf8Response);

    users.forEach((u) {
      usersMap[u.pk.toString()] = u;
      if (u.username == username) {
        me = u;
      }
    });
    return users;
  }

  Future<List<ChatList>> getChatsData() async {
    authtoken = authtoken ?? await getAuthtokenFromStorage();
    http.Response response =
        await API(authtoken: authtoken!).getUserChatsList();
    String utf8Response = Utf8Decoder().convert(response.bodyBytes);
    chatList = chatListFromJson(utf8Response);

    chatList.forEach((chat) {
      chatsMap[chat.theOther.toString()] = chat;
    });

    return chatList;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnreadNotificationsCubit, UnreadNotificationsModel>(
        builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Xat'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(child: Icon(Icons.search)),
            ),
          ],
        ),
        body: FutureBuilder(
          future: Future.wait([getUsersData(), getChatsData()]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator()));
            } else {
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                  itemCount: snapshot.data![0].length,
                  itemBuilder: (context, index) {
                    String userIdx = users[index].pk.toString();
                    debugPrint('userIdx $userIdx');
                    if (!chatsMap.keys.contains(users[index].pk.toString()))
                      return Container();

                    String lastMessage = chatsMap[userIdx].lastMessage;

                    String lastMessageTime =
                        '${chatsMap[userIdx].latestTimestamp.hour.toString().padLeft(2, '0')}:';

                    lastMessageTime +=
                        '${chatsMap[userIdx].latestTimestamp.minute.toString().padLeft(2, '0')}';

                    int unreadNotifs = state.unread[users[index].pk] ?? 0;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetail(
                                user: users[index], me: me?.pk ?? -1),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${users[index].firstFamilyName} ${users[index].secondFamilyName}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '$lastMessage',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(lastMessageTime),
                                        unreadNotifs != 0
                                            ? CircleAvatar(
                                                backgroundColor: Colors.green,
                                                radius: 12,
                                                child: Text('$unreadNotifs',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15)),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Placeholder();
              }
            }
          },
        ),
      );
    });
  }
}
