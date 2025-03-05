import '../models/models.dart';
import 'package:flutter/material.dart';

class ReceivedMessage extends StatefulWidget {
  Result message;
  ScrollController scrollController;
  ReceivedMessage(
      {super.key, required this.message, required this.scrollController});

  @override
  State<ReceivedMessage> createState() => _ReceivedMessageState();
}

class _ReceivedMessageState extends State<ReceivedMessage> {
  late String message_time;

  @override
  void initState() {
    // TODO: implement initState
    message_time =
        '${widget.message.timestamp.hour.toString().padLeft(2, '0')}:${widget.message.timestamp.minute.toString().padLeft(2, '0')}';
    super.initState();
  }

  void _scrollDown() {
    widget.scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          color: Colors.white,
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
