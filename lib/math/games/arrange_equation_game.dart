import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class ArrangeEquationGame extends StatefulWidget {
  const ArrangeEquationGame({super.key});

  @override
  State<ArrangeEquationGame> createState() => _ArrangeEquationGameState();
}

class _ArrangeEquationGameState extends State<ArrangeEquationGame> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Map<String, dynamic>> _questions = [
    {'parts': ['3', '+', '2', '=', '5'], 'answer': ['3', '+', '2', '=', '5'], 'hint': '🍎 Add 3 apples and 2 apples to get 5 apples! 🍏'},
    {'parts': ['5', '-', '2', '=', '3'], 'answer': ['5', '-', '2', '=', '3'], 'hint': '⚽ Start with 5 balls, remove 2 balls ➔ 3 balls remain 🎯'},
    {'parts': ['8', '-', '3', '=', '5'], 'answer': ['8', '-', '3', '=', '5'], 'hint': '🍉 8 watermelons minus 3 gives 5! 🍉'},
    {'parts': ['6', '+', '4', '=', '10'], 'answer': ['6', '+', '4', '=', '10'], 'hint': '🍎 6 apples plus 4 apples make 10! 🍎'},
    {'parts': ['9', '-', '2', '=', '7'], 'answer': ['9', '-', '2', '=', '7'], 'hint': '🚌 9 buses, take away 2, you have 7 left! 🚌'},
  ];

  late List<String> _targets;
  late List<String> _shuffledParts;
  int _currentIndex = 0;
  bool finished = false;
  String? feedbackMessage;
  bool showHint = false;

  late AnimationController _backgroundController;
  late AnimationController _feedbackController;
  late AnimationController _playAgainGlowController;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _playAgainGlowAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _feedbackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _feedbackAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut));
    _playAgainGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _playAgainGlowAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _playAgainGlowController, curve: Curves.easeInOut));
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _setupQuestion();
    _speakInstruction();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _feedbackController.dispose();
    _playAgainGlowController.dispose();
    _confettiController.dispose();
    flutterTts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupQuestion() {
    _targets = List.filled(_questions[_currentIndex]['parts'].length, '');
    _shuffledParts = List<String>.from(_questions[_currentIndex]['parts'])..shuffle();
  }

  Future<void> _speakInstruction() async {
    await flutterTts.speak("Arrange the following equation.");
  }

  Future<void> _playCheeringSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/kids_cheering.mp3'));
    } catch (e) {
      print("Error playing cheering sound: $e");
    }
  }

  Future<void> _checkAnswer() async {
    if (_targets.equals(_questions[_currentIndex]['answer'])) {
      setState(() => feedbackMessage = "🎯 Correct!");
      _feedbackController.forward(from: 0.0);
      await flutterTts.speak("Excellent!");
      await Future.delayed(const Duration(seconds: 2));
      setState(() => feedbackMessage = null);
      _nextQuestion();
    } else {
      setState(() => feedbackMessage = "❗ Try Again!");
      _feedbackController.forward(from: 0.0);
      await flutterTts.speak("Try again!");
      await Future.delayed(const Duration(seconds: 2));
      setState(() => feedbackMessage = null);
    }
  }

  void _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _setupQuestion();
        showHint = false;
      });
      await _speakInstruction();
    } else {
      setState(() => finished = true);
      _confettiController.play();
      await flutterTts.speak("You did very well!");
      await _playCheeringSound();
    }
  }

  void _restartGame() {
    setState(() {
      finished = false;
      _currentIndex = 0;
      _setupQuestion();
      feedbackMessage = null;
      showHint = false;
    });
    _speakInstruction();
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Arrange Equation', style: TextStyle(fontSize: 32, color: Colors.black)),
        centerTitle: true,
        leading: BackButton(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            CustomPaint(painter: BokehPainter(_backgroundController)),
            Center(
              child: finished ? _buildCelebration() : _buildGame(current),
            ),
            if (feedbackMessage != null)
              Center(
                child: ScaleTransition(
                  scale: _feedbackAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      feedbackMessage!,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: feedbackMessage!.contains("Correct") ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame(current) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
          child: const Text("Arrange the following equation", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 10,
          children: List.generate(_targets.length, (i) => DragTarget<String>(
            onAccept: (data) async {
              setState(() => _targets[i] = data);
              if (data == '+') {
                await flutterTts.setSpeechRate(0.4);
                await flutterTts.speak("plus");
              } else if (data == '-') {
                await flutterTts.setSpeechRate(0.4);
                await flutterTts.speak("minus");
              } else if (data == '=') {
                await flutterTts.setSpeechRate(0.4);
                await flutterTts.speak("equals");
              } else {
                await flutterTts.setSpeechRate(0.7);
                await flutterTts.speak(data);
              }
            },
            builder: (_, __, ___) => Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.yellow.shade100, border: Border.all(color: Colors.orangeAccent), borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(_targets[i], style: const TextStyle(fontSize: 36)),
            ),
          )),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 10,
          children: _shuffledParts.map((e) => Draggable<String>(
            data: e,
            feedback: _dragItem(e, Colors.orangeAccent),
            childWhenDragging: _dragItem(e, Colors.grey.shade300),
            child: _dragItem(e, Colors.orange),
          )).toList(),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _checkAnswer,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent.shade100, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
          child: const Text("Check Answer", style: TextStyle(fontSize: 28)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => showHint = !showHint),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade300, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
          child: Text(showHint ? "Hide Hint" : "Show Hint", style: const TextStyle(fontSize: 28)),
        ),
        if (showHint)
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
            child: Text(current['hint'], style: const TextStyle(fontSize: 28, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
          ),
      ],
    ),
  );

  Widget _buildCelebration() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, numberOfParticles: 50),
      const SizedBox(height: 40),
      Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
        child: const Text("🎉 You Did Very Well! 🎉", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
      ),
      const SizedBox(height: 30),
      ScaleTransition(
        scale: _playAgainGlowAnimation,
        child: ElevatedButton(
          onPressed: _restartGame,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)),
          child: const Text("Play Again", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ),
      ),
    ],
  );

  Widget _dragItem(String text, Color color) => Container(
    padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.all(6),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
  );
}

extension ListCompare<T> on List<T> {
  bool equals(List<T> other) {
    if (length != other.length) return false;
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
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
