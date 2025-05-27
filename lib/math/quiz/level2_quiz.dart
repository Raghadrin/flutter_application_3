import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Level2QuizScreen extends StatefulWidget {
  const Level2QuizScreen({super.key});

  @override
  State<Level2QuizScreen> createState() => _Level2QuizScreenState();
}

class _Level2QuizScreenState extends State<Level2QuizScreen> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool isCorrect = false;
  bool showNext = false;
  Timer? timer;
  int remainingSeconds = 180;
  bool showWarning = false;

  final List<Map<String, dynamic>> questions = [
    {
      'type': 'compare',
      'question': 'Which side has more apples?',
      'imageLeft': 'images/new_images/3_apples.png',
      'imageRight': 'images/new_images/4_apples.png',
      'options': ['Left', 'Right'],
      'answer': 'Right'
    },
    {
      'type': 'operator',
      'question': 'What completes this: 7 __ 2 = 14?',
      'options': ['+', '-', '×', '÷'],
      'answer': '×'
    },
    {
      'type': 'equation',
      'question': 'Solve: (6 + 4) × 2 = ?',
      'options': ['14', '20', '12'],
      'answer': '20'
    },
    {
      'type': 'word',
      'question': 'Liam had 4 candies, then got 3 more and gave 2 away. How many now?',
      'options': ['5', '4', '6'],
      'answer': '5'
    },
    {
      'type': 'operator',
      'question': 'What completes this: 9 __ 3 = 3?',
      'options': ['+', '-', '×', '÷'],
      'answer': '÷'
    },
  ];

  @override
  void initState() {
    super.initState();
    _speak(questions[currentIndex]['question']);
    startTimer();
  }

  void _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
          if (remainingSeconds == 30 && !showWarning) {
            showWarning = true;
            _speak("Only 30 seconds left. Try your best!");
          }
        });
      } else {
        timer?.cancel();
        _speak("Time is up. You did your best!");
        _showFinalDialog();
      }
    });
  }

  void _checkAnswer(String selected) {
    final correct = questions[currentIndex]['answer'];
    setState(() {
      isCorrect = (selected == correct);
      showNext = true;
      if (isCorrect) {
        score += 10;
        _speak("Correct!");
      } else {
        _speak("Try again!");
      }
    });
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = false;
        showNext = false;
      });
      _speak(questions[currentIndex]['question']);
    } else {
      timer?.cancel();
      _speak("Great job! You finished the quiz.");
      _showFinalDialog();
    }
  }

  Future<void> _saveScore(int score) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final parentId = user.uid;

      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();
      if (childrenSnapshot.docs.isEmpty) return;

      final childId = childrenSnapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('math')
          .doc('math2')
          .collection('quiz2')
          .add({
        'score': score,
        'total': questions.length * 10,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  String _getStars(int score, int total) {
    double ratio = score / (total * 10);
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }

  Future<void> _showFinalDialog() async {
    await _saveScore(score);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎉 Quiz Complete!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text("Your Score: $score / ${questions.length * 10}",
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 12),
              Text(_getStars(score, questions.length),
                  style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _resetQuiz,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("🔁 Play Again", style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      currentIndex = 0;
      score = 0;
      isCorrect = false;
      showNext = false;
      remainingSeconds = 180;
      showWarning = false;
    });
    _speak(questions[0]['question']);
    startTimer();
    Navigator.pop(context);
  }

  Widget _buildImage(String path,
      {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepOrange, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Image.asset(path, height: 100),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Math Level 2 Quiz"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  "${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  q['question'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w600),
                ),
              ),
              if (q['type'] == 'compare')
                Row(
                  children: [
                    Expanded(
                      child: _buildImage(q['imageLeft'],
                          label: "Left", onTap: () => _checkAnswer("Left")),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImage(q['imageRight'],
                          label: "Right", onTap: () => _checkAnswer("Right")),
                    ),
                  ],
                ),
              if (q['type'] != 'compare')
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: (q['options'] as List<String>).map((option) {
                    return ElevatedButton(
                      onPressed: showNext ? null : () => _checkAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCorrect && option == q['answer']
                            ? Colors.green
                            : Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(option,
                          style: const TextStyle(fontSize: 26)),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 30),
              if (showWarning)
                Text("⚠️ Hurry up! Less than 30 seconds left!",
                    style: TextStyle(color: Colors.red[700], fontSize: 18)),
              if (showNext)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text("Next", style: TextStyle(fontSize: 22)),
                )
            ],
          ),
        ),
      ),
    );
  }
}
