import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class MultiStepEquationGame extends StatefulWidget {
  const MultiStepEquationGame({super.key});

  @override
  State<MultiStepEquationGame> createState() => _MultiStepEquationGameState();
}

class _MultiStepEquationGameState extends State<MultiStepEquationGame> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Map<String, dynamic>> _originalQuestions = [
    {"expression": "2 * 3 + 4", "answer": 10, "hint": "First multiply, then add."},
    {"expression": "5 + 4 * 2 - 3", "answer": 10, "hint": "Multiply first before adding."},
    {"expression": "10 - 2 * 3 + 1", "answer": 5, "hint": "Start by multiplying."},
    {"expression": "12 / 2 + 5 * 2", "answer": 16, "hint": "Divide, then multiply."},
    {"expression": "6 + 8 / 4 * 3", "answer": 12, "hint": "Follow the order of operations."},
  ];

  late List<Map<String, dynamic>> _questions;
  int _currentIndex = 0;
  String feedback = '';
  bool finished = false;
  bool showHint = false;
  final TextEditingController _controller = TextEditingController();
  late AnimationController _twinkleController;
  late AnimationController _confettiController;
  late AnimationController _playAgainGlowController;
  late Animation<double> _playAgainAnimation;
  late AnimationController _hintScaleController;

  @override
  void initState() {
    super.initState();
    _questions = List.from(_originalQuestions)..shuffle(Random());
    _twinkleController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _confettiController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _playAgainGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _playAgainAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _playAgainGlowController, curve: Curves.easeInOut));
    _hintScaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _speakInstructionAndParts();
  }

  @override
  void dispose() {
    _controller.dispose();
    _twinkleController.dispose();
    _confettiController.dispose();
    _playAgainGlowController.dispose();
    _hintScaleController.dispose();
    _audioPlayer.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakInstructionAndParts() async {
    await flutterTts.speak("Solve the following equation");
    await Future.delayed(const Duration(milliseconds: 800));
    final expr = _questions[_currentIndex]["expression"];
    for (String part in expr.split(' ')) {
      String spokenPart = part.replaceAll("*", "times").replaceAll("/", "divided by").replaceAll("+", "plus").replaceAll("-", "minus");
      await flutterTts.speak(spokenPart);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _playCheeringSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/kids_cheering.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  Future<void> _checkAnswer() async {
    final userAnswer = int.tryParse(_controller.text.trim());
    final correct = _questions[_currentIndex]["answer"];

    if (userAnswer == correct) {
      setState(() => feedback = "✅ Great Job!");
      await flutterTts.speak("Correct!");
      await Future.delayed(const Duration(milliseconds: 600));
      _nextQuestion();
    } else {
      setState(() => feedback = "❌ Try Again!");
      await flutterTts.speak("Try again");
    }
  }

  void _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        feedback = '';
        showHint = false;
        _controller.clear();
      });
      await _speakInstructionAndParts();
    } else {
      setState(() => finished = true);
      await flutterTts.speak("You did very well!");
      await _playCheeringSound();
    }
  }

  void _restartGame() {
    setState(() {
      _questions.shuffle(Random());
      _currentIndex = 0;
      feedback = '';
      showHint = false;
      finished = false;
      _controller.clear();
    });
    _speakInstructionAndParts();
  }

  Future<void> _readHint() async {
    final hint = _questions[_currentIndex]["hint"];
    await flutterTts.speak("Here's a hint. $hint");
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Multi-Step Equation",
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFE0B2), Color(0xFFFFB347)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            CustomPaint(painter: SpiralPainter(_twinkleController), child: Container()),
            if (finished) CustomPaint(painter: EmojiConfettiPainter(animation: _confettiController), child: Container()),
            if (showHint) CustomPaint(painter: SparklePainter(animation: _twinkleController), child: Container()),
            Center(
              child: finished
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
                          child: const Text("🎉 You Did Very Well! 🎉", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 30),
                        ScaleTransition(
                          scale: _playAgainAnimation,
                          child: ElevatedButton(
                            onPressed: _restartGame,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)),
                            child: const Text("Play Again", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
                            child: const Text("Solve the following equation", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                            child: Text(current["expression"], style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(18)),
                            child: TextField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 40),
                              decoration: const InputDecoration(hintText: '?', border: InputBorder.none),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _checkAnswer,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18)),
                            child: const Text("Submit", style: TextStyle(fontSize: 30)),
                          ),
                          const SizedBox(height: 20),
                          if (feedback.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.75), borderRadius: BorderRadius.circular(18)),
                              child: Text(feedback, style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: feedback.startsWith('✅') ? Colors.green : Colors.redAccent), textAlign: TextAlign.center),
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() => showHint = !showHint);
                              if (showHint) {
                                _hintScaleController.forward(from: 0.0);
                                await _readHint();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD6A5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                            ),
                            child: Text(showHint ? "Hide Hint" : "Show Hint", style: const TextStyle(fontSize: 30)),
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
class SpiralPainter extends CustomPainter {
  final Animation<double> animation;
  SpiralPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final random = Random();
    for (int i = 0; i < 20; i++) {
      final centerX = random.nextDouble() * size.width;
      final centerY = random.nextDouble() * size.height;
      final radius = 5 + random.nextDouble() * 10;
      final path = Path();
      for (double theta = 0; theta < 6 * pi; theta += 0.1) {
        final r = radius * theta / (6 * pi);
        final x = centerX + r * cos(theta + animation.value * 2 * pi);
        final y = centerY + r * sin(theta + animation.value * 2 * pi);
        if (theta == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SpiralPainter oldDelegate) => true;
}
class EmojiConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  EmojiConfettiPainter({required this.animation}) : super(repaint: animation);
  final random = Random();
  final emojis = ['🎈', '🎉', '✨', '🥳'];

  @override
  void paint(Canvas canvas, Size size) {
    final count = 20;
    for (int i = 0; i < count; i++) {
      final text = emojis[random.nextInt(emojis.length)];
      final offsetX = random.nextDouble() * size.width;
      final offsetY = (animation.value + i / count) * size.height;
      final tp = TextPainter(
        text: TextSpan(text: text, style: const TextStyle(fontSize: 26)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(offsetX, offsetY % size.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
class SparklePainter extends CustomPainter {
  final Animation<double> animation;
  SparklePainter({required this.animation}) : super(repaint: animation);
  final random = Random();
  final sparkles = ['✨', '🌟', '💫'];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 15; i++) {
      final text = sparkles[random.nextInt(sparkles.length)];
      final offsetX = random.nextDouble() * size.width;
      final offsetY = (animation.value + i / 15) * size.height;
      final tp = TextPainter(
        text: TextSpan(text: text, style: const TextStyle(fontSize: 20)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(offsetX, offsetY % size.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
