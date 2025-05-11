import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class RecordSentenceGame extends StatefulWidget {
  const RecordSentenceGame({super.key});

  @override
  State<RecordSentenceGame> createState() => _RecordSentenceGameState();
}

class _RecordSentenceGameState extends State<RecordSentenceGame> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  final List<String> sentences = [
    "The cat is sleeping on the couch.",
    "She reads a book every night.",
    "We love to play in the park.",
    "The sun rises in the east.",
    "He drinks water after running.",
    "Birds fly high in the sky."
  ];

  int currentIndex = 0;
  String recognizedText = '';
  bool isListening = false;
  String feedback = '';
  Color feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakSentence(String text) async {
    try {
      await flutterTts.stop();
      await flutterTts.speak(text);
    } catch (e) {
      print("TTS error: $e");
    }
  }

  void _startListening() async {
    bool available = await speech.initialize();
    if (!available) return;

    setState(() {
      recognizedText = '';
      feedback = '';
      feedbackColor = Colors.transparent;
      isListening = true;
    });

    speech.listen(
      onResult: (val) {
        setState(() {
          recognizedText = val.recognizedWords;
          isListening = false;
        });
        _evaluateSentence();
      },
      listenFor: const Duration(seconds: 8),
      localeId: 'en_US',
    );
  }

  void _evaluateSentence() {
    final original = sentences[currentIndex].toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final spoken = recognizedText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    int matchCount = 0;
    List<String> originalWords = original.split(' ');
    List<String> spokenWords = spoken.split(' ');

    for (var word in originalWords) {
      if (spokenWords.contains(word)) matchCount++;
    }

    double score = (matchCount / originalWords.length) * 100;

    setState(() {
      if (score >= 80) {
        feedback = "✅ Great pronunciation!";
        feedbackColor = Colors.green;
      } else {
        feedback = "❌ Try again";
        feedbackColor = Colors.red;
      }
    });
  }

  void _nextSentence() {
    if (currentIndex < sentences.length - 1) {
      setState(() {
        currentIndex++;
        recognizedText = '';
        feedback = '';
        feedbackColor = Colors.transparent;
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sentence = sentences[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("🎤 Record the Sentence"),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF8B47),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Text(
                  sentence,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _speakSentence(sentence),
                icon: const Icon(Icons.volume_up),
                label: const Text("🔊 Hear Sentence"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isListening ? null : _startListening,
                icon: Icon(isListening ? Icons.stop : Icons.mic),
                label: Text(isListening ? "🎧 Listening..." : "🎙 Record Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC80),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),
              if (recognizedText.isNotEmpty)
                Text(
                  "You said: $recognizedText",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 12),
              if (feedback.isNotEmpty)
                Text(
                  feedback,
                  style: TextStyle(
                    color: feedbackColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),
              if (currentIndex < sentences.length - 1)
                ElevatedButton.icon(
                  onPressed: _nextSentence,
                  icon: const Icon(Icons.navigate_next),
                  label: const Text("➡️ Next Sentence"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD699),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
