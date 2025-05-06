import 'package:flutter/material.dart';

class DragWordToImageGame extends StatefulWidget {
  const DragWordToImageGame({super.key});

  @override
  _DragWordToImageGameState createState() => _DragWordToImageGameState();
}

class _DragWordToImageGameState extends State<DragWordToImageGame> {
  final List<Map<String, dynamic>> questions = [
    {
      "image": "images/apple.png",
      "correctWord": "تفاحة",
      "options": ["تفاحة", "موزة"]
    },
    {
      "image": "images/banana.png",
      "correctWord": "موزة",
      "options": ["تفاحة", "موزة"]
    },
    {
      "image": "images/fish.png",
      "correctWord": "سمكة",
      "options": ["كرة", "سمكة"]
    },
    {
      "image": "images/book.png",
      "correctWord": "كتاب",
      "options": ["تفاحة", "كتاب"]
    },
    {
      "image": "images/ball.png",
      "correctWord": "كرة",
      "options": ["سمكة", "كرة"]
    },
  ];

  int currentIndex = 0;
  String? feedbackMessage;
  Color feedbackColor = Colors.transparent;

  void checkAnswer(String word) {
    final correct = questions[currentIndex]["correctWord"];
    setState(() {
      if (word == correct) {
        feedbackMessage = "إجابة صحيحة ✅";
        feedbackColor = Colors.green;
      } else {
        feedbackMessage = "إجابة خاطئة ❌";
        feedbackColor = Colors.red;
      }
    });

    Future.delayed(Duration(seconds: 2), () {
      if (word == correct) {
        if (currentIndex < questions.length - 1) {
          setState(() {
            currentIndex++;
            feedbackMessage = null;
            feedbackColor = Colors.transparent;
          });
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("أحسنت!"),
              content: Text("أنهيت جميع التمارين 🎉"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("إغلاق"),
                )
              ],
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: Color(0xFFFFF7ED),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAB25F),
        title: Text("اسحب الكلمة إلى الصورة",
            style: TextStyle(fontFamily: 'Arial')),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DragTarget<String>(
                builder: (context, candidateData, rejectedData) => Container(
                  height: 200,
                  width: 200,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepOrange, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(question["image"]),
                ),
                onWillAcceptWithDetails: (data) => true,
                onAcceptWithDetails: (word) {
                  checkAnswer(word as String);
                },
              ),
              SizedBox(height: 40),
              Wrap(
                spacing: 20,
                children: question["options"].map<Widget>((word) {
                  return Draggable<String>(
                    data: word,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildWordChip(word),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.4,
                      child: _buildWordChip(word),
                    ),
                    child: _buildWordChip(word),
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
              if (feedbackMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: feedbackColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedbackMessage!,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordChip(String word) {
    return Chip(
      label: Text(
        word,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.orange.shade100,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
