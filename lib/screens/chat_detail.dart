import 'dart:async';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_notifications/blocs/unread_notifications_cubit.dart';
import 'package:test_notifications/config/router.dart';
import 'package:test_notifications/models/api.dart';
import 'package:test_notifications/utils/lib.dart';
import '../services/services.dart';
import 'package:test_notifications/config/secure_storage.dart';
import '../models/models.dart';
import '../widgets/received_message.dart';
import '../widgets/send_message.dart';
import '../widgets/send_text_message.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' show StreamGroup;

class ChatDetail extends StatefulWidget {
  ChatDetail({super.key, required this.chatId});

  int chatId;

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  late StreamSubscription mainstreaming;
  String? username;
  String? authtoken;
  List<Result> allMessages = [];
  List<Usuari> users = [];
  Usuari? me;
  String chatName = '';
  List<Chat> chatList = [];
  Map<int, Usuari> usersMap = {};
  Map<int, Chat> chatsMap = {};
  int theOtherChatMember = 0;
  bool ready = false;

  final unreadNotificationsCubit =
      navigatiorKey.currentContext!.read<UnreadNotificationsCubit>();

  Future<List<Usuari>> getUsers() async {
    authtoken = authtoken ?? await getAuthtokenFromStorage();
    ApiData apidata = await API(authtoken: authtoken!).getUsers();
    if (apidata is Success) {
      String utf8Response = Utf8Decoder().convert(apidata.data.bodyBytes);
      users = usuariFromJson(utf8Response);

      users.forEach((u) {
        if (u.username == username) {
          me = u;
        }
      });
      return users;
    } else {
      showError(apidata);
      return [];
    }
  }

  Future<ChatDetailModel?> getChatDetail() async {
    authtoken = authtoken ?? await getAuthtokenFromStorage();

    ApiData apidata =
        await API(authtoken: authtoken!).getChatDetail(widget.chatId);

    if (!(apidata is Success)) {
      showError(apidata);
    } else {
      String utf8Response = Utf8Decoder().convert(apidata.data.bodyBytes);
      return chatDetailFromJson(utf8Response);
    }
  }

  late ScrollController scrollController;

  @override
  void initState() {
    getUsernameFromStorage().then((value) {
      username = value;
    });
    getAuthtokenFromStorage().then((value) {
      authtoken = value;
    });
    scrollController = ScrollController();
    mainstreaming = primaryStream.stream.listen((message) {
      allMessages.insert(0, message);
      debugPrint('initstate');
      secondaryStream.add(allMessages);
    });
    mainstreaming.pause();

    getUsers().then((value) {
      users = value;
      getChatDetail().then((value) {
        allMessages = value!.messages;
        secondaryStream.add(allMessages);
        mainstreaming.resume();
        theOtherChatMember = (allMessages[0].receiver != (me?.pk ?? 0))
            ? allMessages[0].receiver
            : allMessages[0].sender;
        Usuari theOtherUser = users.firstWhere((u) {
          return u.pk == theOtherChatMember;
        });

        setState(() {
          chatName =
              '${theOtherUser.name} ${theOtherUser.firstFamilyName} ${theOtherUser.secondFamilyName}';
          ready = true;
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    resetCubit();
    super.dispose();
  }

  void resetCubit() {
    Map<int, Chat> unread = unreadNotificationsCubit.state.unread;
    int key = widget.chatId;
    if (unread.keys.contains(key)) {
      unread[key]!.messagesNotRead = 0;
      unreadNotificationsCubit
          .setNotifications(UnreadNotificationsModel(unread: unread));
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('*');
    return Scaffold(
        appBar: AppBar(title: Text(chatName)),
        body: Column(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height - 140,
                  child: Column(
                    children: [
                      Expanded(
                        child: StreamBuilder(
                            // stream: StreamGroup.merge([fakeStream.stream, mainStream.stream]),
                            stream: StreamGroup.merge([secondaryStream.stream]),
                            builder: (context, snapshot) {
                              if (snapshot.data == null) return Container();
                              List<Result> messages = snapshot.data!;

                              return ListView.builder(
                                  controller: scrollController,
                                  reverse: true,
                                  itemCount: messages.length +
                                      1, //one extra element to do something
                                  itemBuilder: (context, index) {
                                    if (index == (messages.length)) {
                                      return Container(
                                        height: 70,
                                      );
                                    }

                                    // As listview is reversed, previous message is in index + 1 position
                                    int prevIndex =
                                        index == allMessages.length - 1
                                            ? index
                                            : index + 1;
                                    if (allMessages[index].sender == me!.pk) {
                                      return SendMessage(
                                          me: 13,
                                          prevMessage: allMessages[prevIndex],
                                          message: allMessages[index],
                                          scrollController: scrollController);
                                    } else {
                                      return ReceivedMessage(
                                          message: allMessages[index],
                                          prevMessage: allMessages[prevIndex],
                                          scrollController: scrollController);
                                    }
                                  });
                            }),
                      ),
                    ],
                  )),
            ),
            Expanded(
              child: ready
                  ? SendTextMessage(
                      me: me!.pk,
                      chat_id: widget.chatId,
                      receiver: theOtherChatMember,
                      scrollController: scrollController,
                    )
                  : Container(),
            )
          ],
        ));
  }
}
