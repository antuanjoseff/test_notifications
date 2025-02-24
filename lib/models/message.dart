import 'dart:convert';

List<Message> messageFromJson(String str) =>
    List<Message>.from(json.decode(str).map((x) => Message.fromJson(x)));

String messageToJson(List<Message> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Message {
  String me;
  String the_other;
  String last_message;
  DateTime lastest_tmestamp;

  Message({
    required this.me,
    required this.the_other,
    required this.last_message,
    required this.lastest_tmestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    me: json["sender"],
    the_other: json["receiver"],
    last_message: json["message"],
    lastest_tmestamp: DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "sender": me,
    "receiver": the_other,
    "message": last_message,
    "date": lastest_tmestamp.toIso8601String(),
  };
}
