import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nlp_chatbot_flutter/classes/conversation_history.dart';
import 'package:nlp_chatbot_flutter/screens/chat_page.dart';
import 'package:nlp_chatbot_flutter/screens/home_page.dart';
import 'package:nlp_chatbot_flutter/services/conversation.dart';
import 'package:nlp_chatbot_flutter/services/utils.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const Padding(
          padding: EdgeInsets.only(left: 15.0, bottom: 5),
          child: CircleAvatar(
            radius: 40,
            child: Icon(
              Icons.android,
            ),
          ),
        ),
        title: Text(
          'MedAI Bot',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: GoogleFonts.copse().fontFamily,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 80,
              height: 50,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(232, 236, 236, 236),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
          future: getConversationHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  backgroundColor: Colors.white,
                  strokeWidth: 5,
                ),
              );
            } else if (snapshot.hasData) {
              final List<ConversationHistory>? conversationHistory =
                  snapshot.data;
              return ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final ConversationHistory conversation =
                      conversationHistory![index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chatId: conversation.id,
                        ),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            const FaIcon(
                              FontAwesomeIcons.message,
                              color: Colors.black,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              parseChatHistoryDate(
                                  conversation.dateCreated.toString()),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, i) => Container(height: 12),
                itemCount: conversationHistory!.length,
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'No conversation history found',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
          }),
    );
  }
}
