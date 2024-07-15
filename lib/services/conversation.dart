import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nlp_chatbot_flutter/classes/conversation.dart';
import 'package:nlp_chatbot_flutter/classes/conversation_history.dart';
import 'package:nlp_chatbot_flutter/constants/constants.dart';
import 'package:http/http.dart' as http;

Future createChat(
  BuildContext context,
) async {
  try {
    final response = await http
        .post(Uri.parse("$appUrl/create-chat"), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 201) {
      final conversationId = jsonDecode(response.body)['id'];
      return conversationId;
    } else {
      throw Exception(
          'Unable to create chat: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print(e.toString());
    throw Exception('Failed to create chat: $e');
  }
}

Future<List<Conversation>> getConversation(
  int chatId,
) async {
  try {
    final response = await http.get(Uri.parse("$appUrl/chat/$chatId"));
    if (response.statusCode == 200) {
      final List<Conversation> conversation = jsonDecode(response.body)
          .map<Conversation>((json) => Conversation.fromJson(json))
          .toList();
      return conversation;
    } else {
      throw Exception(
          'Unable to get conversation: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print(e.toString());
    throw Exception('Failed to get conversation: $e');
  }
}

Future<List<ConversationHistory>> getConversationHistory() async {
  try {
    final response = await http.get(Uri.parse("$appUrl/chat-history"));
    if (response.statusCode == 200) {
      final List<ConversationHistory> conversationHistory =
          jsonDecode(response.body)
              .map<ConversationHistory>(
                  (json) => ConversationHistory.fromJson(json))
              .toList();
      print(conversationHistory);
      return conversationHistory;
    } else {
      throw Exception(
          'Unable to get conversation history: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print(e.toString());
    throw Exception('Failed to get conversation history: $e');
  }
}

Future sendMessage(
  int chatId,
  String request,
) async {
  try {
    final response = await http.post(Uri.parse("$appUrl/chat/$chatId"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'text': request,
        }));
    if (response.statusCode == 201) {
      final message = jsonDecode(response.body)['answer'];
      return message;
    } else {
      throw Exception(
          'Unable to send message: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print(e.toString());
    throw Exception('Failed to send message: $e');
  }
}
