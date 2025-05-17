import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ReverseEquationGame extends StatefulWidget {
  const ReverseEquationGame({super.key});

  @override
  State<ReverseEquationGame> createState() => _ReverseEquationGameState();
}

class _ReverseEquationGameState extends State<ReverseEquationGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool isCorrect = false;
  bool showNext = false;

  final List<Map<String, dynamic>> _questions = [
    {
      "equation": "x × 3 + 3 = 18",
      "question": "What is x?",
      "options": ["5", "6", "4"],
      "answer": "5",
      "image": "reverse_eq_1.png"
    },
    {
      "equation": "x + 4 = 10",
      "question": "What is x?",
      "options": ["6", "7", "5"],
      "answer": "6",
      "image": "reverse_eq_2.png"
    },
    {
      "equation": "20 = x × 4",
      "question": "What is x?",
      "options": ["5", "4", "6"],
      "answer": "5",
      "image": "reverse_eq_3.png"
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
    _speak(_questions[currentIndex]['equation'] + ". " + _questions[currentIndex]['question']);
  }

  void _check(String value) {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      isCorrect = (value == correct);
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
      _speak("Excellent! You finished the reverse equations. Your score is $score out of ${_questions.length}");
      _showFinalDialog();
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("🔁 Play Again", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  String _getStars(int score, int total) {
    double ratio = score / total;
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }

  Color _colorToken(String token) {
    if (token == "x") return Colors.blue;
    if (["+", "-", "=", "×", "*", "/"].contains(token)) return Colors.deepOrange;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];
    final tokens = RegExp(r'x|\d+|[+=×*/-]').allMatches(q['equation']).map((e) => e.group(0)!).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Reverse Equation Game"), backgroundColor: Colors.orange),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score display
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("🏆 Score: $score", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),

              // Equation display
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepOrange, width: 2),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: tokens.map((token) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _colorToken(token), width: 2),
                      ),
                      child: Text(
                        token,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _colorToken(token),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Question
              Text(
                q['question'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 20),

              if (q['image'] != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.1),
                    border: Border.all(color: Colors.deepOrange, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 20, top: 12),
                  child: Image.asset("images/new_images/${q['image']}", height: 160),
                ),

              // Options
              Wrap(
                spacing: 20,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: q["options"].map<Widget>((opt) {
                  final correct = opt == q["answer"];
                  final bgColor = isCorrect && correct ? Colors.green : Colors.orangeAccent.shade100;
                  return ElevatedButton(
                    onPressed: showNext ? null : () => _check(opt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(opt, style: const TextStyle(fontSize: 24)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              if (isCorrect) const Text("✅ Correct!", style: TextStyle(fontSize: 22, color: Colors.green)),

              if (showNext)
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text("Next", style: TextStyle(fontSize: 22)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
