import 'package:flutter/material.dart';
import '../models/models.dart';

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
                debugPrint('${widget.user.pk}   ${myController.text}');
              },
              child: Icon(Icons.send))
        ],
      ),
    );
  }
}
