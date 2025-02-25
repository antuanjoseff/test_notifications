import '../models/models.dart';
import 'package:flutter/material.dart';

class SendMessage extends StatefulWidget {
  Result message;
  SendMessage({super.key, required this.message});

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  late String message_time;

  @override
  void initState() {
    // TODO: implement initState
    message_time =
        '${widget.message.timestamp.hour}:${widget.message.timestamp.minute}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          color: Color(0xffdcf8c6),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 30,
                  top: 5,
                  bottom: 20,
                ),
                child: Text(widget.message.body),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Text(
                  message_time,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
