import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MissingLetterGame extends StatefulWidget {
  const MissingLetterGame({super.key});

  @override
  State<MissingLetterGame> createState() => _MissingLetterGameState();
}

class _MissingLetterGameState extends State<MissingLetterGame> {
  final FlutterTts flutterTts = FlutterTts();

  final List<MissingLetterQuestion> questions = [
    MissingLetterQuestion(word: "B__ok", correctLetter: "o", options: ["a", "o", "u"]),
    MissingLetterQuestion(word: "Ca__", correctLetter: "t", options: ["r", "t", "n"]),
    MissingLetterQuestion(word: "Do__", correctLetter: "g", options: ["g", "b", "d"]),
    MissingLetterQuestion(word: "Fi__h", correctLetter: "s", options: ["x", "s", "z"]),
    MissingLetterQuestion(word: "Tr__e", correctLetter: "e", options: ["i", "a", "e"]),
    MissingLetterQuestion(word: "Su__", correctLetter: "n", options: ["m", "r", "n"]),
    MissingLetterQuestion(word: "Bo__k", correctLetter: "o", options: ["a", "o", "e"]),
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

  Future<void> speak(String text) async {
    try {
      await flutterTts.stop();
      await flutterTts.speak(text);
    } catch (e) {
      print("TTS error: $e");
    }
  }

  void checkAnswer(String letter) {
    final isCorrect = letter == questions[currentIndex].correctLetter;
    setState(() {
      feedback = isCorrect ? " Correct!" : " Try again";
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });

    speak(feedback);

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 1), () {
        if (currentIndex < questions.length - 1) {
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
    final q = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("🔡 Missing Letter"),
        backgroundColor: const Color(0xFFFF8B47),
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
                      "Which letter is missing from this word?",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      q.word,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 20,
                alignment: WrapAlignment.center,
                children: q.options.map((opt) {
                  return ElevatedButton(
                    onPressed: () => checkAnswer(opt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC80),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(opt, style: const TextStyle(fontSize: 20)),
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

class MissingLetterQuestion {
  final String word;
  final String correctLetter;
  final List<String> options;

  MissingLetterQuestion({
    required this.word,
    required this.correctLetter,
    required this.options,
  });
}
