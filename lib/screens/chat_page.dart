import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nlp_chatbot_flutter/classes/message.dart';
import 'package:nlp_chatbot_flutter/screens/home_page.dart';
import 'package:nlp_chatbot_flutter/services/conversation.dart';
import 'package:nlp_chatbot_flutter/widgets/message_body.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatId});

  final int chatId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isConversationActive = true;
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool _isSendingResponse = false;

  @override
  void initState() {
    super.initState();
    addMessage(
      Message(
        text:
            "Hello! I am your personal medical chatbot. How can I help you today?",
      ),
    );
    fetchChatMessages();
    listenForPermissions();
    _initTts();
    _initSpeech();
  }

  Future<void> fetchChatMessages() async {
    final chatId = widget.chatId;
    getConversation(chatId).then((conversation) {
      for (final message in conversation) {
        addMessage(Message(text: message.text), true);
              addMessage(Message(text: message.answer), false);
            }
      setState(() {});
      print(messages);
    });
    }

  void _initTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  void listenForPermissions() async {
    final status = await Permission.microphone.status;
    switch (status) {
      case PermissionStatus.denied:
        requestForPermission();
        break;
      case PermissionStatus.granted:
        break;
      case PermissionStatus.limited:
        break;
      case PermissionStatus.permanentlyDenied:
        break;
      case PermissionStatus.restricted:
        break;
      case PermissionStatus.provisional:
        break;
    }
  }

  Future<void> requestForPermission() async {
    await Permission.microphone.request();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    // print("Speech recognition initialized: $_speechEnabled");
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        localeId: "en_US",
      );
      // print("Listening started: ${_speechToText.isListening}");
      setState(() {});
    } else {
      print("Speech recognition is not enabled.");
    }
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    // print("Listening stopped: ${_speechToText.isListening}");
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      messageController.text = _lastWords;
    });
    // print("Recognized words: $_lastWords");
  }

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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: MessageBody(messages: messages),
            ),
            if (_isSendingResponse)
              const LinearProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            if (isConversationActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          onFieldSubmitted: (value) {
                            makeRequest(value);
                            messageController.clear();
                          },
                          controller: messageController,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                            labelStyle: const TextStyle(color: Colors.black),
                            hintText: 'Type here...',
                          ),
                        ),
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     // If not yet listening for speech start, otherwise stop
                    //     if (_speechToText.isNotListening) {
                    //       _startListening();
                    //     } else {
                    //       _stopListening();
                    //     }
                    //   },
                    //   icon: Icon(
                    //     _speechToText.isListening ? Icons.mic : Icons.mic_off,
                    //   ),
                    //   color: _speechToText.isListening
                    //       ? Colors.blue
                    //       : Colors.black,
                    // ),
                    const SizedBox(width: 5),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue,
                      ),
                      height: 50,
                      width: 50,
                      child: IconButton(
                        color: Colors.white,
                        icon: const FaIcon(FontAwesomeIcons.paperPlane),
                        onPressed: () {
                          makeRequest(messageController.text);
                          messageController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
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
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            'Go to Home',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Future<void> makeRequest(String text) async {
    if (text.isEmpty) return;
    final chatId = widget.chatId;
    setState(() {
      addMessage(Message(text: text), true);
      _isSendingResponse = true;
    });

    try {
      await sendMessage(chatId, text).then((value) {
        setState(() {
          _isSendingResponse = false;
          addMessage(Message(text: value), false);
        });
      });
    } catch (e) {
      print('Failed to send message: $e');
    }
    }

  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }
}
