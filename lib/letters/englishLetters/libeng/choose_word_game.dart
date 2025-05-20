import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChooseWordGame extends StatefulWidget {
  const ChooseWordGame({super.key});

  @override
  State<ChooseWordGame> createState() => _ChooseWordGameState();
}

class _ChooseWordGameState extends State<ChooseWordGame> {
  final FlutterTts flutterTts = FlutterTts();

  int currentIndex = 0;
  String feedback = '';
  Color feedbackColor = Colors.transparent;

  final List<WordQuestion> questions = [
    WordQuestion(
      sentenceWithGap: '_ go to school every day.',
      correctWord: 'I',
      options: ['He', 'I', 'They'],
    ),
    WordQuestion(
      sentenceWithGap: 'She _ a red apple.',
      correctWord: 'eats',
      options: ['eat', 'eats', 'ate'],
    ),
    WordQuestion(
      sentenceWithGap: 'They _ playing in the park.',
      correctWord: 'are',
      options: ['is', 'are', 'was'],
    ),
    WordQuestion(
      sentenceWithGap: 'We _ to the zoo last week.',
      correctWord: 'went',
      options: ['go', 'goes', 'went'],
    ),
    WordQuestion(
      sentenceWithGap: 'My father _ a new car.',
      correctWord: 'bought',
      options: ['buy', 'bought', 'buys'],
    ),
    WordQuestion(
      sentenceWithGap: 'I _ my homework before dinner.',
      correctWord: 'did',
      options: ['do', 'does', 'did'],
    ),
    WordQuestion(
      sentenceWithGap: 'He _ very happy today.',
      correctWord: 'is',
      options: ['are', 'is', 'was'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
  }

  Future<void> giveVoiceFeedback(String message) async {
    try {
      await flutterTts.stop();
      await flutterTts.speak(message);
    } catch (e) {
      print("TTS error: $e");
    }
  }

  void checkAnswer(String word) {
    final isCorrect = word == questions[currentIndex].correctWord;
    setState(() {
      feedback = isCorrect ? " Correct!" : " Try again";
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });
    giveVoiceFeedback(feedback);

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
        backgroundColor: const Color(0xFFFF8B47),
        title: const Text("🧩 Choose the Correct Word"),
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
                      "Choose the correct word to complete the sentence:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      q.sentenceWithGap,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
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
                      backgroundColor: const Color(0xFFFFA726),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(opt, style: const TextStyle(fontSize: 22)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              if (feedback.isNotEmpty)
                Text(
                  feedback,
                  style: TextStyle(
                    color: feedbackColor,
                    fontSize: 24,
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

class WordQuestion {
  final String sentenceWithGap;
  final String correctWord;
  final List<String> options;

  WordQuestion({
    required this.sentenceWithGap,
    required this.correctWord,
    required this.options,
  });
}
