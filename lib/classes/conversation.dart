// To parse this JSON data, do
//
//     final conversation = conversationFromJson(jsonString);

import 'dart:convert';

List<Conversation> conversationFromJson(String str) => List<Conversation>.from(json.decode(str).map((x) => Conversation.fromJson(x)));

String conversationToJson(List<Conversation> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Conversation {
    int id;
    String text;
    String answer;
    DateTime dateCreated;
    int chat;

    Conversation({
        required this.id,
        required this.text,
        required this.answer,
        required this.dateCreated,
        required this.chat,
    });

    factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json["id"],
        text: json["text"],
        answer: json["answer"],
        dateCreated: DateTime.parse(json["date_created"]),
        chat: json["chat"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "answer": answer,
        "date_created": dateCreated.toIso8601String(),
        "chat": chat,
    };
}
