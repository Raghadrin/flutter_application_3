import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Level1Quiz extends StatefulWidget {
  const Level1Quiz({super.key});

  @override
  State<Level1Quiz> createState() => _Level1QuizState();
}

class _Level1QuizState extends State<Level1Quiz>
    with SingleTickerProviderStateMixin {
  final FlutterTts tts = FlutterTts();
  int currentQuestion = 0;
  int score = 0;
  int stars = 0;
  bool isCorrect = false;
  bool showNext = false;
  String? selectedAnswer;
  late Timer timer;
  int remainingSeconds = 180;
  bool warned = false;
  bool showWarning = false;

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'How many apples are in the image?',
      'image': 'images/new_images/3_apples.png',
      'options': ['2', '3', '4'],
      'answer': '3'
    },
    {
      'question': 'Which number is shown in the image?',
      'image': 'images/new_images/Number2_hand.PNG',
      'options': ['1', '2', '5'],
      'answer': '2'
    },
    {
      'question': 'Complete: 1 + _ = 4',
      'options': ['2', '3', '4'],
      'answer': '3'
    },
    {
      'question': 'Which of these is number five?',
      'image': 'images/new_images/number_shapes.png',
      'options': ['5', '2', '9'],
      'answer': '5'
    },
  ];

  @override
  void initState() {
    super.initState();
    tts.setLanguage("en-US");
    tts.setSpeechRate(0.45);
    _speak(questions[currentQuestion]['question']);
    _startTimer();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _colorAnimation =
        ColorTween(begin: Colors.black, end: Colors.red).animate(_controller);
  }

  void _speak(String text) async {
    await tts.speak(text);
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        remainingSeconds--;
        if (remainingSeconds == 30 && !warned) {
          warned = true;
          showWarning = true;
          _speak("Only 30 seconds left!");
        }
        if (remainingSeconds <= 0) {
          timer.cancel();
          _speak("Time is up");
          _showResult();
        }
      });
    });
  }

  void _checkAnswer(String selected) {
    final correct = questions[currentQuestion]['answer'];
    setState(() {
      selectedAnswer = selected;
      showNext = true;
      isCorrect = selected == correct;
      if (isCorrect) {
        score += 10;
        _speak("Correct!");
      } else {
        _speak("Try again");
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        isCorrect = false;
        showNext = false;
        selectedAnswer = null;
      });
      _speak(questions[currentQuestion]['question']);
    } else {
      timer.cancel();
      _showResult();
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
          .doc('math1')
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

  Future<void> _showResult() async {
    await _saveScore(score);
    setState(() {
      stars = (score == questions.length * 10)
          ? 3
          : (score >= (questions.length * 10 * 0.66))
              ? 2
              : (score >= (questions.length * 10 * 0.33))
                  ? 1
                  : 0;
    });

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(Icons.star,
                      color: i < stars ? Colors.orange : Colors.grey, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _restartQuiz,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child:
                    const Text("🔁 Try Again", style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restartQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      stars = 0;
      showNext = false;
      isCorrect = false;
      remainingSeconds = 180;
      warned = false;
      showWarning = false;
      selectedAnswer = null;
    });
    _speak(questions[0]['question']);
    _startTimer();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Math Level 1 Quiz"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 6),
                AnimatedBuilder(
                  animation: _colorAnimation,
                  builder: (context, child) => Text(
                    "${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: 20,
                      color: remainingSeconds <= 30
                          ? _colorAnimation.value
                          : Colors.white,
                    ),
                  ),
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
            children: [
              Text(
                'Question ${currentQuestion + 1} of ${questions.length}',
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
              if (q['image'] != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepOrange, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(q['image'], height: 160),
                  ),
                ),
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
                        style:
                            const TextStyle(fontSize: 26, color: Colors.black)),
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
