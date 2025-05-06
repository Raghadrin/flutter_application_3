import 'package:flutter/material.dart';
import 'dart:async';

class QuizAllScreen extends StatefulWidget {
  const QuizAllScreen({super.key});

  @override
  _QuizAllScreenState createState() => _QuizAllScreenState();
}

class _QuizAllScreenState extends State<QuizAllScreen> {
  int currentQuestion = 0;
  int score = 0;
  int timeLeft = 60;
  Timer? timer;
  bool showFeedback = false;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;

  final List<Map<String, dynamic>> questions = [
    {
      "type": "choose_word",
      "image": "images/apple.png",
      "sound": "sounds/tuffaha.mp3",
      "word": "تفاحة",
      "options": ["تفاحة", "تفاخة", "تفعحة"]
    },
    {
      "type": "drag_to_image",
      "image": "images/apple.png",
      "word": "تفاحة",
      "options": ["موزة", "تفاحة", "برتقالة"]
    },
    {
      "type": "choose_image",
      "word": "تفاحة",
      "options": [
        {"image": "images/apple.png", "label": "تفاحة"},
        {"image": "images/banana.png", "label": "موزة"}
      ],
      "correct": "تفاحة"
    },
    {
      "type": "color_match",
      "color": Colors.red,
      "correct": "أحمر",
      "options": ["أصفر", "أحمر", "أزرق"]
    }
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timeLeft = 60;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        t.cancel();
        showFinalScore();
      }
    });
  }

  void showFinalScore() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        title: Text("النتيجة النهائية", textAlign: TextAlign.center),
        content: Text("لقد حصلت على $score نقطة", textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: Text("العودة لشاشة المادة"),
          )
        ],
      ),
    );
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        showFeedback = false;
      });
    } else {
      timer?.cancel();
      showFinalScore();
    }
  }

  void checkAnswer(bool correct) {
    setState(() {
      if (correct) {
        score += 1;
        feedbackMessage = "أحسنت!";
        feedbackColor = Colors.green;
      } else {
        feedbackMessage = "حاول مرة أخرى";
        feedbackColor = Colors.red;
      }
      showFeedback = true;
    });
    if (correct) {
      Future.delayed(Duration(seconds: 1), nextQuestion);
    }
  }

  Widget buildChooseWord(Map<String, dynamic> q) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepOrange, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(q["image"], height: 150),
        ),
        SizedBox(height: 20),
        Text("اختر الكلمة الصحيحة", style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        ...q["options"].map<Widget>((opt) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ElevatedButton(
                onPressed: () => checkAnswer(opt == q["word"]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(opt),
              ),
            )),
      ],
    );
  }

  Widget buildChooseImage(Map<String, dynamic> q) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("اختر الصورة التي تمثل الكلمة: ${q["word"]}",
            style: TextStyle(fontSize: 20)),
        SizedBox(height: 15),
        Wrap(
          spacing: 20,
          alignment: WrapAlignment.center,
          children: q["options"].map<Widget>((option) {
            return GestureDetector(
              onTap: () => checkAnswer(option["label"] == q["correct"]),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Image.asset(option["image"], height: 100),
                  ),
                  SizedBox(height: 5),
                  Text(option["label"]),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget buildDragToImage(Map<String, dynamic> q) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("اسحب الكلمة إلى الصورة", style: TextStyle(fontSize: 20)),
        SizedBox(height: 20),
        DragTarget<String>(
          builder: (context, candidateData, rejectedData) => Container(
            height: 180,
            width: 180,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepOrange, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(q["image"]),
          ),
          onWillAcceptWithDetails: (data) => true,
          onAcceptWithDetails: (word) {
            checkAnswer(word == q["word"]);
          },
        ),
        SizedBox(height: 30),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          children: q["options"].map<Widget>((word) {
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
      ],
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

  Widget buildColorMatch(Map<String, dynamic> q) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("ما اسم هذا اللون؟", style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: q["color"],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        ...q["options"].map<Widget>((opt) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ElevatedButton(
                onPressed: () => checkAnswer(opt == q["correct"]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(opt),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = questions[currentQuestion];

    Widget content;
    switch (current["type"]) {
      case "choose_word":
        content = buildChooseWord(current);
        break;
      case "drag_to_image":
        content = buildDragToImage(current);
        break;
      case "choose_image":
        content = buildChooseImage(current);
        break;
      case "color_match":
        content = buildColorMatch(current);
        break;
      default:
        content = Center(child: Text("نوع غير معروف"));
    }

    return Scaffold(
      backgroundColor: Color(0xFFFFF7ED),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAB25F),
        title: Text("الاختبار الشامل", style: TextStyle(fontFamily: 'Arial')),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("السؤال ${currentQuestion + 1} من ${questions.length}",
                style: TextStyle(fontSize: 20, color: Colors.deepOrange)),
            Text("الوقت المتبقي: $timeLeft ثانية",
                style: TextStyle(fontSize: 16, color: Colors.red)),
            SizedBox(height: 20),
            Expanded(child: Center(child: content)),
            if (showFeedback)
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feedbackColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  feedbackMessage,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
