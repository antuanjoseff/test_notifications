import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_notifications/blocs/unread_notifications_cubit.dart';
import 'package:test_notifications/config/router.dart';
import 'package:test_notifications/config/secure_storage.dart';
import 'package:test_notifications/main.dart';
import 'package:test_notifications/models/api.dart';
import 'package:test_notifications/utils/lib.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'package:http/http.dart' as http;

class SendTextMessage extends StatefulWidget {
  int receiver;
  int me;
  int chat_id;
  ScrollController scrollController;

  SendTextMessage(
      {super.key,
      required this.receiver,
      required this.me,
      required this.chat_id,
      required this.scrollController});

  @override
  State<SendTextMessage> createState() => _SendTextMessageState();
}

class _SendTextMessageState extends State<SendTextMessage> {
  final myController = TextEditingController();
  final unreadNotificationsCubit =
      navigatiorKey.currentContext!.read<UnreadNotificationsCubit>();

  void _scrollDown() {
    widget.scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              autofocus: true,
              maxLines: 4,
              minLines: 1,
              controller: myController,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                hintText: "type a message",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (myController.text.isEmpty) return;
                DateTime now = DateTime.now();
                sendNotification(myController.text, widget.receiver);
                primaryStream.add(Result(
                    body: myController.text,
                    sender: widget.me,
                    chat: widget.chat_id,
                    receiver: widget.receiver,
                    timestamp: now));
                myController.text = '';

                Map<int, Chat> unread = unreadNotificationsCubit.state.unread;
                unread[widget.chat_id]!.lastMessage = myController.text;
                unread[widget.chat_id]!.timestampLastMessage = now;

                unreadNotificationsCubit
                    .setNotifications(UnreadNotificationsModel(unread: unread));

                FocusScope.of(context).previousFocus();
                _scrollDown();
              },
              child: Icon(Icons.send))
        ],
      ),
    );
  }
}

void sendNotification(message, sender) async {
  String? authtoken = await getAuthtokenFromStorage();

  ApiData apidata =
      await API(authtoken: authtoken!).sendNotification(message, sender);

  if (!(apidata is Success)) {
    showError(apidata);
  }
}
