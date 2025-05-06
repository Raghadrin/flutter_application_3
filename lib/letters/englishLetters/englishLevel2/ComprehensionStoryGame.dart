import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ComprehensionStoryGame extends StatefulWidget {
  const ComprehensionStoryGame({super.key});

  @override
  _ComprehensionStoryGameState createState() => _ComprehensionStoryGameState();
}

class _ComprehensionStoryGameState extends State<ComprehensionStoryGame> {
  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> stories = [
    {
      'text':
          'Peter found a small puppy in the park. He decided to take it home.',
      'image': 'images/peter_puppy.png',
      'question': 'What did Peter find?',
      'options': ['a kitten', 'a puppy', 'a ball'],
      'answer': 'a puppy',
    },
    {
      'text': 'Lily saw a rainbow after the rain. She was very happy.',
      'image': 'images/lily_rainbow.png',
      'question': 'What did Lily see?',
      'options': ['a rainbow', 'a bird', 'a cloud'],
      'answer': 'a rainbow',
    },
  ];

  int current = 0;
  String? selectedAnswer;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    _speakStory();
  }

  Future<void> _speakStory() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.setPitch(1.0);
    await tts.speak(stories[current]['text']);
  }

  void checkAnswer(String answer) async {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
    });

    await tts.speak(
      answer == stories[current]['answer'] ? "Correct!" : "Try again!",
    );
  }

  void nextStory() {
    setState(() {
      current = (current + 1) % stories.length;
      selectedAnswer = null;
      showResult = false;
    });
    _speakStory();
  }

  @override
  Widget build(BuildContext context) {
    final story = stories[current];

    return Scaffold(
      appBar: AppBar(title: Text("Story Comprehension")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset(story['image'], height: 200),
            SizedBox(height: 20),
            Text(
              story['text'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            ElevatedButton.icon(
              onPressed: _speakStory,
              icon: Icon(Icons.volume_up),
              label: Text("Listen to Story"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent),
            ),
            SizedBox(height: 30),
            Text(story['question'], style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            ...story['options'].map<Widget>((option) {
              bool isCorrect = option == story['answer'];
              bool isSelected = selectedAnswer == option;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: showResult ? null : () => checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showResult
                        ? (isSelected
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.blue.shade100)
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
                  onPressed: nextStory,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Next Story"),
                ),
              )
          ],
        ),
      ),
    );
  }
}
