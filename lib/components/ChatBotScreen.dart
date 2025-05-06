import 'package:flutter/material.dart';

class ChatBotScreen extends StatefulWidget {
  final bool isArabic;
  final bool isDarkMode;

  const ChatBotScreen({
    super.key,
    required this.isArabic,
    required this.isDarkMode, // Pass dark mode state
  });

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isRecording = false;

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add({"sender": "user", "text": _messageController.text});
        _messageController.clear();
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            messages.add({
              "sender": "bot",
              "text":
                  widget.isArabic ? "أنا هنا للمساعدة!" : "I'm here to help!"
            });
          });
        });
      });
    }
  }

  void startVoiceRecording() {
    setState(() {
      isRecording = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isRecording = false;
        messages.add({
          "sender": "bot",
          "text": widget.isArabic ? "تحليل الصوت..." : "Analyzing voice..."
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? Color.fromARGB(255, 212, 174, 255) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Color.fromARGB(255, 110, 44, 185)
            : const Color.fromARGB(255, 249, 157, 20),
        elevation: 0,
        title: Text(
          widget.isArabic ? "المساعد الذكي" : "Chat Bot",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Color.fromARGB(255, 8, 8, 8)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isUser = message["sender"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? (isDarkMode
                              ? const Color.fromARGB(255, 133, 90, 209)
                              : Colors.orange[100])
                          : (isDarkMode
                              ? Color.fromARGB(255, 117, 49, 194)
                              : Colors.orange[300]),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        if (!isUser)
                          Image.asset(
                            'images/fox_chatbot.png',
                            height: 25,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          message["text"]!,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: widget.isArabic
                          ? "اكتب رسالة..."
                          : "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(
                          color: isDarkMode
                              ? Color.fromARGB(255, 117, 49, 194)
                              : Colors.black54),
                    ),
                    style: TextStyle(
                        color: isDarkMode
                            ? Color.fromARGB(255, 137, 77, 205)
                            : Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send,
                      color: isDarkMode
                          ? Color.fromARGB(255, 117, 49, 194)
                          : Colors.orange),
                  onPressed: sendMessage,
                ),
                IconButton(
                  icon: Icon(Icons.mic,
                      color: isRecording
                          ? Colors.red
                          : (isDarkMode
                              ? Color.fromARGB(255, 117, 49, 194)
                              : Colors.orange)),
                  onPressed: startVoiceRecording,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
