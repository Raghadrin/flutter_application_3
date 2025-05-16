import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class KaraokeWordsScreen extends StatefulWidget {
  const KaraokeWordsScreen({super.key});

  @override
  State<KaraokeWordsScreen> createState() => _KaraokeWordsScreenState();
}

class _KaraokeWordsScreenState extends State<KaraokeWordsScreen> {
  final FlutterTts flutterTts = FlutterTts();

  // جملة عربية للتدريب
  List<String> sentenceWords = "أنا أحب اللغة العربية كثيرًا لأنها جميلة!".split(" ").reversed.toList();
  int highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ar-SA");
    flutterTts.setSpeechRate(0.4);
  }

  Future<void> speakWord(int index) async {
    setState(() {
      highlightedIndex = index;
    });
    await flutterTts.speak(sentenceWords[index]);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      highlightedIndex = -1;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality( // ← يجعل الشاشة بالكامل من اليمين لليسار
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6ED),
        appBar: AppBar(
          title: const Text("كلمات تتراقص", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFA726),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 20,
              textDirection: TextDirection.rtl,
              children: List.generate(sentenceWords.length, (index) {
                final word = sentenceWords[index];
                final isHighlighted = index == highlightedIndex;

                return GestureDetector(
                  onTap: () => speakWord(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isHighlighted ? Colors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 2),
                      boxShadow: isHighlighted
                          ? [const BoxShadow(color: Colors.orangeAccent, blurRadius: 8)]
                          : [],
                    ),
                    child: Text(
                      word,
                      style: TextStyle(
                        fontSize: 22,
                        color: isHighlighted ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
