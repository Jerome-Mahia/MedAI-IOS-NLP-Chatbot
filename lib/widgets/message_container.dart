// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nlp_chatbot_flutter/classes/message.dart';
import 'package:nlp_chatbot_flutter/screens/chat_webview_page.dart';

// The message container widget
class MessageContainer extends StatefulWidget {
  final Message message;
  final bool isUserMessage;

  const MessageContainer({
    super.key,
    required this.message,
    this.isUserMessage = false,
  });

  @override
  State<MessageContainer> createState() => _MessageContainerState();
}

class _MessageContainerState extends State<MessageContainer> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setSpeechRate(0.52);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat.jm().format(now);
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: widget.isUserMessage
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.isUserMessage ? Colors.blue : Colors.white,
                  borderRadius: widget.isUserMessage
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15))
                      : const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                ),
                padding: const EdgeInsets.all(10),
                child: Linkify(
                  text: widget.message.text,
                  onOpen: (link) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChatWebViewPage(url: link.url)));
                  },
                  style: TextStyle(
                    color: widget.isUserMessage ? Colors.white : Colors.black,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                  linkStyle: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (!widget.isUserMessage)
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.volumeHigh,
                          size: 17,
                          color: Colors.grey[800],
                        ),
                        onPressed: () {
                          // Text to speech
                          if (!widget.isUserMessage) {
                            if (widget.message.text.isNotEmpty) {
                              _flutterTts.speak(widget.message.text);
                            }
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
