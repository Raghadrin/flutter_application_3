import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MatchWordToPictureScreen extends StatefulWidget {
  const MatchWordToPictureScreen({super.key});

  @override
  _MatchWordToPictureScreenState createState() =>
      _MatchWordToPictureScreenState();
}

class _MatchWordToPictureScreenState extends State<MatchWordToPictureScreen> {
  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> questions = [
    {
      'word': 'Apple',
      'image': 'images/apple.png',
      'options': ['images/apple.png', 'images/ball.png', 'images/cat.png']
    },
    {
      'word': 'Dog',
      'image': 'images/dog.png',
      'options': ['images/dog.png', 'images/fish.png', 'images/bird.png']
    },
  ];

  int currentQuestion = 0;
  bool? isCorrect;

  @override
  void initState() {
    super.initState();
    _speakWord();
  }

  Future<void> _speakWord() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(questions[currentQuestion]['word']);
  }

  void checkAnswer(String selectedImage) {
    final correctImage = questions[currentQuestion]['image'];
    final result = selectedImage == correctImage;

    setState(() => isCorrect = result);

    tts.stop();
    tts.speak(result ? "Correct!" : "Try again!");
  }

  void nextQuestion() {
    setState(() {
      currentQuestion = (currentQuestion + 1) % questions.length;
      isCorrect = null;
    });
    _speakWord();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(title: Text("Match Word to Picture")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Tap the correct image for:", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text(
              question['word'],
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _speakWord,
              icon: Icon(Icons.volume_up),
              label: Text("Hear Word"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: question['options'].map<Widget>((imgPath) {
                  return GestureDetector(
                    onTap: () => checkAnswer(imgPath),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isCorrect == null
                              ? Colors.grey
                              : (imgPath == question['image']
                                  ? Colors.green
                                  : Colors.red),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(imgPath, fit: BoxFit.contain),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (isCorrect != null)
              ElevatedButton(
                onPressed: nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Next"),
              ),
          ],
        ),
      ),
    );
  }
}
