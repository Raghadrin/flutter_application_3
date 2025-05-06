import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MatchSentenceToPictureGame extends StatefulWidget {
  const MatchSentenceToPictureGame({super.key});

  @override
  _MatchSentenceToPictureGameState createState() =>
      _MatchSentenceToPictureGameState();
}

class _MatchSentenceToPictureGameState
    extends State<MatchSentenceToPictureGame> {
  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> questions = [
    {
      'sentence': 'The boy is eating an apple.',
      'image': 'images/boy_apple.png',
      'options': [
        'images/boy_apple.png',
        'images/girl_book.png',
        'images/dog_running.png',
      ]
    },
    {
      'sentence': 'The girl is reading a book.',
      'image': 'images/girl_book.png',
      'options': [
        'images/cat_sleeping.png',
        'images/girl_book.png',
        'images/tree.png',
      ]
    },
  ];

  int current = 0;
  String? selectedImage;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    _speakSentence();
  }

  Future<void> _speakSentence() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.setPitch(1.0);
    await tts.speak(questions[current]['sentence']);
  }

  void _checkAnswer(String imagePath) async {
    setState(() {
      selectedImage = imagePath;
      showResult = true;
    });

    await tts.speak(
        imagePath == questions[current]['image'] ? "Correct!" : "Try again!");
  }

  void _nextQuestion() {
    setState(() {
      current = (current + 1) % questions.length;
      selectedImage = null;
      showResult = false;
    });
    _speakSentence();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[current];

    return Scaffold(
      appBar: AppBar(title: Text("Match Sentence to Picture")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Listen and choose the picture that matches the sentence:",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              question['sentence'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ElevatedButton.icon(
              onPressed: _speakSentence,
              icon: Icon(Icons.volume_up),
              label: Text("Play Sentence"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: question['options'].map<Widget>((imagePath) {
                  bool isSelected = imagePath == selectedImage;
                  bool isCorrect = imagePath == question['image'];
                  Color borderColor = Colors.grey;

                  if (showResult) {
                    if (isSelected && isCorrect) {
                      borderColor = Colors.green;
                    } else if (isSelected && !isCorrect)
                      borderColor = Colors.red;
                  }

                  return GestureDetector(
                    onTap: () => _checkAnswer(imagePath),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (showResult)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Next"),
              )
          ],
        ),
      ),
    );
  }
}
