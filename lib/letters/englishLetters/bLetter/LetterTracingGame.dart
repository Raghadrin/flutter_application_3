import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LetterTracingGame extends StatelessWidget {
  final String letter;
  final FlutterTts tts = FlutterTts();

  LetterTracingGame({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    speak() async {
      await tts.setLanguage("en-US");
      await tts.setSpeechRate(0.5);
      await tts.speak("Trace the letter $letter");
    }

    return Scaffold(
      appBar: AppBar(title: Text("Trace the Letter")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(letter,
              style: TextStyle(fontSize: 120, color: Colors.grey.shade400)),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: speak,
            icon: Icon(Icons.volume_up),
            label: Text("Guide me"),
          ),
          SizedBox(height: 10),
          Text("Drawing pad coming here...", style: TextStyle(fontSize: 18))
        ],
      ),
    );
  }
}
