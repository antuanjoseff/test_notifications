import 'dart:convert';

List<ChatList> chatListFromJson(String str) =>
    List<ChatList>.from(json.decode(str).map((x) => ChatList.fromJson(x)));

String chatListToJson(List<ChatList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatList {
  int chatId;
  int theOther;
  String lastMessage;
  DateTime timestampLastMessage;
  int messagesNotReaded;

  ChatList({
    required this.chatId,
    required this.theOther,
    required this.lastMessage,
    required this.timestampLastMessage,
    required this.messagesNotReaded,
  });

  factory ChatList.fromJson(Map<String, dynamic> json) => ChatList(
        chatId: json["chat_id"],
        theOther: json["the_other"],
        lastMessage: json["last_message"],
        timestampLastMessage: DateTime.parse(json["timestamp_last_message"]),
        messagesNotReaded: json["messages_not_readed"],
      );

  Map<String, dynamic> toJson() => {
        "chat_id": chatId,
        "the_other": theOther,
        "last_message": lastMessage,
        "timestamp_last_message": timestampLastMessage.toIso8601String(),
        "messages_not_readed": messagesNotReaded,
      };
}
