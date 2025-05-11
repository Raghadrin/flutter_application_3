import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class ReverseEquationGame extends StatefulWidget {
  const ReverseEquationGame({super.key});

  @override
  State<ReverseEquationGame> createState() => _ReverseEquationGameState();
}

class _ReverseEquationGameState extends State<ReverseEquationGame> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _questions = [
    {"equation": "18 = x × 3 + 3", "answer": 5, "hints": ["Subtract 3 from 18", "Then divide by 3"]},
    {"equation": "24 = 2 × x + 4", "answer": 10, "hints": ["Subtract 4 from 24", "Then divide by 2"]},
    {"equation": "50 = x × 5 + 10", "answer": 8, "hints": ["Subtract 10 from 50", "Then divide by 5"]},
    {"equation": "40 = 4 × x + 4", "answer": 9, "hints": ["Subtract 4 from 40", "Then divide by 4"]},
    {"equation": "33 = 3 × x + 3", "answer": 10, "hints": ["Subtract 3 from 33", "Then divide by 3"]},
  ];

  int _currentIndex = 0;
  bool showHint = false;
  bool finished = false;
  String feedback = '';
  final TextEditingController _controller = TextEditingController();

  late AnimationController _backgroundController;
  late ConfettiController _confettiController;
  late AnimationController _playAgainGlowController;
  late Animation<double> _playAgainAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _playAgainGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _playAgainAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _playAgainGlowController, curve: Curves.easeInOut));
    _speakQuestion(_questions[_currentIndex]['equation']);
  }

  @override
  void dispose() {
    _controller.dispose();
    _backgroundController.dispose();
    _confettiController.dispose();
    _playAgainGlowController.dispose();
    flutterTts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _speakQuestion(String equation) async {
    await flutterTts.speak("Solve the equation: $equation");
  }

  Future<void> _speakHint(String hint) async {
    await flutterTts.speak(hint);
  }

  Future<void> _playCheering() async {
    await _audioPlayer.play(AssetSource('kids_cheering.mp3'));
  }

  Future<void> _checkAnswer() async {
    if (_controller.text.trim() == _questions[_currentIndex]['answer'].toString()) {
      setState(() => feedback = "✅ Correct!");
      await flutterTts.speak("Excellent!");
      await Future.delayed(const Duration(milliseconds: 500));
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
        showHint = false;
        feedback = '';
        _controller.clear();
      });
      await _speakQuestion(_questions[_currentIndex]['equation']);
    } else {
      setState(() => finished = true);
      _confettiController.play();
      await _playCheering();
      await flutterTts.speak("You did very well!");
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _restartGame() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reverse Equation Game",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFE0B2), Color(0xFFFFB347)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            CustomPaint(
              painter: SpiralPainter(_backgroundController),
              child: Container(),
            ),
            if (finished)
              Center(child: _finishScreen())
            else
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
                      child: const Text("Solve the following equation", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                      child: Text(current['equation'], style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
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
                      child: const Text("Check", style: TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(height: 20),
                    if (feedback.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(18)),
                        child: Text(feedback, style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: feedback.startsWith('✅') ? Colors.green : Colors.redAccent), textAlign: TextAlign.center),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => showHint = !showHint);
                        if (showHint) {
                          for (var hint in current['hints']) {
                            _speakHint(hint);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade200, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18)),
                      child: Text(showHint ? "Hide Hints" : "Show Hints", style: const TextStyle(fontSize: 30)),
                    ),
                    if (showHint)
                      ...List.generate(
                        (current['hints'] as List<String>).length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
                          child: Text(current['hints'][index], style: const TextStyle(fontSize: 26), textAlign: TextAlign.center),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _finishScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive),
        Container(
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
          child: const Text("🎉 You Did Very Well! 🎉", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 20),
        ScaleTransition(
          scale: _playAgainAnimation,
          child: ElevatedButton(
            onPressed: _restartGame,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)),
            child: const Text("Play Again", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class SpiralPainter extends CustomPainter {
  final Animation<double> animation;
  SpiralPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1.5;
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
