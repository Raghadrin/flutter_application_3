import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Level3Quiz extends StatefulWidget {
  const Level3Quiz({super.key});

  @override
  State<Level3Quiz> createState() => _Level3QuizState();
}

class _Level3QuizState extends State<Level3Quiz> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool finished = false;
  bool showWarning = false;
  String? selected;
  Timer? countdownTimer;
  int remainingSeconds = 180;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': '(6 + 2) × 3 = ?',
      'spoken': 'What is the answer to: open parentheses 6 plus 2 close parentheses times 3',
      'options': ['24', '18', '30'],
      'answer': '24'
    },
    {
      'question': 'Which number completes: ? ÷ 2 = 4',
      'spoken': 'Which number divided by 2 equals 4?',
      'options': ['6', '8', '10'],
      'answer': '8'
    },
    {
      'question': 'Lina started with 5 apples, then bought 3 more, gave 2 away, and finally found 1 extra. How many apples does she have now?',
      'spoken': 'Lina had 5 apples, bought 3, gave away 2, and found 1 more. How many does she have now?',
      'options': ['6', '7', '8'],
      'answer': '7'
    },
    {
      'question': '(12 - 4) ÷ 2 = ?',
      'spoken': 'What is the result of open parentheses 12 minus 4 close parentheses divided by 2?',
      'options': ['2', '4', '6'],
      'answer': '4'
    },
    {
      'question': '7 = ? - 3\nWhat number minus 3 equals 7?',
      'spoken': 'What number minus 3 equals 7?',
      'options': ['10', '9', '8'],
      'answer': '10'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _speak("Let's start the quiz!");
    Future.delayed(const Duration(seconds: 2), () => _speakCurrent());
  }

  void _startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds--;
        if (remainingSeconds == 30 && !showWarning) {
          showWarning = true;
          _speak("Only 30 seconds left");
        }
        if (remainingSeconds <= 0) {
          timer.cancel();
          _speak("Time is up!");
          finished = true;
        }
      });
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.48);
    await flutterTts.speak(text);
  }

  void _speakCurrent() {
    final spoken = _questions[currentIndex]['spoken'] ?? _questions[currentIndex]['question'];
    _speak(spoken);
  }

  void _checkAnswer(String option) {
    if (finished) return;
    setState(() {
      selected = option;
      if (option == _questions[currentIndex]['answer']) {
        score++;
        _speak("Correct!");
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            currentIndex++;
            selected = null;
          });
          if (currentIndex >= _questions.length) {
            countdownTimer?.cancel();
            finished = true;
          } else {
            _speakCurrent();
          }
        });
      } else {
        _speak("Try again");
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      currentIndex = 0;
      score = 0;
      remainingSeconds = 180;
      showWarning = false;
      finished = false;
      selected = null;
    });
    _startTimer();
    _speak("Quiz restarted!");
    Future.delayed(const Duration(seconds: 1), () => _speakCurrent());
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = currentIndex < _questions.length ? _questions[currentIndex] : null;
    int stars = (score >= 5) ? 3 : (score >= 3) ? 2 : 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: const Text('Level 3 Quiz'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: finished
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("🎉 Quiz Finished!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text("Score: $score / ${_questions.length}", style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      stars,
                      (i) => const Icon(Icons.star, color: Colors.orange, size: 36),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _restartQuiz,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                    child: const Text("Start Again", style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ],
              )
            : Column(
                children: [
                  Text("⏱ Time Left: ${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 24, color: Colors.red)),
                  if (showWarning)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text("⚠️ Hurry up!", style: TextStyle(fontSize: 20, color: Colors.orange)),
                    ),
                  const SizedBox(height: 24),

                  // Question white box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.deepOrange, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Text(
                      question!['question'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),

                  ...List.generate(
                    question['options'].length,
                    (i) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: () => _checkAnswer(question['options'][i]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selected == question['options'][i]
                              ? Colors.orangeAccent
                              : Colors.white,
                          side: const BorderSide(color: Colors.deepOrange, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          question['options'][i],
                          style: const TextStyle(fontSize: 22, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
