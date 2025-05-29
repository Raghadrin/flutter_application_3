import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Level3Quiz extends StatefulWidget {
  const Level3Quiz({super.key});

  @override
  State<Level3Quiz> createState() => _Level3QuizState();
}

class _Level3QuizState extends State<Level3Quiz> {
  final FlutterTts flutterTts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool finished = false;
  bool showWarning = false;
  String? selected;
  bool showNext = false;
  Timer? countdownTimer;
  int remainingSeconds = 180;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': '(6 + 2) × 3 = ?',
      'spoken':
          'What is the answer to: open parentheses 6 plus 2 close parentheses times 3',
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
      'question':
          'Lina had 5 apples, bought 3, gave away 2, and found 1 more. How many does she have now?',
      'spoken':
          'Lina had 5 apples, bought 3, gave away 2, and found 1 more. How many does she have now?',
      'options': ['6', '7', '8'],
      'answer': '7'
    },
    {
      'question': '(12 - 4) ÷ 2 = ?',
      'spoken':
          'What is the result of open parentheses 12 minus 4 close parentheses divided by 2?',
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
    final spoken = _questions[currentIndex]['spoken'] ??
        _questions[currentIndex]['question'];
    _speak(spoken);
  }

  void _checkAnswer(String option) {
    if (finished) return;
    setState(() {
      selected = option;
      showNext = true;
      if (option == _questions[currentIndex]['answer']) {
        score += 10;
        _speak("Correct!");
      } else {
        _speak("Try again!");
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      currentIndex++;
      selected = null;
      showNext = false;
    });

    if (currentIndex >= _questions.length) {
      countdownTimer?.cancel();
      finished = true;
      _speak("You completed the quiz.");
      _saveScore(score);
    } else {
      _speakCurrent();
    }
  }

  Future<void> _saveScore(int score) async {
    try {
      String? parentId = ""; // fetch parentId
      String? childId = ""; // fetch childId

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }
      parentId = user.uid;

      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();
      if (childrenSnapshot.docs.isNotEmpty) {
        childId = childrenSnapshot.docs.first.id;
      } else {
        print("No children found for this parent.");
        return null;
      }

      if (parentId.isEmpty || childId == null) {
        print("Cannot save score: parentId or childId missing");
        return;
      }

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('math')
          .doc('math3')
          .collection('attempts') // optional: track multiple attempts
          .add({
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Score saved successfully");
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  void _restartQuiz() {
    setState(() {
      currentIndex = 0;
      score = 0;
      remainingSeconds = 180;
      showWarning = false;
      finished = false;
      selected = null;
      showNext = false;
    });
    _startTimer();
    _speak("Quiz restarted!");
    Future.delayed(const Duration(seconds: 1), () => _speakCurrent());
  }

  String _getStars(int score, int total) {
    double ratio = score / (total * 10);
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question =
        currentIndex < _questions.length ? _questions[currentIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Math Level 3 Quiz"),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: finished
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("🎉 Quiz Finished!",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text("Your Score: $score / ${_questions.length * 10}",
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 10),
                    Text(_getStars(score, _questions.length),
                        style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _restartQuiz,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      child: const Text("🔁 Restart",
                          style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  if (showWarning)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text("⚠️ Hurry up!",
                          style: TextStyle(fontSize: 20, color: Colors.red)),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Question ${currentIndex + 1} of ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.deepOrange, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: Text(
                      question!['question'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...List.generate(
                    question['options'].length,
                    (i) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: showNext
                            ? null
                            : () => _checkAnswer(question['options'][i]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selected == question['options'][i]
                              ? Colors.orangeAccent
                              : Colors.white,
                          side: const BorderSide(
                              color: Colors.deepOrange, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          question['options'][i],
                          style: const TextStyle(
                              fontSize: 22, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (showNext)
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber),
                      child: const Text("Next", style: TextStyle(fontSize: 22)),
                    ),
                ],
              ),
      ),
    );
  }
}
