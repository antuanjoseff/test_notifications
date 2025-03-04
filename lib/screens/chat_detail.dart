import 'dart:async';
import 'dart:convert';
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
  ScrollController scrollController = ScrollController();

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

  @override
  void initState() {
    StreamSubscription mainstreaming = primaryStream.stream.listen((message) {
      allMessages.add(message);
      secondaryStream.add(allMessages);
    });
    mainstreaming.pause();

    getChatDetail().then((value) {
      allMessages = value!.results;
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
    super.dispose();
  }

  void resetCubit() {
    Map<int, int> unread = unreadNotificationsCubit.state.unread;
    int key = widget.user.pk;
    if (unread.keys.contains(key)) {
      unread[key] = 0;
      unreadNotificationsCubit
          .setNotifications(UnreadNotificationsModel(unread: unread));
    }
  }

  @override
  Widget build(BuildContext context) {
    resetCubit();

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
                            resetCubit();
                            if (snapshot.data == null) return Container();
                            // Result message = snapshot.data!;
                            List<Result> messages = snapshot.data!;
                            // allMessages.add(message);

                            return ListView.builder(
                                controller: scrollController,
                                itemCount: messages
                                    .length, //one extra element to do something
                                itemBuilder: (context, index) {
                                  if (allMessages[index].sender == widget.me) {
                                    return SendMessage(
                                        me: widget.me,
                                        message: allMessages[index]);
                                  } else {
                                    return ReceivedMessage(
                                        message: allMessages[index]);
                                  }
                                });
                          }),
                    ),
                  ],
                )),
          ),
          Expanded(
              child: SendTextMessage(me: widget.me, receiver: widget.user.pk)),
        ],
      ),
    );
  }
}
