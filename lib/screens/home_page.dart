import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nlp_chatbot_flutter/screens/chat_history_page.dart';
import 'package:nlp_chatbot_flutter/screens/chat_page.dart';
import 'package:nlp_chatbot_flutter/services/conversation.dart';
import 'package:nlp_chatbot_flutter/widgets/home_options.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 25,
                    child: Icon(
                      Icons.android,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Hello!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Text(
                        'Group 7',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "How's Your Day? What Can MedAI Bot Help?",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
                fontFamily: GoogleFonts.copse().fontFamily,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            HomeOptions(
              title: 'Start Chatting\nWith MedAI Bot',
              description:
                  'MedAI Bot is here to help you with your health queries',
              buttonText: 'Start Chat',
              buttonFunction: () {
                setState(() {
                });
                createChat(context).then((value) {
                  setState(() {
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        chatId: value,
                      ),
                    ),
                  );
                });
              },
              color: Colors.blue,
            ),
            const SizedBox(
              height: 10,
            ),
            HomeOptions(
              title: 'Check Your Chat History\nWith MedAI Bot',
              description: 'Check your chat history with MedAI Bot',
              buttonText: 'Check History',
              buttonFunction: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatHistoryPage(),
                ),
              ),
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
