import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LetterPuzzleGame extends StatelessWidget {
  final String letter;
  final FlutterTts tts = FlutterTts();

  LetterPuzzleGame({super.key, required this.letter});

  void _speakLetter() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.speak(letter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Letter Puzzle")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/puzzle/letter_${letter.toLowerCase()}.png"),
            ElevatedButton.icon(
              onPressed: _speakLetter,
              icon: Icon(Icons.volume_up),
              label: Text("Play Letter"),
            ),
          ],
        ),
      ),
    );
  }
}
