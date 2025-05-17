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
  late AnimationController countdownAnimation;
  late Timer countdownTimer;

  int currentIndex = 0;
  int score = 0;
  bool finished = false;
  bool showWarning = false;
  int remainingSeconds = 180;
  String? selected;
  bool? isCorrectAnswer;

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
      "question":
          "Sara had 8 pens, lost 3, bought 2 more, and then found one in her bag. How many pens does she have now?",
      "display":
          "Sara had 8 pens, lost 3, bought 2 more, and found 1 more. How many pens now?",
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
    countdownAnimation = AnimationController(vsync: this, duration: const Duration(seconds: 180));
    countdownAnimation.forward();
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
    setState(() {
      selected = option;
      if (option == questions[currentIndex]['answer']) {
        score++;
        isCorrectAnswer = true;
        _speak("Correct!");
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            currentIndex++;
            selected = null;
            isCorrectAnswer = null;
          });
          if (currentIndex >= questions.length) {
            countdownTimer.cancel();
            finished = true;
          } else {
            _readCurrentQuestion();
          }
        });
      } else {
        isCorrectAnswer = false;
        _speak("Try again");
      }
    });
  }

  void _restart() {
    setState(() {
      currentIndex = 0;
      score = 0;
      finished = false;
      remainingSeconds = 180;
      selected = null;
      isCorrectAnswer = null;
      showWarning = false;
    });
    _startCountdown();
    _speak("Quiz restarted!");
    _readCurrentQuestion();
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    countdownAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = currentIndex < questions.length ? questions[currentIndex] : null;
    int stars = (score >= 6) ? 3 : (score >= 4) ? 2 : 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: const Text("Quiz For All"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: finished
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("🎉 Quiz Complete!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text("Your Score: $score / ${questions.length}", style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      stars,
                      (i) => const Icon(Icons.star, color: Colors.orange, size: 36),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _restart,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                    child: const Text("🔁 Start Again", style: TextStyle(fontSize: 20, color: Colors.white)),
                  )
                ],
              )
            : Column(
                children: [
                  // Timer bar
                  LinearProgressIndicator(
                    value: countdownAnimation.value,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),

                  // Timer + question count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Time Left: ${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 20, color: Colors.red)),
                      Text("Question ${currentIndex + 1} of ${questions.length}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  if (showWarning)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text("⚠️ Hurry up!", style: TextStyle(fontSize: 20, color: Colors.orange)),
                    ),
                  const SizedBox(height: 24),

                  // Question box
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8)],
                    ),
                    child: Text(
                      question!['display'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                  ),

                  // Options
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
                          style: const TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                    ),
                  ),

                  // Emoji feedback
                  if (isCorrectAnswer != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        isCorrectAnswer == true ? " Correct!" : " Try again",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isCorrectAnswer == true ? const Color.fromARGB(255, 12, 242, 20) : const Color.fromARGB(255, 250, 63, 50),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
