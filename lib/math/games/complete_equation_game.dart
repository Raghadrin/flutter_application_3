import 'package:flutter/material.dart';
import 'package:flutter_application_3/math/theme.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CompleteEquationGame extends StatefulWidget {
  const CompleteEquationGame({super.key});

  @override
  State<CompleteEquationGame> createState() => _CompleteEquationGameState();
}

class _CompleteEquationGameState extends State<CompleteEquationGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  String? droppedValue;
  bool showNext = false;
  int currentSpokenIndex = -1;

  final List<Map<String, dynamic>> _questions = [
    {
      "equationParts": ["3", "+", "_", "=", "5"],
      "answer": "2",
      "options": ["1", "2", "3"],
      "image": "3_plus_question_equals_5.png",
    },
    {
      "equationParts": ["4", "+", "_", "=", "7"],
      "answer": "3",
      "options": ["2", "3", "4"],
      "image": "4_plus_question_equals_7.png",
    },
    {
      "equationParts": ["_", "+", "2", "=", "6"],
      "answer": "4",
      "options": ["3", "4", "5"],
      "image": "question_plus_2_equals_6.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _speakCurrentQuestionKaraoke();
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  Future<void> _speakCurrentQuestionKaraoke() async {
    final parts = _questions[currentIndex]['equationParts'] as List<String>;

    final Map<String, String> speakMap = {
      '+': 'plus',
      '-': 'minus',
      '=': 'equals',
      '_': 'blank',
      '1': 'one', '2': 'two', '3': 'three',
      '4': 'four', '5': 'five', '6': 'six',
      '7': 'seven', '8': 'eight', '9': 'nine',
      '0': 'zero',
    };

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      setState(() => currentSpokenIndex = i);
      await _speak(speakMap[part] ?? part);
      await Future.delayed(const Duration(milliseconds: 500));
    }
    setState(() => currentSpokenIndex = -1);
  }

  void _checkAnswer(String value) {
    final correct = _questions[currentIndex]['answer'];
    setState(() => droppedValue = value);

    if (value == correct) {
      score++;
      showNext = true;
      _speak("Correct!");
      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    } else {
      _speak("Try again!");
    }
  }

  void _nextQuestion() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        droppedValue = null;
        showNext = false;
      });
      _speakCurrentQuestionKaraoke();
    } else {
      _speak("Excellent! You completed all equations.");
      _showFinalDialog();
    }
  }

  void _resetGame() {
    setState(() {
      currentIndex = 0;
      score = 0;
      droppedValue = null;
      showNext = false;
    });
    _speakCurrentQuestionKaraoke();
    Navigator.pop(context);
  }

  String _getStars(int score, int total) {
    double ratio = score / total;
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }

  void _showFinalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Good Job!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your Score: $score / ${_questions.length}", style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(_getStars(score, _questions.length), style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("🔁 Play Again", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];
    final parts = q['equationParts'] as List<String>;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Complete the Equation"),
        backgroundColor: AppTheme.appBarColor,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("🏆 Score: $score", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(parts.length, (index) {
                  final part = parts[index];
                  final isHighlighted = index == currentSpokenIndex;

                  if (part == "_") {
                    return DragTarget<String>(
                      builder: (context, candidate, rejected) => Container(
                        width: 60,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: droppedValue != null ? Colors.greenAccent : Colors.white,
                          border: Border.all(color: Colors.deepOrange, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(droppedValue ?? "_", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      onAccept: _checkAnswer,
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      part,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isHighlighted ? Colors.orange : Colors.black,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              if (q['image'] != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    border: Border.all(color: Colors.deepOrange, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Image.asset("images/new_images/${q['image']}", height: 160),
                ),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: (q['options'] as List<String>).map((opt) {
                  return Draggable<String>(
                    data: opt,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildOption(opt, dragging: true),
                    ),
                    childWhenDragging: Opacity(opacity: 0.4, child: _buildOption(opt)),
                    child: _buildOption(opt),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String value, {bool dragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: dragging ? Colors.amber : Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: dragging ? [] : [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }
}
