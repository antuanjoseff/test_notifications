import 'package:flutter/material.dart';
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
  SendTextMessage({super.key, required this.receiver, required this.me});

  @override
  State<SendTextMessage> createState() => _SendTextMessageState();
}

class _SendTextMessageState extends State<SendTextMessage> {
  final myController = TextEditingController();

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

                sendNotification(myController.text, widget.receiver);
                primaryStream.add(Result(
                  body: myController.text,
                  sender: widget.me,
                  receiver: widget.receiver,
                  timestamp: DateTime.now(),
                ));
                myController.text = '';
                FocusScope.of(context).previousFocus();
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
