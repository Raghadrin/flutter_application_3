import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HearLetterScreen extends StatelessWidget {
  final String letter;
  final FlutterTts tts = FlutterTts();

  HearLetterScreen({super.key, required this.letter});

  void _speak() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(letter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hear Letter")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(letter,
                style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _speak,
              icon: Icon(Icons.volume_up),
              label: Text("Say it"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}
