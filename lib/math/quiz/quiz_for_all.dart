// File: quiz_for_all.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class QuizForAll extends StatefulWidget {
  const QuizForAll({super.key});

  @override
  State<QuizForAll> createState() => _QuizForAllState();
}

class _QuizForAllState extends State<QuizForAll> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late Timer countdownTimer;

  int currentIndex = 0;
  int score = 0;
  bool finished = false;
  bool showWarning = false;
  int remainingSeconds = 180;
  String? selected;
  bool? isCorrectAnswer;
  bool showNext = false;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "What is 2 plus 1?",
      "display": "What is 2 + 1?",
      "options": ["2", "3", "4"],
      "answer": "3"
    },
    {
      "question": "What number comes after 5?",
      "display": "What number comes after 5?",
      "options": ["4", "6", "7"],
      "answer": "6"
    },
    {
      "question": "What operation makes 6 ? 2 = 12 true?",
      "display": "Which operation completes this: 6 ? 2 = 12",
      "options": ["+", "*", "-"],
      "answer": "*"
    },
    {
      "question": "What number minus 3 equals 9?",
      "display": "9 = ? - 3",
      "options": ["12", "11", "10"],
      "answer": "12"
    },
    {
      "question": "Sara had 8 pens, lost 3, bought 2 more, and then found one in her bag. How many pens does she have now?",
      "display": "Sara had 8 pens, lost 3, bought 2 more, and found 1 more. How many pens now?",
      "options": ["7", "8", "9"],
      "answer": "8"
    },
    {
      "question": "What is 3 plus 2 times 2?",
      "display": "(3 + 2) × 2 = ?",
      "options": ["10", "8", "12"],
      "answer": "10"
    },
  ];

  @override
  void initState() {
    super.initState();
    _speak("Let's start the full quiz!");
    _startCountdown();
    _readCurrentQuestion();
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds--;
        if (remainingSeconds == 30 && !showWarning) {
          showWarning = true;
          _speak("Only 30 seconds left");
        }
        if (remainingSeconds <= 0) {
          timer.cancel();
          finished = true;
          _speak("Time is up");
        }
      });
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.48);
    await flutterTts.speak(text);
  }

  void _readCurrentQuestion() {
    if (currentIndex < questions.length) {
      _speak(questions[currentIndex]['question']);
    }
  }

  void _checkAnswer(String option) {
    if (finished) return;
    final correct = questions[currentIndex]['answer'];
    setState(() {
      selected = option;
      isCorrectAnswer = (option == correct);
      showNext = true;
      if (isCorrectAnswer!) {
        score += 10;
        _speak("Correct!");
      } else {
        _speak("Try again");
      }
    });
  }

  void _next() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selected = null;
        isCorrectAnswer = null;
        showNext = false;
      });
      _readCurrentQuestion();
    } else {
      countdownTimer.cancel();
      setState(() => finished = true);
      _speak("Great job! You finished the quiz.");
    }
  }

  void _restart() {
    setState(() {
      currentIndex = 0;
      score = 0;
      selected = null;
      isCorrectAnswer = null;
      showNext = false;
      finished = false;
      remainingSeconds = 180;
      showWarning = false;
    });
    _startCountdown();
    _speak("Quiz restarted!");
    _readCurrentQuestion();
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = currentIndex < questions.length ? questions[currentIndex] : null;
    final stars = (score >= 60) ? 3 : (score >= 40) ? 2 : (score >= 20) ? 1 : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Math Final Quiz"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  "${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Center(
        child: finished
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("🎉 Quiz Complete!",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text("Score: $score / ${questions.length * 10}",
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Icon(Icons.star,
                          color: i < stars ? Colors.orange : Colors.grey, size: 36),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _restart,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                    child: const Text("🔁 Start Again",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  )
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Question ${currentIndex + 1} of ${questions.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.deepOrange, width: 2),
                      ),
                      child: Text(
                        question!['display'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    ...List.generate(question['options'].length, (i) {
                      final option = question['options'][i];
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: OutlinedButton(
                          onPressed: showNext ? null : () => _checkAnswer(option),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: const BorderSide(color: Colors.deepOrange, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 24, color: Colors.black),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    if (showWarning)
                      Text("⚠️ Less than 30 seconds left!",
                          style: TextStyle(color: Colors.red[700], fontSize: 18)),
                    if (isCorrectAnswer != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          isCorrectAnswer == true ? "✅ Correct!" : "❌ Try again",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isCorrectAnswer == true
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                      ),
                    if (showNext)
                      ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        child: const Text("Next", style: TextStyle(fontSize: 22)),
                      )
                  ],
                ),
              ),
      ),
    );
  }
}