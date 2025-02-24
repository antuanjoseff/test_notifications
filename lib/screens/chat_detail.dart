import 'dart:convert';

import '../models/models.dart';
import '../widgets/received_message.dart';
import '../widgets/send_message.dart';
import '../widgets/send_text_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatDetail extends StatefulWidget {
  ChatDetail({super.key, required this.user, required this.token});
  Usuari user;
  String token;

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  // List<Message> messages = [];

  @override
  void initState() {
    getChatDetail().then((response) {
      String utf8Response = Utf8Decoder().convert(response.bodyBytes);
      debugPrint('CHAT DETAIL $utf8Response');
      setState(() {});
    });
    super.initState();
  }

  Future getChatDetail() async {
    http.Response response = await http.get(
        Uri.parse(
            'https://sigserver4.udg.edu/apps/carpool/api/chats/detail/${widget.user.pk}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${widget.token}'
        });

    String utf8Response = Utf8Decoder().convert(response.bodyBytes);
    debugPrint(utf8Response);
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${widget.user.firstFamilyName ?? ''} ${widget.user.secondFamilyName ?? ''}')),
      body: Column(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 140,
              child: FutureBuilder(
                future: getChatDetail(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: 0,
                              itemBuilder: (context, index) {
                                return Placeholder();
                                // Message m = widget.messages[index];
                                // if (m.me == 7) {
                                //   return SendMessage(message: m);
                                // } else {
                                //   return ReceivedMessage(message: m);
                                // }

                                // return Card(child: ListTile(title: Text(m.message)));
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                    ;
                  }
                },
              ),
            ),
          ),
          Expanded(child: SendTextMessage()),
        ],
      ),
    );
  }
}
