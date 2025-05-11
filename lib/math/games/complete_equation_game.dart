import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CompleteEquationGame extends StatefulWidget {
  const CompleteEquationGame({super.key});

  @override
  State<CompleteEquationGame> createState() => _CompleteEquationGameState();
}

class _CompleteEquationGameState extends State<CompleteEquationGame> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _questions = [
    {
      'parts': [3, '+', 2, '=', 5],
      'hint': [
        {'text': 'You have three 🍊.', 'emoji': '🍊', 'count': 3},
        {'text': 'You add two more 🍊.', 'emoji': '🍊', 'count': 2},
        {'text': 'Now you have five 🍊.', 'emoji': '🍊', 'count': 5},
      ],
    },
    {
      'parts': [8, '-', 3, '=', 5],
      'hint': [
        {'text': 'You have eight 🍉.', 'emoji': '🍉', 'count': 8},
        {'text': 'You remove three 🍉.', 'emoji': '🍉', 'count': 3},
        {'text': 'Now you have five 🍉.', 'emoji': '🍉', 'count': 5},
      ],
    },
    {
      'parts': [6, '+', 4, '=', 10],
      'hint': [
        {'text': 'You have six 🍎.', 'emoji': '🍎', 'count': 6},
        {'text': 'You add four more 🍎.', 'emoji': '🍎', 'count': 4},
        {'text': 'Now you have ten 🍎.', 'emoji': '🍎', 'count': 10},
      ],
    },
    {
      'parts': [9, '-', 2, '=', 7],
      'hint': [
        {'text': 'You have nine 🚌.', 'emoji': '🚌', 'count': 9},
        {'text': 'You remove two 🚌.', 'emoji': '🚌', 'count': 2},
        {'text': 'Now you have seven 🚌.', 'emoji': '🚌', 'count': 7},
      ],
    },
  ];

  int _currentIndex = 0;
  String feedback = '';
  bool showHint = false;
  bool finished = false;
  final TextEditingController _controller = TextEditingController();
  late AnimationController _twinkleController;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardScaleAnimation;
  late AnimationController _playAgainGlowController;
  late Animation<double> _playAgainAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _cardAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut));
    _playAgainGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _playAgainAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _playAgainGlowController, curve: Curves.easeInOut));
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _speakInstruction();
  }

  @override
  void dispose() {
    _controller.dispose();
    _twinkleController.dispose();
    _cardAnimationController.dispose();
    _playAgainGlowController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakInstruction() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await flutterTts.speak("Solve the below question");
    _cardAnimationController.forward();
  }

  Future<void> _playCheeringSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/kids_cheering.mp3'));
    } catch (e) {
      print("Error playing cheering sound: $e");
    }
  }

  Future<void> _checkAnswer() async {
    final userAnswer = _controller.text.trim();
    final correctAnswer = _questions[_currentIndex]['parts'][2].toString();

    if (userAnswer == correctAnswer) {
      setState(() {
        feedback = "✅ Great Job!";
      });
      await flutterTts.speak("Excellent!");
      await Future.delayed(const Duration(milliseconds: 500));
      _nextQuestion();
    } else {
      setState(() {
        feedback = "❌ Try Again!";
      });
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
      setState(() {
        finished = true;
      });
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

  Future<void> _readFullHint(List<dynamic> hints) async {
    for (var hint in hints) {
      await flutterTts.speak(hint['text']);
      await Future.delayed(const Duration(milliseconds: 600));
    }
    await flutterTts.speak(
      "${_questions[_currentIndex]['parts'][0]} ${_questions[_currentIndex]['parts'][1]} blank ${_questions[_currentIndex]['parts'][3]} ${_questions[_currentIndex]['parts'][4]}",
    );
  }

  Widget _buildEquationBox(dynamic content) {
    return ScaleTransition(
      scale: _cardScaleAnimation,
      child: GestureDetector(
        onTap: () async {
          await flutterTts.speak(content.toString());
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.5), blurRadius: 8)],
          ),
          child: Text(
            content.toString(),
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildHintBox(List<dynamic> hints) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        children: hints.map((hint) {
          return Column(
            children: [
              Text(List.generate(hint['count'], (_) => hint['emoji']).join(), style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              Text(hint['text'], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.black87), textAlign: TextAlign.center),
            ],
          );
        }).toList(),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];
    final parts = current['parts'] as List<dynamic>;
    final hints = current['hint'] as List<dynamic>;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Complete the Equation",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFFFB347)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            CustomPaint(
              painter: BokehPainter(_twinkleController),
              child: Container(),
            ),
            Center(
              child: finished
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          numberOfParticles: 50,
                          shouldLoop: false,
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.4), blurRadius: 8)],
                          ),
                          child: const Text(
                            "🎉 You Did Very Well! 🎉",
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ScaleTransition(
                          scale: _playAgainAnimation,
                          child: ElevatedButton(
                            onPressed: _restartGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            ),
                            child: const Text("Play Again", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.5), blurRadius: 8)],
                            ),
                            child: const Text(
                              "Solve the below question",
                              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEquationBox(parts[0]),
                              _buildEquationBox(parts[1]),
                              _buildEquationBox('_'),
                              _buildEquationBox(parts[3]),
                              _buildEquationBox(parts[4]),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: TextField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 40),
                              decoration: const InputDecoration(
                                hintText: '?',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _checkAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                            ),
                            child: const Text("Check Answer", style: TextStyle(fontSize: 30)),
                          ),
                          const SizedBox(height: 20),
                          if (feedback.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                feedback,
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: feedback.startsWith('✅') ? Colors.green : Colors.redAccent,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() => showHint = !showHint);
                              if (showHint) await _readFullHint(hints);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                            ),
                            child: Text(showHint ? "Hide Hint" : "Show Hint", style: const TextStyle(fontSize: 30)),
                          ),
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
