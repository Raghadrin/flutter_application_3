import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizForAll extends StatefulWidget {
  const QuizForAll({super.key});

  @override
  State<QuizForAll> createState() => _QuizForAllState();
}

class _QuizForAllState extends State<QuizForAll> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> originalQuestions = [
    {"question": "3 + 2 = ?", "options": ["4", "5", "6"], "answer": "5"},
    {"question": "Which operation makes this true: 6 ☐ 2 = 12", "options": ["+", "*", "-"], "answer": "*"},
    {"question": "Complete the equation: 8 - 3 = ?", "options": ["5", "6", "4"], "answer": "5"},
    {"question": "What is the missing number: 10 = x × 2 + 0", "options": ["4", "5", "6"], "answer": "5"},
    {"question": "Reorder the steps: 2 × 3 + 4 = ?", "options": ["10", "12", "8"], "answer": "10"},
    {"question": "Which comes first: 5 + 4 × 2", "options": ["+", "*", "-"], "answer": "*"},
    {"question": "Find x: 18 = x × 3 + 3", "options": ["5", "6", "7"], "answer": "5"},
  ];

  late List<Map<String, dynamic>> questions;
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  String feedback = "";
  int score = 0;
  bool quizFinished = false;
  late ConfettiController _confettiController;
  late AnimationController _backgroundController;
  late Timer _timer;
  int remainingSeconds = 240;
  final FlutterTts tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    questions = List.from(originalQuestions)..shuffle();
    _backgroundController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _startTimer();
    _speakCurrentQuestion();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds == 0) {
        setState(() => quizFinished = true);
        _confettiController.play();
        _playCheering();
        _speak("Quiz completed!");
        _timer.cancel();
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  Future<void> _speak(String text) async {
    await tts.stop();
    await tts.speak(text);
  }

  Future<void> _speakCurrentQuestion() async {
    await _speak("Question: ${questions[currentQuestionIndex]['question']}");
  }

  Future<void> _playCheering() async {
    await _audioPlayer.play(AssetSource('audio/kids_cheering.mp3'));
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void checkAnswer(String answer) {
    if (selectedAnswer != null) return;
    final isCorrect = answer == questions[currentQuestionIndex]['answer'];
    if (isCorrect) {
      setState(() {
        selectedAnswer = answer;
        feedback = "✅ Correct!";
        score += 10;
      });
      _speak("Correct!");
    } else {
      setState(() {
        selectedAnswer = answer;
        feedback = "❌ Try Again!";
        score = max(0, score - 5);
      });
      _speak("Try again!");
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => selectedAnswer = null);
      });
    }
  }

  void nextQuestion() {
    if (selectedAnswer == questions[currentQuestionIndex]['answer']) {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          feedback = "";
        });
        _speakCurrentQuestion();
      } else {
        setState(() => quizFinished = true);
        _confettiController.play();
        _playCheering();
        _speak("Quiz completed!");
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
    _backgroundController.dispose();
    tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            CustomPaint(painter: FloatingStarsPainter(_backgroundController)),
            quizFinished
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(20)),
                          child: Text("Quiz Completed!", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 20),
                        Text("Final Score: $score", style: const TextStyle(fontSize: 32, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : buildQuizBody(question),
          ],
        ),
      ),
    );
  }

  Widget buildQuizBody(Map<String, dynamic> question) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
          child: Column(
            children: [
              Text("⏱ Time Left: ${formatTime(remainingSeconds)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text("Score: $score", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(16)),
                child: Text(
                  question['question'],
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ...question['options'].map<Widget>((option) {
                final isCorrect = selectedAnswer == question['answer'] && option == question['answer'];
                final isWrong = selectedAnswer == option && option != question['answer'];
                Color bgColor = Colors.orange.shade300;
                if (isCorrect) bgColor = Colors.green;
                if (isWrong) bgColor = Colors.red;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: selectedAnswer == null ? () => checkAnswer(option) : null,
                    child: Text(option, style: const TextStyle(fontSize: 28)),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              if (feedback.isNotEmpty)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.75), borderRadius: BorderRadius.circular(14)),
                    child: Text(
                      feedback,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: feedback.contains('✅') ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
              if (selectedAnswer == question['answer'] && !quizFinished)
                ElevatedButton(
                  onPressed: nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text("Next Question", style: TextStyle(fontSize: 24)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingStarsPainter extends CustomPainter {
  final Animation<double> animation;
  final Random _random = Random();
  FloatingStarsPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < 30; i++) {
      final dx = _random.nextDouble() * size.width;
      final dy = (animation.value + i * 0.03) % 1.0 * size.height;
      final radius = 2.0 + _random.nextDouble() * 2.0;
      paint.color = Colors.white.withOpacity(0.3 + _random.nextDouble() * 0.5);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
