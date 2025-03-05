// To parse this JSON data, do
//
//     final chatDetail = chatDetailFromJson(jsonString);

import 'dart:convert';

ChatDetailModel chatDetailFromJson(String str) =>
    ChatDetailModel.fromJson(json.decode(str));

String chatDetailToJson(ChatDetailModel data) => json.encode(data.toJson());

class ChatDetailModel {
  int count;
  dynamic next;
  dynamic previous;
  List<Result> messages;

  ChatDetailModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.messages,
  });

  factory ChatDetailModel.fromJson(Map<String, dynamic> json) =>
      ChatDetailModel(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        messages:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": List<dynamic>.from(messages.map((x) => x.toJson())),
      };
}

class Result {
  int sender;
  int receiver;
  int chat;
  String body;
  DateTime timestamp;

  Result({
    required this.sender,
    required this.receiver,
    required this.chat,
    required this.body,
    required this.timestamp,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        sender: json["sender"],
        receiver: json["receiver"],
        chat: json["chat_id"],
        body: json["body"],
        timestamp: DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "sender": sender,
        "receiver": receiver,
        "chat_id": chat,
        "body": body,
        "timestamp": timestamp.toIso8601String(),
      };
}
