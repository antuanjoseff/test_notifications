import 'dart:async';
import 'dart:convert';
import 'package:test_notifications/models/api.dart';

import '../services/services.dart';
import 'package:test_notifications/config/secure_storage.dart';

import '../models/models.dart';
import '../widgets/received_message.dart';
import '../widgets/send_message.dart';
import '../widgets/send_text_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart' show StreamGroup;

class ChatDetail extends StatefulWidget {
  ChatDetail({super.key, required this.me, required this.user});
  Usuari user;
  int me;

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  String? authtoken;

  List<Result> allMessages = [];
  ScrollController scrollController = ScrollController();
  final StreamController<Result> fakeStream = StreamController.broadcast();

  Future getChatDetail() async {
    authtoken = authtoken ?? await getAuthtokenFromStorage();
    debugPrint('AUTHTOKEN $authtoken');

    int userid = 7;
    http.Response response =
        await API(authtoken: authtoken!).getChatDetail(userid);

    String utf8Response = Utf8Decoder().convert(response.bodyBytes);

    return chatDetailFromJson(utf8Response);
  }

  @override
  void initState() {
    mainStream.stream.listen((message) {
      fakeStream.add(message);
    });

    getChatDetail().then((value) {
      allMessages = value.results;
      allMessages.forEach((m) {
        debugPrint('${m.body}');
        fakeStream.add(m);
      });
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                          stream: StreamGroup.merge(
                              [fakeStream.stream, mainStream.stream]),
                          builder: (context, snapshot) {
                            if (snapshot.data == null) return Container();

                            Result message = snapshot.data!;

                            debugPrint('MESSAGE $message');
                            allMessages.add(message);

                            return ListView.builder(
                                controller: scrollController,
                                itemCount: allMessages.length +
                                    1, //one extra element to do something
                                itemBuilder: (context, index) {
                                  if (index == allMessages.length) {
                                    // if (index != 1) {
                                    //   scrollController.animateTo(
                                    //       scrollController
                                    //           .position.maxScrollExtent,
                                    //       duration: Duration(milliseconds: 300),
                                    //       curve: Curves.easeOut);
                                    // }
                                    return Container(
                                      height: 70,
                                    );
                                  } else {
                                    if (allMessages[index].sender ==
                                        widget.me) {
                                      return SendMessage(
                                          message: allMessages[index]);
                                    } else {
                                      return ReceivedMessage(
                                          message: allMessages[index]);
                                    }
                                  }
                                });
                          }),
                    ),
                  ],
                )),
          ),
          Expanded(child: SendTextMessage(user: widget.user)),
        ],
      ),
    );
  }
}
