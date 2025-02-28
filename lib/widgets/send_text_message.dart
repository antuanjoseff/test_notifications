import 'package:flutter/material.dart';
import 'package:test_notifications/config/secure_storage.dart';
import 'package:test_notifications/main.dart';
import 'package:test_notifications/models/api.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'package:http/http.dart' as http;

class SendTextMessage extends StatefulWidget {
  Usuari user;
  SendTextMessage({super.key, required this.user});

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
              maxLines: 4,
              minLines: 1,
              controller: myController,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                hintText: "type a message",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (myController.text.isEmpty) return;

                sendNotification(myController.text, 7);
                mainStream.add(Result(
                  body: myController.text,
                  sender: 13,
                  receiver: 7,
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
  debugPrint('send notification');
  String? authtoken = await getAuthtokenFromStorage();

  ApiData apidata =
      await API(authtoken: authtoken!).sendNotification(message, sender);
  debugPrint('API DATA response code ${apidata.statusCode}');
  if (apidata.statusCode != 200) {
    final snackbar = SnackBar(content: Text('Error:  ${apidata.message}'));
    showSnackBar(snackbar);
  }
}
