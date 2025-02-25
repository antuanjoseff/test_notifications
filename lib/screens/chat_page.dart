import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:test_notifications/services/PushNotifications.dart';
import '../config/config.dart';
import '../models/models.dart';
import './chat_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future<http.Response> getUsers() async {
    username = username ?? await getUsernameFromStorage();
    authtoken = authtoken ?? await getAuthtokenFromStorage();

    return http.get(
        Uri.parse('https://sigserver4.udg.edu/apps/carpool/api/user/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $authtoken'
        });
  }

  Future<http.Response> getChatList() async {
    username = username ?? await getUsernameFromStorage();
    authtoken = authtoken ?? await getAuthtokenFromStorage();
    debugPrint('AUTHTOKEN $authtoken');

    return http.get(
        Uri.parse('https://sigserver4.udg.edu/apps/carpool/api/chats/mine/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${authtoken}'
        });
  }

  Future<List<Usuari>> getUsersData() async {
    username = username ?? await getUsernameFromStorage();
    authtoken = authtoken ?? await getAuthtokenFromStorage();
    debugPrint('AUTHTOKEN $authtoken');
    // TODO
    // if no username/authtoken then go to login page
    if (username == null || authtoken == null) {
      router.pushNamed('login');
    }

    http.Response response = await getUsers();
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
    http.Response response = await getChatList();
    String utf8Response = Utf8Decoder().convert(response.bodyBytes);
    chatList = chatListFromJson(utf8Response);

    chatList.forEach((chat) {
      chatsMap[chat.theOther.toString()] = chat;
    });

    return chatList;
  }

  @override
  Widget build(BuildContext context) {
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
                itemCount: snapshot.data?[0].length ?? 0,
                itemBuilder: (context, index) {
                  String userIdx = users[index].pk.toString();

                  if (!chatsMap.keys.contains(users[index].pk.toString()))
                    return Container();

                  String lastMessage = chatsMap[userIdx].lastMessage;

                  String lastMessageTime =
                      '${chatsMap[userIdx].latestTimestamp.hour.toString().padLeft(2, '0')}:';

                  lastMessageTime +=
                      '${chatsMap[userIdx].latestTimestamp.minute.toString().padLeft(2, '0')}';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatDetail(user: users[index], me: me?.pk ?? -1),
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
                                  Text(lastMessageTime),
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
  }
}
