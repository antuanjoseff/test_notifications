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
  List<Result> results;

  ChatDetailModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory ChatDetailModel.fromJson(Map<String, dynamic> json) =>
      ChatDetailModel(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class Result {
  int sender;
  int receiver;
  String body;
  DateTime timestamp;

  Result({
    required this.sender,
    required this.receiver,
    required this.body,
    required this.timestamp,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        sender: json["sender"],
        receiver: json["receiver"],
        body: json["body"],
        timestamp: DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "sender": sender,
        "receiver": receiver,
        "body": body,
        "timestamp": timestamp.toIso8601String(),
      };
}
