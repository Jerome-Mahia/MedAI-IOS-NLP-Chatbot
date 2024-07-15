import 'package:flutter/material.dart';
import 'package:nlp_chatbot_flutter/classes/message.dart';
import 'package:nlp_chatbot_flutter/widgets/message_container.dart';

class MessageBody extends StatelessWidget {
  final List<Map<String, dynamic>> messages;

  const MessageBody({
    super.key,
    this.messages = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, i) {
        var obj = messages[messages.length - 1 - i];
        Message message = obj['message'];
        bool isUserMessage = obj['isUserMessage'] ?? false;
        return Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // if (!isUserMessage) const CircleAvatar(child: Icon(Icons.android)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: MessageContainer(
                message: message,
                isUserMessage: isUserMessage,
              ),
            ),
            // if (isUserMessage) const CircleAvatar(child: Icon(Icons.person)),
          ],
        );
      },
      separatorBuilder: (_, i) => Container(height: 10),
      itemCount: messages.length,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
    );
  }
}
