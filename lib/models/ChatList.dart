import 'dart:convert';

List<Chat> chatListFromJson(String str) =>
    List<Chat>.from(json.decode(str).map((x) => Chat.fromJson(x)));

String chatListToJson(List<Chat> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Chat {
  int chatId;
  int theOther;
  String lastMessage;
  DateTime timestampLastMessage;
  int messagesNotRead;

  Chat({
    required this.chatId,
    required this.theOther,
    required this.lastMessage,
    required this.timestampLastMessage,
    required this.messagesNotRead,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        chatId: json["chat_id"],
        theOther: json["the_other"],
        lastMessage: json["last_message"],
        timestampLastMessage: DateTime.parse(json["timestamp_last_message"]),
        messagesNotRead: json["messages_not_readed"],
      );

  Map<String, dynamic> toJson() => {
        "chat_id": chatId,
        "the_other": theOther,
        "last_message": lastMessage,
        "timestamp_last_message": timestampLastMessage.toIso8601String(),
        "messages_not_readed": messagesNotRead,
      };
}
