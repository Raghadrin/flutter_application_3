import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ChooseWordLearningGame extends StatefulWidget {
  const ChooseWordLearningGame({super.key});

  @override
  _ChooseWordLearningGameState createState() => _ChooseWordLearningGameState();
}

class _ChooseWordLearningGameState extends State<ChooseWordLearningGame> {
  final List<Map<String, dynamic>> wordsData = [
    {
      "image": "images/apple.png",
      "word": "تفاحة",
      "audio": "sounds/tuffaha.mp3",
      "options": ["تفاحة", "تفاخة", "تفعحة"]
    },
    {
      "image": "images/banana.png",
      "word": "موزة",
      "audio": "sounds/mawza.mp3",
      "options": ["موزة", "موزى", "موز"]
    },
    {
      "image": "images/fish.png",
      "word": "سمكة",
      "audio": "sounds/samakah.mp3",
      "options": ["سمكة", "سماكة", "سماكه"]
    },
    {
      "image": "images/book.png",
      "word": "كتاب",
      "audio": "sounds/kitaab.mp3",
      "options": ["كتاب", "كتبا", "كتب"]
    },
  ];

  final AudioPlayer player = AudioPlayer();
  int currentIndex = 0;
  bool showQuiz = false;
  String? feedbackMessage;
  Color feedbackColor = Colors.transparent;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void playAudio(String file) async {
    await player.play(AssetSource(file));
  }

  void nextWord() {
    if (currentIndex < wordsData.length - 1) {
      setState(() {
        currentIndex++;
        showQuiz = false;
        feedbackMessage = null;
        feedbackColor = Colors.transparent;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("أحسنت!"),
          content: Text("أنهيت جميع الكلمات 🎉"),
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

  @override
  Widget build(BuildContext context) {
    final data = wordsData[currentIndex];
    return Scaffold(
      backgroundColor: Color(0xFFFFF7ED),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAB25F),
        title: Text("اختر الكلمة", style: TextStyle(fontFamily: 'Arial')),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "الكلمة ${currentIndex + 1} من ${wordsData.length}",
                style: TextStyle(fontSize: 20, color: Colors.deepOrange),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Image.asset(data["image"], height: 150),
                    SizedBox(height: 10),
                    Text(
                      data["word"],
                      style: TextStyle(
                          fontSize: 36,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => playAudio(data["audio"]),
                      icon: Icon(Icons.volume_up),
                      label: Text("اسمع الكلمة"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (!showQuiz)
                ElevatedButton(
                  onPressed: () => setState(() => showQuiz = true),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("ابدأ الاختبار"),
                ),
              if (showQuiz) ...[
                Text("اختر الكلمة الصحيحة:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ...data["options"].map<Widget>((opt) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: ElevatedButton(
                        onPressed: () {
                          final isCorrect = opt == data["word"];
                          setState(() {
                            feedbackMessage =
                                isCorrect ? "إجابة صحيحة ✅" : "إجابة خاطئة ❌";
                            feedbackColor =
                                isCorrect ? Colors.green : Colors.red;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(opt,
                            style:
                                TextStyle(fontSize: 20, color: Colors.black)),
                      ),
                    )),
                SizedBox(height: 10),
                if (feedbackMessage != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: feedbackColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      feedbackMessage!,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                SizedBox(height: 10),
                if (feedbackMessage != null && feedbackColor == Colors.green)
                  ElevatedButton(
                    onPressed: nextWord,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("التالي"),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
