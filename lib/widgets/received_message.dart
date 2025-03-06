import '../models/models.dart';
import 'package:flutter/material.dart';

class ReceivedMessage extends StatefulWidget {
  Result message;
  Result prevMessage;
  ScrollController scrollController;
  ReceivedMessage(
      {super.key,
      required this.message,
      required this.prevMessage,
      required this.scrollController});

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
    DateTime prev = widget.prevMessage.timestamp;
    DateTime cur = widget.message.timestamp;
    DateTime today = DateTime.now();
    bool firstMessage = prev.isAtSameMomentAs(cur);
    int curDaysAgo = today.difference(cur).inDays;
    bool samedaysAgo = today.difference(prev).inDays == curDaysAgo;

    debugPrint('days ago $samedaysAgo');
    if (firstMessage || (!samedaysAgo)) {
      return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 45,
              ),
              child: Column(
                children: [
                  Card(
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 8, bottom: 8),
                        child: Text(
                          curDaysAgo == 0 ? 'Avui' : 'Fa $curDaysAgo dies',
                        ),
                      )),
                  ReceivedBodyMessage(
                      widget: widget, message_time: message_time)
                ],
              )));
    }
    return ReceivedBodyMessage(widget: widget, message_time: message_time);
  }
}

class ReceivedBodyMessage extends StatelessWidget {
  const ReceivedBodyMessage({
    super.key,
    required this.widget,
    required this.message_time,
  });

  final ReceivedMessage widget;
  final String message_time;

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
