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
  ChatDetail(
      {super.key, required this.me, required this.user, required this.chatId});
  Usuari user;
  int me;
  int chatId;

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  String? authtoken;
  List<Result> allMessages = [];

  final unreadNotificationsCubit =
      navigatiorKey.currentContext!.read<UnreadNotificationsCubit>();

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
    scrollController = ScrollController();
    StreamSubscription mainstreaming = primaryStream.stream.listen((message) {
      allMessages.insert(0, message);
      secondaryStream.add(allMessages);
    });
    mainstreaming.pause();

    getChatDetail().then((value) {
      allMessages = value!.messages;
      secondaryStream.add(allMessages);
      // allMessages.forEach((m) {
      //   fakeStream.add(m);
      // });
      mainstreaming.resume();
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
      appBar: AppBar(
          title: Text(
              '${widget.user.name ?? ''} ${widget.user.firstFamilyName ?? ''} ${widget.user.secondFamilyName ?? ''}')),
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
                            // Result message = snapshot.data!;
                            List<Result> messages = snapshot.data!;
                            // allMessages.add(message);

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
                                  if (allMessages[index].sender == widget.me) {
                                    return SendMessage(
                                        me: widget.me,
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
              child: SendTextMessage(
            me: widget.me,
            chat_id: widget.chatId,
            receiver: widget.user.pk,
            scrollController: scrollController,
          )),
        ],
      ),
    );
  }
}
