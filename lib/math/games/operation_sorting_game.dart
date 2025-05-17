import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class OperationSortingGame extends StatefulWidget {
  const OperationSortingGame({super.key});

  @override
  State<OperationSortingGame> createState() => _OperationSortingGameState();
}

class _OperationSortingGameState extends State<OperationSortingGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool isCorrect = false;
  bool showNext = false;

  final List<Map<String, dynamic>> _questions = [
    {
      "equation": "4 ☐ 2 = 8",
      "answer": "*",
      "options": ["+", "-", "*", "/"]
    },
    {
      "equation": "9 ☐ 3 = 3",
      "answer": "/",
      "options": ["+", "-", "*", "/"]
    },
    {
      "equation": "6 ☐ 2 = 4",
      "answer": "-",
      "options": ["+", "-", "*", "/"]
    },
  ];

  @override
  void initState() {
    super.initState();
    _speakCurrent();
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  void _speakCurrent() {
    final eq = _questions[currentIndex]['equation'];
    _speak("Which operation completes this equation: $eq");
  }

  void _check(String value) {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      isCorrect = value == correct;
      showNext = isCorrect;
      if (isCorrect) score++;
    });
    _speak(isCorrect ? "Correct!" : "Try again!");
  }

  void _next() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = false;
        showNext = false;
      });
      _speakCurrent();
    } else {
      _speak("Great job! You finished all the questions.");
      _showFinalDialog();
    }
  }

  String _getStars(int score, int total) {
    double ratio = score / total;
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }

  void _resetGame() {
    setState(() {
      currentIndex = 0;
      score = 0;
      isCorrect = false;
      showNext = false;
    });
    Navigator.pop(context);
    _speakCurrent();
  }

  void _showFinalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("🎉 Well done!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your Score: $score / ${_questions.length}", style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(_getStars(score, _questions.length), style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text("🔁 Play Again", style: TextStyle(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose the Operation"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: const Color(0xFFFFF3E0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Question white box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  border: Border.all(color: Colors.deepOrange, width: 2),
                ),
                child: Text(
                  q['equation'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),

              // Option buttons
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: q["options"].map<Widget>((symbol) {
                  final correct = symbol == q["answer"];
                  final bgColor = isCorrect && correct ? Colors.green : Colors.deepOrange.shade100;
                  return ElevatedButton(
                    onPressed: showNext ? null : () => _check(symbol),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      symbol,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Feedback
              if (isCorrect)
                const Text("✅ Correct!", style: TextStyle(fontSize: 26, color: Colors.green, fontWeight: FontWeight.w600)),

              const SizedBox(height: 10),

              if (showNext)
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  ),
                  child: const Text("Next", style: TextStyle(fontSize: 24)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
