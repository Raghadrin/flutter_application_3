// ملف: choose_similar_word_game.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChooseSimilarWordGame extends StatefulWidget {
  const ChooseSimilarWordGame({super.key});

  @override
  _ChooseSimilarWordGameState createState() => _ChooseSimilarWordGameState();
}

class _ChooseSimilarWordGameState extends State<ChooseSimilarWordGame> {
  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> questions = [
    {
      'target': 'cat',
      'options': ['cut', 'cat', 'cot'],
    },
    {
      'target': 'bed',
      'options': ['bad', 'bud', 'bed'],
    },
    {
      'target': 'pen',
      'options': ['pin', 'pen', 'pan'],
    },
  ];

  int current = 0;
  String? selected;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    _speakWord();
  }

  Future<void> _speakWord() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.setPitch(1.0);
    await tts.speak(questions[current]['target']);
  }

  void checkAnswer(String value) async {
    setState(() {
      selected = value;
      showResult = true;
    });

    if (value == questions[current]['target']) {
      await tts.speak("Correct!");
    } else {
      await tts.speak("Try again.");
    }
  }

  void nextQuestion() {
    setState(() {
      current = (current + 1) % questions.length;
      selected = null;
      showResult = false;
    });
    _speakWord();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[current];

    return Scaffold(
      appBar: AppBar(title: Text("Choose the Correct Word")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Listen and choose the correct word",
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _speakWord,
              icon: Icon(Icons.volume_up),
              label: Text("Play Word"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent),
            ),
            SizedBox(height: 30),
            ...question['options'].map<Widget>((option) {
              bool isCorrect = option == question['target'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: showResult ? null : () => checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showResult
                        ? (option == selected
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.blue.shade100)
                        : Colors.blue.shade100,
                  ),
                  child: Text(option, style: TextStyle(fontSize: 18)),
                ),
              );
            }).toList(),
            if (showResult)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: nextQuestion,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Next"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
