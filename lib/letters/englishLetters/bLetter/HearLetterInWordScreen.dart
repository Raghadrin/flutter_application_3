import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HearLetterInWordScreen extends StatelessWidget {
  final String letter;
  final FlutterTts tts = FlutterTts();

  HearLetterInWordScreen({super.key, required this.letter});

  final Map<String, String> letterWords = {
    'A': 'Apple',
    'B': 'Ball',
    'C': 'Cat',
    'D': 'Dog',
    // Add more mappings as needed
  };

  void _speakWord(String word) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(word);
  }

  @override
  Widget build(BuildContext context) {
    final word = letterWords[letter.toUpperCase()] ?? 'Word';

    return Scaffold(
      appBar: AppBar(title: Text("Hear in Word")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(word,
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _speakWord(word),
              icon: Icon(Icons.volume_up),
              label: Text("Say word"),
            ),
          ],
        ),
      ),
    );
  }
}
