import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ListenRepeatSentenceGame extends StatefulWidget {
  const ListenRepeatSentenceGame({super.key});

  @override
  _ListenRepeatSentenceGameState createState() =>
      _ListenRepeatSentenceGameState();
}

class _ListenRepeatSentenceGameState extends State<ListenRepeatSentenceGame> {
  final FlutterTts tts = FlutterTts();

  final List<String> sentences = [
    "I like to play outside.",
    "The sun is very bright today.",
    "She has a yellow balloon.",
  ];

  int currentIndex = 0;
  bool showNext = false;

  @override
  void initState() {
    super.initState();
    _speakSentence();
  }

  Future<void> _speakSentence() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.setPitch(1.0);
    await tts.speak(sentences[currentIndex]);
  }

  void _nextSentence() {
    setState(() {
      currentIndex = (currentIndex + 1) % sentences.length;
      showNext = false;
    });
    _speakSentence();
  }

  @override
  Widget build(BuildContext context) {
    String sentence = sentences[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Listen and Repeat")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Step 1: Listen to the sentence",
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text(
              sentence,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            ElevatedButton.icon(
              onPressed: _speakSentence,
              icon: Icon(Icons.volume_up),
              label: Text("Play Sentence"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent),
            ),
            SizedBox(height: 30),
            Text("Step 2: Say the sentence out loud",
                style: TextStyle(fontSize: 20)),
            Icon(Icons.record_voice_over_rounded,
                size: 60, color: Colors.blue.shade300),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => showNext = true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("I'm Done"),
            ),
            if (showNext)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _nextSentence,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                  child: Text("Next Sentence"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
