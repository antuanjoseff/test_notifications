import 'dart:convert';

List<ChatList> chatListFromJson(String str) =>
    List<ChatList>.from(json.decode(str).map((x) => ChatList.fromJson(x)));

String chatListToJson(List<ChatList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatList {
  int normSender;
  int normReceiver;
  DateTime latestTimestamp;
  String lastMessage;

  ChatList({
    required this.normSender,
    required this.normReceiver,
    required this.latestTimestamp,
    required this.lastMessage,
  });

  factory ChatList.fromJson(Map<String, dynamic> json) => ChatList(
        normSender: json["norm_sender"],
        normReceiver: json["norm_receiver"],
        latestTimestamp: DateTime.parse(json["latest_timestamp"]),
        lastMessage: json["last_message"],
      );

  Map<String, dynamic> toJson() => {
        "norm_sender": normSender,
        "norm_receiver": normReceiver,
        "latest_timestamp": latestTimestamp.toIso8601String(),
        "last_message": lastMessage,
      };
}
