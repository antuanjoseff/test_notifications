import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:test_notifications/models/ChatList.dart';
import 'package:test_notifications/services/PushNotifications.dart';
import '../config/config.dart';
import '../models/models.dart';
import './chat_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

class ChatPage extends StatefulWidget {
  String username;
  String token;
  ChatPage({super.key, required this.username, required this.token});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  @override
  String? username;
  String? token;
  Map<String, Usuari> usersMap = {};
  Map<String, dynamic> chatsMap = {};
  List<String> allMessages = [];
  AppLifecycleState? _notification;
  List<Usuari> users = [];
  Usuari? me;
  List<ChatList> chatList = [];

  void initState() {
    if (kIsWeb) {
      debugPrint('WEB: ChatList before set user cubit');
      PushNotifications.getFCMToken().then((value) {
        token = value;
        debugPrint('token received: $token');
        // userCubit.setUser(User(username: 'u8839485', token: token));
      });
    } else {
      getTokenFromStorage().then((value) {
        debugPrint('DEVICE: ChatList before set user cubit');
        setState(() {
          token = value;
          // userCubit.setUser(User(username: 'u8839485', token: token));
        });
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
          'Authorization': 'Token ${widget.token}'
        });
  }

  Future<http.Response> getChatList() {
    return http.get(
        Uri.parse('https://sigserver4.udg.edu/apps/carpool/api/chats/mine/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${widget.token}'
        });
  }

  Future<List<Usuari>> getUsersData() async {
    http.Response response = await getUsers();
    String utf8Response = Utf8Decoder().convert(response.bodyBytes);
    users = usuariFromJson(utf8Response);

    users.forEach((u) {
      usersMap[u.pk.toString()] = u;
      if (u.username == widget.username) {
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
      debugPrint(
          'key ${chat.theOther.toString()}    value: ${chat.lastMessage}');
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
            return CircularProgressIndicator();
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                itemCount: snapshot.data![0].length,
                itemBuilder: (context, index) {
                  if (!chatsMap.keys.contains(users[index].pk.toString()))
                    return Container();

                  String userIdx = users[index].pk.toString();

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
                              ChatDetail(user: users[index], token: token!),
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
