import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ListenRepeatWordGame extends StatefulWidget {
  const ListenRepeatWordGame({super.key});

  @override
  _ListenRepeatWordGameState createState() => _ListenRepeatWordGameState();
}

class _ListenRepeatWordGameState extends State<ListenRepeatWordGame> {
  final FlutterTts tts = FlutterTts();

  final List<String> words = ['Apple', 'Ball', 'Dog', 'Cat'];
  int currentWordIndex = 0;
  bool showPrompt = false;

  @override
  void initState() {
    super.initState();
    _speakCurrentWord();
  }

  Future<void> _speakCurrentWord() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.setPitch(1.0);
    await tts.speak(words[currentWordIndex]);
  }

  void _nextWord() {
    setState(() {
      currentWordIndex = (currentWordIndex + 1) % words.length;
      showPrompt = false;
    });
    _speakCurrentWord();
  }

  @override
  Widget build(BuildContext context) {
    String word = words[currentWordIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Listen and Repeat")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Step 1: Listen to the word", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text(word,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _speakCurrentWord,
              icon: Icon(Icons.volume_up),
              label: Text("Play Word"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent),
            ),
            SizedBox(height: 30),
            Text("Step 2: Say the word out loud",
                style: TextStyle(fontSize: 20)),
            Icon(Icons.record_voice_over_rounded,
                size: 60, color: Colors.blue.shade300),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() => showPrompt = true);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400),
              child: Text("I'm Done"),
            ),
            if (showPrompt)
              Column(
                children: [
                  SizedBox(height: 20),
                  Text("✅ Great job! Now let's try another word.",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _nextWord,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                    child: Text("Next Word"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
