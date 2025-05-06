import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

import 'package:flutter_application_3/math/math_quizes/game_audio_helper.dart';

class Level3Quiz extends StatefulWidget {
  const Level3Quiz({super.key});

  @override
  State<Level3Quiz> createState() => _Level3QuizState();
}

class _Level3QuizState extends State<Level3Quiz> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String feedback = "";
  String? selected;
  bool showNext = false;
  late ConfettiController _confettiController;
  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  late Animation<Offset> _floatingAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "Solve: 2 × 3 + 4",
      "options": ["10", "12", "14"],
      "answer": "10"
    },
    {
      "question": "Find x: 18 = x × 3 + 3",
      "options": ["4", "5", "6"],
      "answer": "5"
    },
    {
      "question": "What comes first in: 10 - 2 × 3 + 1?",
      "options": ["Subtraction", "Multiplication", "Addition"],
      "answer": "Multiplication"
    },
    {
      "question": "Find x: 24 = 2 × x + 4",
      "options": ["10", "8", "9"],
      "answer": "10"
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _backgroundController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat();
    _floatingController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _floatingAnimation =
        Tween<Offset>(begin: Offset(0, -0.02), end: Offset(0, 0.02)).animate(
            CurvedAnimation(
                parent: _floatingController, curve: Curves.easeInOut));
    GameAudioHelper.speak("Question: ${_questions[_currentIndex]["question"]}");
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _backgroundController.dispose();
    _floatingController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _check(String value) async {
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
        feedback = "❌ Wrong!";
      });
      await GameAudioHelper.sayWrongAnswer();
    }
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        selected = null;
        feedback = "";
        showNext = false;
      });
      GameAudioHelper.speak(
          "Question: ${_questions[_currentIndex]["question"]}");
    } else {
      _showResult();
    }
  }

  Future<void> _showResult() async {
    await _audioPlayer.play(AssetSource('audio/kids_cheering.mp3'));
    _confettiController.play();
    GameAudioHelper.sayQuizComplete();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("🎉 You Are Great! 🎉",
            style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text("You completed all questions!",
                style: const TextStyle(fontSize: 32),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Back", style: TextStyle(fontSize: 28))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            CustomPaint(
                painter: BokehPainter(_backgroundController),
                child: Container()),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Question ${_currentIndex + 1}",
                        style: TextStyle(
                            fontSize: 34, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: _floatingAnimation,
                      child: const Text("Read Carefully:",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(q["question"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    ...q["options"].map<Widget>((opt) {
                      final bool isCorrect =
                          selected == q["answer"] && opt == q["answer"];
                      final bool isWrong =
                          selected == opt && opt != q["answer"];
                      Color bgColor = Colors.orange;
                      if (isCorrect) bgColor = Colors.green;
                      if (isWrong) bgColor = Colors.redAccent;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton(
                          onPressed: showNext ? null : () => _check(opt),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bgColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(opt,
                              style: const TextStyle(
                                  fontSize: 32, color: Colors.white)),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    if (feedback.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          feedback,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: feedback.startsWith("✅")
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (showNext)
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 252, 232, 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("Next",
                              style: TextStyle(fontSize: 28)),
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
