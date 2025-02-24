// To parse this JSON data, do
//
//     final chatList = chatListFromJson(jsonString);

import 'dart:convert';

List<ChatList> chatListFromJson(String str) =>
    List<ChatList>.from(json.decode(str).map((x) => ChatList.fromJson(x)));

String chatListToJson(List<ChatList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatList {
  int me;
  int theOther;
  DateTime latestTimestamp;
  String lastMessage;

  ChatList({
    required this.me,
    required this.theOther,
    required this.latestTimestamp,
    required this.lastMessage,
  });

  factory ChatList.fromJson(Map<String, dynamic> json) => ChatList(
        me: json["me"],
        theOther: json["the_other"],
        latestTimestamp: DateTime.parse(json["latest_timestamp"]),
        lastMessage: json["last_message"],
      );

  Map<String, dynamic> toJson() => {
        "me": me,
        "the_other": theOther,
        "latest_timestamp": latestTimestamp.toIso8601String(),
        "last_message": lastMessage,
      };
}
