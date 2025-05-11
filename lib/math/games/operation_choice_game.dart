import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class OperationChoiceGame extends StatefulWidget {
  const OperationChoiceGame({super.key});

  @override
  State<OperationChoiceGame> createState() => _OperationChoiceGameState();
}

class _OperationChoiceGameState extends State<OperationChoiceGame> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _questions = [
    {
      'question': "6 ☐ 2 = 12 🍊",
      'options': ['+', '*', '-'],
      'answer': '*',
      'hint': [
        {'text': 'You have 6 oranges 🍊.'},
        {'text': 'Multiply by 2 🍊.'},
        {'text': 'Now you have 12 oranges 🍊.'},
      ],
    },
    {
      'question': "9 ☐ 3 = 3 🚌",
      'options': ['-', '*', '/'],
      'answer': '/',
      'hint': [
        {'text': 'You have 9 buses 🚌.'},
        {'text': 'Divide into 3 groups 🚌.'},
        {'text': 'Each group has 3 buses 🚌.'},
      ],
    },
    {
      'question': "5 ☐ 5 = 10 🍎",
      'options': ['+', '*', '-'],
      'answer': '+',
      'hint': [
        {'text': 'You have 5 apples 🍎.'},
        {'text': 'Add 5 apples 🍎.'},
        {'text': 'Now you have 10 apples 🍎.'},
      ],
    },
    {
      'question': "10 ☐ 2 = 5 🏀",
      'options': ['/', '*', '-'],
      'answer': '/',
      'hint': [
        {'text': 'You have 10 balls 🏀.'},
        {'text': 'Divide into 2 teams 🏀.'},
        {'text': 'Each team gets 5 balls 🏀.'},
      ],
    },
    {
      'question': "What operation fits best in this game? +, -, *, or /?",
      'options': ['+', '-', '*', '/'],
      'answer': '*',
      'hint': [
        {'text': 'This game helps you learn how to pick the right math operation!'},
      ],
    }
  ];

  int _currentIndex = 0;
  String feedback = '';
  bool showHint = false;
  bool finished = false;
  final TextEditingController _controller = TextEditingController();
  late AnimationController _twinkleController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _speakInstruction();
  }

  @override
  void dispose() {
    _controller.dispose();
    _twinkleController.dispose();
    _confettiController.dispose();
    _flutterTts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _speakInstruction() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _flutterTts.speak("Solve the below question");
  }

  Future<void> _playCheeringSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/kids_cheering.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  Future<void> _speakHint(List<dynamic> hints) async {
    for (var hint in hints) {
      await _flutterTts.speak(hint['text']);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _checkAnswer() async {
    final userAnswer = _controller.text.trim();
    final correctAnswer = _questions[_currentIndex]['answer'].toString();

    if (userAnswer == correctAnswer) {
      setState(() { feedback = "✅ Great Job!"; });
      await _flutterTts.speak("Excellent!");
      await Future.delayed(const Duration(milliseconds: 800));
      _nextQuestion();
    } else {
      setState(() { feedback = "❌ Try Again!"; });
      await _flutterTts.speak("Try again");
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
      await _flutterTts.speak("You did very well");
      await _playCheeringSound();
    }
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      feedback = '';
      finished = false;
      showHint = false;
      _controller.clear();
    });
    _speakInstruction();
  }

  Widget _buildEquationBox(String content) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.5), blurRadius: 8)],
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildFeedbackBox(String message, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHintClouds(List<dynamic> hints) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        children: hints.map<Widget>((hint) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            hint['text'],
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];
    final parts = current['question'].split(' ');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Operation Choice", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                        ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, shouldLoop: false),
                        const SizedBox(height: 30),
                        _buildFeedbackBox("🎉 You Did Very Well! 🎉", Colors.green),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _restartGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          ),
                          child: const Text("Play Again", style: TextStyle(fontSize: 30)),
                        )
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Solve the below question", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: parts.map<Widget>((p) => _buildEquationBox(p)).toList(),
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
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 40),
                              decoration: const InputDecoration(hintText: '?', border: InputBorder.none),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _checkAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            ),
                            child: const Text("Check Answer", style: TextStyle(fontSize: 30)),
                          ),
                          if (feedback.isNotEmpty) _buildFeedbackBox(feedback, feedback.startsWith('✅') ? Colors.green : Colors.redAccent),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() => showHint = !showHint);
                              if (showHint) {
                                await _speakHint(current['hint']);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            ),
                            child: Text(showHint ? "Hide Hint" : "Show Hint", style: const TextStyle(fontSize: 30)),
                          ),
                          if (showHint) _buildHintClouds(current['hint']),
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
