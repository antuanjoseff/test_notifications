import 'dart:convert';

import 'package:test_notifications/config/secure_storage.dart';

import '../models/models.dart';
import '../widgets/received_message.dart';
import '../widgets/send_message.dart';
import '../widgets/send_text_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatDetail extends StatefulWidget {
  ChatDetail({super.key, required this.me, required this.user});
  Usuari user;
  int me;

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  String? authtoken;

  Future getChatDetail() async {
    authtoken = authtoken ?? await getAuthtokenFromStorage();
    debugPrint('AUTHTOKEN $authtoken');

    http.Response response = await http.get(
        Uri.parse(
            'https://sigserver4.udg.edu/apps/carpool/api/chats/detail/7/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${authtoken}'
        });

    String utf8Response = Utf8Decoder().convert(response.bodyBytes);

    return chatDetailFromJson(utf8Response);
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
                    return const Center(
                        child: SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator()));
                  } else {
                    debugPrint('SNAPSHOT DATA : ${snapshot.data}');
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data.results.length,
                              itemBuilder: (context, index) {
                                Result meg = snapshot.data.results[index];

                                if (meg.sender == widget.me) {
                                  return SendMessage(message: meg);
                                } else {
                                  return ReceivedMessage(message: meg);
                                }

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
          Expanded(child: SendTextMessage(user: widget.user)),
        ],
      ),
    );
  }
}
