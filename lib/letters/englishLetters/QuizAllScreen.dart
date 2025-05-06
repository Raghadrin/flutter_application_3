import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class QuizAllScreen extends StatefulWidget {
  const QuizAllScreen({super.key});

  @override
  _QuizAllScreenState createState() => _QuizAllScreenState();
}

class _QuizAllScreenState extends State<QuizAllScreen> {
  final FlutterTts tts = FlutterTts();

  int currentQuestionIndex = 0;
  int score = 0;
  bool showResult = false;
  bool? isCorrect;
  bool quizFinished = false;
  String? selectedAnswer;

  late Timer timer;
  int remainingSeconds = 300; // 5 minutes

  final List<Map<String, dynamic>> questions = [
    // Level 1 - Letters
    {
      'type': 'letter',
      'question': 'Tap the letter B',
      'options': ['A', 'B', 'D'],
      'answer': 'B',
    },
    {
      'type': 'letter',
      'question': 'Tap the letter D',
      'options': ['B', 'C', 'D'],
      'answer': 'D',
    },
    {
      'type': 'letter',
      'question': 'Tap the letter A',
      'options': ['A', 'E', 'I'],
      'answer': 'A',
    },

    // Level 2 - Words
    {
      'type': 'word',
      'question': 'What word matches this picture?',
      'image': 'images/apple.png',
      'options': ['apple', 'banana', 'carrot'],
      'answer': 'apple',
    },
    {
      'type': 'word',
      'question': 'What word matches this picture?',
      'image': 'images/dog.png',
      'options': ['cat', 'dog', 'mouse'],
      'answer': 'dog',
    },

    // Level 3 - Sentences
    {
      'type': 'sentence',
      'question': 'She ___ a red ball.',
      'options': ['has', 'is', 'run'],
      'answer': 'has',
    },
    {
      'type': 'sentence',
      'question': 'They ___ to school every day.',
      'options': ['go', 'eat', 'sleep'],
      'answer': 'go',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _speakCurrentQuestion();
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (remainingSeconds == 0) {
        _endQuiz();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  Future<void> _speakCurrentQuestion() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.setPitch(1.0);
    await tts.speak(questions[currentQuestionIndex]['question']);
  }

  void checkAnswer(String selected) async {
    final correct = selected == questions[currentQuestionIndex]['answer'];
    selectedAnswer = selected;

    setState(() {
      isCorrect = correct;
      showResult = true;
      if (correct) score++;
    });

    await tts.speak(correct ? "Correct!" : "Try again!");
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        showResult = false;
        isCorrect = null;
        selectedAnswer = null;
      });
      _speakCurrentQuestion();
    } else {
      _endQuiz();
    }
  }

  void _endQuiz() {
    timer.cancel();
    setState(() {
      quizFinished = true;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (quizFinished) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz Results")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("✅ Quiz Completed!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text("Your Score: $score / ${questions.length}",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Icon(
                score >= questions.length * 0.8
                    ? Icons.emoji_events
                    : score >= questions.length * 0.5
                        ? Icons.sentiment_satisfied
                        : Icons.sentiment_dissatisfied,
                size: 60,
                color: score >= questions.length * 0.8
                    ? Colors.amber
                    : score >= questions.length * 0.5
                        ? Colors.orange
                        : Colors.red,
              ),
              Text(
                score >= questions.length * 0.8
                    ? "🏆 Excellent!"
                    : score >= questions.length * 0.5
                        ? "🙂 Good job!"
                        : "😕 Keep practicing!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Return to English"),
              )
            ],
          ),
        ),
      );
    }

    final current = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz All"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              _formatTime(remainingSeconds),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _buildQuestionWidget(current),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (question['type'] == 'word' && question['image'] != null)
            Image.asset(question['image'], height: 150),
          SizedBox(height: 20),
          Text(
            question['question'],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ...question['options'].map<Widget>((option) {
            final bool selected = showResult && option == question['answer'];
            final bool wrong =
                showResult && option == selectedAnswer && !selected;

            Color bgColor = Colors.blue.shade100;
            if (selected) bgColor = Colors.green;
            if (wrong) bgColor = Colors.red;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ElevatedButton(
                onPressed: showResult ? null : () => checkAnswer(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(option, style: TextStyle(fontSize: 18)),
              ),
            );
          }).toList(),
          SizedBox(height: 20),
          if (showResult)
            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Next"),
            ),
        ],
      ),
    );
  }
}
