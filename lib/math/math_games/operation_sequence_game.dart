import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class OperationSequenceGame extends StatefulWidget {
  const OperationSequenceGame({super.key});

  @override
  State<OperationSequenceGame> createState() => _OperationSequenceGameState();
}

class _OperationSequenceGameState extends State<OperationSequenceGame> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _questions = [
    {"expression": ["2", "+", "3", "*", "2"], "answer": 8, "hint": ["Multiply 3 and 2 first", "Then add 2"]},
    {"expression": ["10", "-", "4", "/", "2"], "answer": 8, "hint": ["Divide 4 by 2 first", "Then subtract from 10"]},
    {"expression": ["6", "/", "3", "+", "5"], "answer": 7, "hint": ["Divide 6 by 3 first", "Then add 5"]},
    {"expression": ["2", "+", "2", "*", "3"], "answer": 8, "hint": ["Multiply 2 and 3 first", "Then add 2"]},
    {"expression": ["8", "/", "2", "+", "6"], "answer": 10, "hint": ["Divide 8 by 2 first", "Then add 6"]},
    {"expression": ["15", "-", "3", "*", "4"], "answer": 3, "hint": ["Multiply 3 and 4 first", "Then subtract from 15"]},
  ];

  int _currentIndex = 0;
  String feedback = '';
  bool showHint = false;
  bool finished = false;
  final TextEditingController _controller = TextEditingController();

  late AnimationController _twinkleController;
  late AnimationController _cardController;
  late Animation<double> _cardScale;
  late AnimationController _playAgainController;
  late Animation<double> _playAgainScale;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _cardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _cardScale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _cardController, curve: Curves.elasticOut));
    _playAgainController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _playAgainScale = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _playAgainController, curve: Curves.easeInOut));
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _speakInstruction();
  }

  @override
  void dispose() {
    _controller.dispose();
    _twinkleController.dispose();
    _cardController.dispose();
    _playAgainController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakInstruction() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await flutterTts.speak("Solve the below question");
    _cardController.forward();
  }

  Future<void> _playCheeringSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/kids_cheering.mp3'));
    } catch (e) {
      print("Error playing cheering sound: $e");
    }
  }

  Future<void> _checkAnswer() async {
    final userAnswer = int.tryParse(_controller.text.trim());
    final correct = _questions[_currentIndex]['answer'];

    if (userAnswer == correct) {
      setState(() => feedback = "✅ Great Job!");
      await flutterTts.speak("Excellent");
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
        feedback = '';
        _controller.clear();
        showHint = false;
      });
      await _speakInstruction();
    } else {
      setState(() => finished = true);
      _confettiController.play();
      await flutterTts.speak("You did very well");
      await _playCheeringSound();
    }
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      feedback = '';
      showHint = false;
      finished = false;
      _controller.clear();
    });
    _speakInstruction();
  }

  Future<void> _readHints(List<dynamic> hints) async {
    for (var hint in hints) {
      await flutterTts.speak(hint);
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  Widget _buildEquationBox(String content) {
    return ScaleTransition(
      scale: _cardScale,
      child: GestureDetector(
        onTap: () async => await flutterTts.speak(content.replaceAll("*", "times").replaceAll("/", "divided by").replaceAll("+", "plus").replaceAll("-", "minus")),
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.5), blurRadius: 8)]),
          child: Text(content, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      ),
    );
  }

  Widget _buildHintBox(List<dynamic> hints) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
      child: Column(
        children: hints.map((hint) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(hint, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.black87), textAlign: TextAlign.center),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];
    final parts = current['expression'] as List<dynamic>;
    final hints = current['hint'] as List<dynamic>;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Operation Sequence", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFE0B2), Color(0xFFFFB347)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            CustomPaint(painter: BokehPainter(_twinkleController), child: Container()),
            Center(
              child: finished
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, numberOfParticles: 50),
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
                          child: const Text("🎉 You Did Very Well! 🎉", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 30),
                        ScaleTransition(
                          scale: _playAgainScale,
                          child: ElevatedButton(
                            onPressed: _restartGame,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                            child: const Text("Play Again", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
                            child: const Text("Solve the below question", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                          ),
                          const SizedBox(height: 30),
                          Wrap(alignment: WrapAlignment.center, children: parts.map((e) => _buildEquationBox(e)).toList()),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(18)),
                            child: TextField(controller: _controller, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 40), decoration: const InputDecoration(hintText: '?', border: InputBorder.none)),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(onPressed: _checkAnswer, style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text("Check Answer", style: TextStyle(fontSize: 30))),
                          const SizedBox(height: 20),
                          if (feedback.isNotEmpty) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.75), borderRadius: BorderRadius.circular(18)), child: Text(feedback, style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: feedback.startsWith('✅') ? Colors.green : Colors.redAccent), textAlign: TextAlign.center)),
                          const SizedBox(height: 30),
                          ElevatedButton(onPressed: () async { setState(() => showHint = !showHint); if (showHint) await _readHints(hints); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text(showHint ? "Hide Hint" : "Show Hint", style: const TextStyle(fontSize: 30))),
                          if (showHint) _buildHintBox(hints),
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
  BokehPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = Random();
    for (int i = 0; i < 25; i++) {
      final opacity = 0.5 + 0.5 * sin(animation.value * 2 * pi + i);
      paint.color = Colors.white.withOpacity(opacity);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BokehPainter oldDelegate) => true;
}
