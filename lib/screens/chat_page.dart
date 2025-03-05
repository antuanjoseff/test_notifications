import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_notifications/blocs/unread_notifications_cubit.dart';
import 'package:test_notifications/models/api.dart';
import 'package:test_notifications/utils/lib.dart';
import '../config/config.dart';
import '../models/models.dart';
import './chat_detail.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  String? username;
  String? authtoken;
  String? devicetoken;
  Map<int, Usuari> usersMap = {};
  List<String> allMessages = [];
  AppLifecycleState? _notification;
  List<Usuari> users = [];
  Usuari? me;
  List<ChatList> chatList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getData().then((value) {
      value.forEach((v) {
        debugPrint(
            'nom ${v.pk} ${v.name} ${v.firstFamilyName} ${v.secondFamilyName}');
      });
      users = value;
      setState(() {});
    });
  }

  Future<List<Usuari>> getData() async {
    username = username ?? await getUsernameFromStorage();
    authtoken = authtoken ?? await getAuthtokenFromStorage();

    if (username == null || authtoken == null) {
      router.pushNamed('login');
    }

    ApiData apidata = await API(authtoken: authtoken!).getUsers();
    if (apidata is Success) {
      String utf8Response = Utf8Decoder().convert(apidata.data.bodyBytes);
      users = usuariFromJson(utf8Response);

      users.forEach((u) {
        usersMap[u.pk] = u;
        if (u.username == username) {
          me = u;
        }
      });

      apidata = await API(authtoken: authtoken!).getUserChatsList();

      if (apidata is Success) {
        String utf8Response = Utf8Decoder().convert(apidata.data.bodyBytes);
        chatList = chatListFromJson(utf8Response);

        return users;
      } else {
        showError(apidata);
        return [];
      }
    } else {
      showError(apidata);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Xat'),
          actions: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(child: Icon(Icons.search)),
            ),
          ],
        ),
        body: users.isEmpty
            ? const Center(
                child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator()))
            : Container(
                child: BlocBuilder<UnreadNotificationsCubit,
                    UnreadNotificationsModel>(
                  builder: (context, state) {
                    return ListView.builder(
                      itemCount: chatList.length,
                      itemBuilder: (context, index) {
                        int userPk = chatList[index].theOther;

                        if (userPk == me!.pk) {
                          return Container();
                        }

                        String lastMessage = chatList[index].lastMessage;

                        String lastMessageTime =
                            '${chatList[index].timestampLastMessage.hour.toString().padLeft(2, '0')}:';

                        lastMessageTime +=
                            '${chatList[index].timestampLastMessage.minute.toString().padLeft(2, '0')}';

                        int unreadNotifs = state.unread[userPk] ?? 0;

                        return ChatTile(
                            context,
                            chatList[index].chatId,
                            usersMap[userPk]!,
                            lastMessage,
                            lastMessageTime,
                            unreadNotifs);
                      },
                    );
                  },
                ),
              ));
  }

  GestureDetector ChatTile(BuildContext context, int chatId, Usuari user,
      String lastMessage, String lastMessageTime, int unreadNotifs) {
    LineSplitter ls = new LineSplitter();
    List<String> messageLines = ls.convert(lastMessage);
    String message =
        messageLines.length > 1 ? '${messageLines[0]}...' : messageLines[0];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatDetail(chatId: chatId, user: user, me: me?.pk ?? -1),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.name} ${user.firstFamilyName} ${user.secondFamilyName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${message}',
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
                                        color: Colors.white, fontSize: 15)),
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
  }
}
