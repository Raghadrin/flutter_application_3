import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../game_audio_helper.dart';
import 'dart:math';

class Level2Quiz extends StatefulWidget {
  const Level2Quiz({super.key});

  @override
  State<Level2Quiz> createState() => _Level2QuizState();
}

class _Level2QuizState extends State<Level2Quiz> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String feedback = "";
  String? selected;
  bool showNext = false;
  late ConfettiController _confettiController;
  late AnimationController _twinkleController;

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "What number times 3 equals 12?",
      "options": ["3", "4", "5"],
      "answer": "4"
    },
    {
      "question": "Complete: 20 = _ * 4",
      "options": ["4", "5", "6"],
      "answer": "5"
    },
    {
      "question": "What is 2 + 3 * 2?",
      "options": ["8", "10", "12"],
      "answer": "8"
    },
    {
      "question": "What is 6 / 3 + 5?",
      "options": ["7", "8", "9"],
      "answer": "7"
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _twinkleController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    GameAudioHelper.speak("Question: " + _questions[_currentIndex]["question"]);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  void _check(String value) async {
    if (selected == _questions[_currentIndex]["answer"]) return;
    final correct = value == _questions[_currentIndex]["answer"];

    if (correct) {
      setState(() {
        selected = value;
        feedback = "✅ Correct!";
        showNext = true;
      });
      await GameAudioHelper.sayCorrectAnswer();
    } else {
      setState(() {
        selected = null;
        feedback = "❌ Try Again!";
      });
      await GameAudioHelper.sayWrongAnswer();
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        selected = null;
        feedback = "";
        showNext = false;
      });
      GameAudioHelper.speak("Question: " + _questions[_currentIndex]["question"]);
    } else {
      _showResult();
    }
  }

  void _showResult() async {
    await GameAudioHelper.sayQuizComplete();
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("🎉 You Are Great!", textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.orange)),
        content: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 50,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text("Back", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextBox(String text, {Color textColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            CustomPaint(
              painter: BokehPainter(_twinkleController),
              child: Container(),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTextBox("Question ${_currentIndex + 1} of ${_questions.length}"),
                    _buildTextBox("Solve the below question:", textColor: Colors.black),
                    _buildTextBox(q["question"]),
                    ...q["options"].map<Widget>((opt) {
                      final bool isCorrect = selected == q["answer"] && opt == q["answer"];
                      final bool isWrong = selected == opt && opt != q["answer"];
                      Color bgColor = Colors.white;
                      if (isCorrect) bgColor = Colors.greenAccent;
                      if (isWrong) bgColor = Colors.redAccent;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: ElevatedButton(
                          onPressed: showNext ? null : () => _check(opt),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bgColor,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Text(opt, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 30),
                    if (feedback.isNotEmpty)
                      _buildTextBox(feedback, textColor: feedback.startsWith("✅") ? Colors.green : Colors.red),
                    if (showNext)
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 249, 212, 158),
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Text("Next", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BokehPainter extends CustomPainter {
  final Animation<double> animation;
  final random = Random();
  BokehPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = 0.5 + 0.5 * sin(animation.value * 2 * pi + i);
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
