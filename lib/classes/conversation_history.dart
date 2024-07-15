// To parse this JSON data, do
//
//     final conversationHistory = conversationHistoryFromJson(jsonString);

import 'dart:convert';

List<ConversationHistory> conversationHistoryFromJson(String str) => List<ConversationHistory>.from(json.decode(str).map((x) => ConversationHistory.fromJson(x)));

String conversationHistoryToJson(List<ConversationHistory> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConversationHistory {
    int id;
    DateTime dateCreated;

    ConversationHistory({
        required this.id,
        required this.dateCreated,
    });

    factory ConversationHistory.fromJson(Map<String, dynamic> json) => ConversationHistory(
        id: json["id"],
        dateCreated: DateTime.parse(json["date_created"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "date_created": dateCreated.toIso8601String(),
    };
}
