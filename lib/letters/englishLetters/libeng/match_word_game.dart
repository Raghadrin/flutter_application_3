import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MatchWordGame extends StatefulWidget {
  const MatchWordGame({super.key});

  @override
  State<MatchWordGame> createState() => _MatchWordGameState();
}

class _MatchWordGameState extends State<MatchWordGame> {
  final FlutterTts flutterTts = FlutterTts();

  final List<WordSoundPair> data = [
    WordSoundPair(word: "Cat", sound: "Cat"),
    WordSoundPair(word: "Ball", sound: "Ball"),
    WordSoundPair(word: "Dog", sound: "Dog"),
    WordSoundPair(word: "Fish", sound: "Fish"),
    WordSoundPair(word: "Tree", sound: "Tree"),
    WordSoundPair(word: "Book", sound: "Book"),
    WordSoundPair(word: "Sun", sound: "Sun"),
  ];

  int currentIndex = 0;
  String feedback = '';
  Color feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
  }

  Future<void> playSound(String text) async {
    try {
      await flutterTts.stop();
      await flutterTts.speak(text);
    } catch (e) {
      print("TTS Error: $e");
    }
  }

  void checkAnswer(String answer) {
    final correct = data[currentIndex].word;
    bool isCorrect = answer == correct;

    setState(() {
      feedback = isCorrect ? "✅ Correct!" : "❌ Try again";
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });

    playSound(feedback);

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 1), () {
        if (currentIndex < data.length - 1) {
          setState(() {
            currentIndex++;
            feedback = '';
            feedbackColor = Colors.transparent;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = data[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8B47),
        title: const Text("🔊 Match Word with Sound"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    const Text(
                      "Which word matches this sound?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => playSound(item.sound),
                      icon: const Icon(Icons.volume_up),
                      label: const Text("🔊 Play Sound"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 40,
                alignment: WrapAlignment.center,
                children: data.map((pair) {
                  return ElevatedButton(
                    onPressed: () => checkAnswer(pair.word),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC80),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 28),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child:
                        Text(pair.word, style: const TextStyle(fontSize: 20)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              if (feedback.isNotEmpty)
                Text(
                  feedback,
                  style: TextStyle(
                    fontSize: 24,
                    color: feedbackColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WordSoundPair {
  final String word;
  final String sound;

  WordSoundPair({required this.word, required this.sound});
}
