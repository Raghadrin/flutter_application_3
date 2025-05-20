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
  int remainingTime = 180;
  bool warned = false;

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
      'question': 'Which of these is number 5?',
      'image': 'images/new_images/number_shapes.png',
      'options': ['5', '2', '9'],
      'answer': '5'
    },
  ];

  @override
  void initState() {
    super.initState();
    tts.setLanguage("en-US");
    tts.setSpeechRate(0.5);
    _startTimer();
    _speak(questions[currentQuestion]['question']);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.red,
    ).animate(_controller);
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        remainingTime--;
        if (remainingTime == 30 && !warned) {
          warned = true;
          _speak("Only 30 seconds left!");
        }
        if (remainingTime == 0) {
          timer.cancel();
          _speak("Time is up");
          _showResult();
        }
      });
    });
  }

  Future<void> _saveScore(int score) async {
    try {
      // Fetch parentId and childId, adapt this to your actual method:
      String? parentId = ""; // fetch parentId from your auth or Firestore
      String? childId = ""; // fetch childId from your app logic

      // Example: fetch from Firestore assuming current user is parent
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

      // Save to Firestore: example path 'parents/{parentId}/children/{childId}/scores'
      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('math')
          .doc('math1')
          .collection('quiz1')
          .add({
        'score': score,
        //'total': _items.length,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Score saved successfully");
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  void _speak(String text) async {
    await tts.speak(text);
  }

  void _checkAnswer(String selected) {
    final correctAnswer = questions[currentQuestion]['answer'];
    setState(() {
      selectedAnswer = selected;
      if (selected == correctAnswer) {
        score++;
        isCorrect = true;
        showNext = true;
        _speak("Correct");
      } else {
        isCorrect = false;
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

  Future<void> _showResult() async {
    await _saveScore(score);
    setState(() {
      if (score == questions.length) {
        stars = 3;
      } else if (score >= questions.length - 1) {
        stars = 2;
      } else if (score >= 1) {
        stars = 1;
      } else {
        stars = 0;
      }
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Result", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Score: $score / ${questions.length}",
                style: const TextStyle(fontSize: 20)),
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
              onPressed: () {
                Navigator.pop(context);
                _restartQuiz();
              },
              child: const Text("Start Again"),
            )
          ],
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
      remainingTime = 180;
      warned = false;
      selectedAnswer = null;
    });
    _startTimer();
    _speak(questions[0]['question']);
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
    final minutes = remainingTime ~/ 60;
    final seconds = (remainingTime % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title:
            const Text("Level 1 Quiz", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFFA726),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) => Text(
                "Time left: $minutes:$seconds",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: remainingTime <= 30
                      ? _colorAnimation.value
                      : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

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

            // Question box with shadow
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
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // Options
            ...q['options'].map<Widget>((opt) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedAnswer == opt
                          ? Colors.orangeAccent
                          : Colors.white,
                      side:
                          const BorderSide(color: Colors.deepOrange, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: showNext ? null : () => _checkAnswer(opt),
                    child: Text(opt,
                        style:
                            const TextStyle(fontSize: 22, color: Colors.black)),
                  ),
                )),

            const SizedBox(height: 12),
            if (isCorrect)
              const Text("✅ Correct!",
                  style: TextStyle(fontSize: 22, color: Colors.green)),

            const SizedBox(height: 12),
            if (showNext)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: const Text("Next", style: TextStyle(fontSize: 20)),
              ),
          ],
        ),
      ),
    );
  }
}
