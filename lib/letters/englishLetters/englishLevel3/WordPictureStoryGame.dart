import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WordPictureStoryGame extends StatefulWidget {
  const WordPictureStoryGame({super.key});

  @override
  _WordPictureStoryGameState createState() => _WordPictureStoryGameState();
}

class _WordPictureStoryGameState extends State<WordPictureStoryGame> {
  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> stories = [
    {
      'sentence': "Penny took her puppy for a walk.",
      'targetWord': "puppy",
      'image': 'images/dog.png',
      'question': "Who did Penny take for a walk?",
      'options': ['puppy', 'cat', 'bird'],
      'answer': 'puppy'
    },
    {
      'sentence': "The apple fell from the tree.",
      'targetWord': "apple",
      'image': 'images/apple.png',
      'question': "What fell from the tree?",
      'options': ['ball', 'apple', 'book'],
      'answer': 'apple'
    },
  ];

  int current = 0;
  String? selectedAnswer;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    _speakSentence();
  }

  Future<void> _speakSentence() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(stories[current]['sentence']);
  }

  void checkAnswer(String value) async {
    setState(() {
      selectedAnswer = value;
      showResult = true;
    });

    await tts.stop();
    if (value == stories[current]['answer']) {
      await tts.speak("Correct! Great job.");
    } else {
      await tts.speak("Try again.");
    }
  }

  void next() {
    setState(() {
      current = (current + 1) % stories.length;
      selectedAnswer = null;
      showResult = false;
    });
    _speakSentence();
  }

  @override
  Widget build(BuildContext context) {
    final story = stories[current];

    return Scaffold(
      appBar: AppBar(title: Text("Story Word Game")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset(story['image'], height: 200),
            SizedBox(height: 20),
            Text(
              story['sentence'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _speakSentence,
              icon: Icon(Icons.volume_up),
              label: Text("Listen Again"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            SizedBox(height: 30),
            Text(story['question'], style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            ...story['options'].map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAnswer == option
                        ? (option == story['answer']
                            ? Colors.green
                            : Colors.red)
                        : Colors.blue.shade100,
                  ),
                  child: Text(option),
                ),
              );
            }).toList(),
            if (showResult)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: next,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Next"),
                ),
              )
          ],
        ),
      ),
    );
  }
}
