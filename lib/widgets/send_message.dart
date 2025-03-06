import '../models/models.dart';
import 'package:flutter/material.dart';

class SendMessage extends StatefulWidget {
  Result message;
  Result prevMessage;
  int me;
  ScrollController scrollController;

  SendMessage(
      {super.key,
      required this.message,
      required this.prevMessage,
      required this.me,
      required this.scrollController});

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  late String message_time;

  @override
  void initState() {
    // TODO: implement initState
    message_time =
        '${widget.message.timestamp.year}-${widget.message.timestamp.month}-${widget.message.timestamp.day} ${widget.message.timestamp.hour}:${widget.message.timestamp.minute}}';
    // message_time =
    //     '${widget.message.timestamp.hour.toString().padLeft(2, '0')}:${widget.message.timestamp.minute.toString().padLeft(2, '0')}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime prev = widget.prevMessage.timestamp;
    DateTime cur = widget.message.timestamp;
    DateTime today = DateTime.now();
    bool firstMessage = prev.isAtSameMomentAs(cur);
    int curDaysAgo = today.difference(cur).inDays;
    bool samedaysAgo = today.difference(prev).inDays == curDaysAgo;

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
                  SentBodyMessage(widget: widget, message_time: message_time)
                ],
              )));
    }
    return SentBodyMessage(widget: widget, message_time: message_time);
  }
}

class SentBodyMessage extends StatelessWidget {
  const SentBodyMessage({
    super.key,
    required this.widget,
    required this.message_time,
  });

  final SendMessage widget;
  final String message_time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: SizedBox(
          width: 200,
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
      ),
    );
  }
}
