import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ColorLearningAndQuizGame extends StatefulWidget {
  const ColorLearningAndQuizGame({super.key});

  @override
  _ColorLearningAndQuizGameState createState() =>
      _ColorLearningAndQuizGameState();
}

class _ColorLearningAndQuizGameState extends State<ColorLearningAndQuizGame> {
  final player = AudioPlayer();

  final List<Map<String, dynamic>> colors = [
    {"name": "أحمر", "color": Colors.red, "audio": "sounds/red.mp3"},
    {"name": "أخضر", "color": Colors.green, "audio": "sounds/green.mp3"},
    {"name": "أزرق", "color": Colors.blue, "audio": "sounds/blue.mp3"},
    {"name": "أصفر", "color": Colors.yellow, "audio": "sounds/yellow.mp3"},
    {"name": "بنفسجي", "color": Colors.purple, "audio": "sounds/purple.mp3"},
  ];

  int currentIndex = 0;
  bool inQuiz = false;
  String? feedbackMessage;
  Color feedbackColor = Colors.transparent;

  void playAudio(String path) async {
    await player.play(AssetSource(path));
  }

  void nextColor() {
    if (currentIndex < colors.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      setState(() {
        currentIndex = 0;
        inQuiz = true;
      });
    }
  }

  void checkAnswer(String selected) {
    final correct = colors[currentIndex]["name"];
    final isCorrect = selected == correct;
    setState(() {
      feedbackMessage = isCorrect ? "إجابة صحيحة ✅" : "إجابة خاطئة ❌";
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });

    if (isCorrect) {
      Future.delayed(Duration(seconds: 1), () {
        if (currentIndex < colors.length - 1) {
          setState(() {
            currentIndex++;
            feedbackMessage = null;
          });
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("أحسنت!"),
              content: Text("أنهيت جميع الألوان 🎉"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("إغلاق"))
              ],
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorData = colors[currentIndex];

    return Scaffold(
      backgroundColor: Color(0xFFFFF7ED),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title:
            Text("ألعب وتعلم الألوان", style: TextStyle(fontFamily: 'Arial')),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("اللون ${currentIndex + 1} من ${colors.length}",
                  style: TextStyle(color: Colors.orange, fontSize: 18)),
              SizedBox(height: 20),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: colorData["color"],
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              SizedBox(height: 20),
              if (!inQuiz) ...[
                Text(
                  colorData["name"],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => playAudio(colorData["audio"]),
                  icon: Icon(Icons.volume_up),
                  label: Text("استمع إلى اسم اللون"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: nextColor,
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 247, 196, 101)),
                  child: Text("التالي"),
                ),
              ] else ...[
                Text("ما اسم هذا اللون؟", style: TextStyle(fontSize: 20)),
                SizedBox(height: 10),
                ...colors.map((c) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        playAudio(c["audio"]);
                        checkAnswer(c["name"]);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100,
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 45),
                      ),
                      child: Text(c["name"], style: TextStyle(fontSize: 18)),
                    ),
                  );
                }),
                if (feedbackMessage != null) ...[
                  SizedBox(height: 15),
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
                ]
              ]
            ],
          ),
        ),
      ),
    );
  }
}
