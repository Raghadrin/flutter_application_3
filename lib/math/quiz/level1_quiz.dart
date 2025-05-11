import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';

class Level1Quiz extends StatefulWidget {
  const Level1Quiz({super.key});

  @override
  State<Level1Quiz> createState() => _Level1QuizState();
}

class _Level1QuizState extends State<Level1Quiz> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  late AnimationController _backgroundController;

  int _currentIndex = 0;
  bool finished = false;
  String feedback = "";
  String? selected;
  bool showNext = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is missing? 8 - _ = 5',
      'options': ['2', '3', '5'],
      'answer': '3',
    },
    {
      'question': 'Which operation makes 5 ☐ 5 = 10?',
      'options': ['+', '-', '*'],
      'answer': '+',
    },
    {
      'question': 'What is missing? 6 + _ = 10',
      'options': ['2', '4', '6'],
      'answer': '4',
    },
    {
      'question': 'Which operation makes 10 ☐ 2 = 5?',
      'options': ['+', '/', '-'],
      'answer': '/',
    },
    {
      'question': 'What is missing? 7 - _ = 5',
      'options': ['1', '2', '3'],
      'answer': '2',
    },
    {
      'question': 'Which operation makes 6 ☐ 2 = 12?',
      'options': ['+', '*', '-'],
      'answer': '*',
    },
    {
      'question': 'What is 4 + 3?',
      'options': ['5', '6', '7'],
      'answer': '7',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _backgroundController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _speak(_questions[_currentIndex]['question']);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _backgroundController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  void _check(String value) async {
    if (showNext) return;

    final correct = value == _questions[_currentIndex]['answer'];

    if (correct) {
      setState(() {
        selected = value;
        feedback = "✅ Correct!";
        showNext = true;
      });
      await flutterTts.speak("Excellent!");
    } else {
      setState(() {
        selected = null;
        feedback = "❌ Try Again!";
      });
      await flutterTts.speak("Try again");
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
      _speak(_questions[_currentIndex]['question']);
    } else {
      setState(() => finished = true);
      _confettiController.play();
      flutterTts.speak("You are great!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Level 1 Quiz", style: TextStyle(color: Colors.black, fontSize: 26)),
        centerTitle: true,
        leading: BackButton(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            CustomPaint(painter: BokehPainter(_backgroundController), child: Container()),
            Center(
              child: finished
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                          child: const Text("🎉 You Are Great! 🎉", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
                          child: const Text("Return", style: TextStyle(fontSize: 28)),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Question ${_currentIndex + 1} of ${_questions.length}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: screenWidth * 0.9,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(20)),
                            child: Text(q['question'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 30),
                          ...q['options'].map<Widget>((opt) {
                            final isCorrect = selected == q['answer'] && opt == q['answer'];
                            final isWrong = selected == opt && opt != q['answer'];
                            Color bgColor = Colors.deepOrangeAccent.shade100;
                            if (isCorrect) bgColor = Colors.green;
                            if (isWrong) bgColor = Colors.redAccent;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ElevatedButton(
                                onPressed: showNext ? null : () => _check(opt),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bgColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text(opt, style: const TextStyle(fontSize: 28)),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 20),
                          if (feedback.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                feedback,
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: feedback.startsWith('✅') ? Colors.green : Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (showNext)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                onPressed: _nextQuestion,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
                                child: const Text("Next", style: TextStyle(fontSize: 26)),
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
