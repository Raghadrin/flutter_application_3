import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DragLetterToWordGame extends StatelessWidget {
  final String letter;
  final FlutterTts tts = FlutterTts();

  DragLetterToWordGame({super.key, required this.letter});

  final List<String> words = ['Apple', 'Ball', 'Cat', 'Dog'];

  @override
  Widget build(BuildContext context) {
    String targetWord =
        words.firstWhere((w) => w.startsWith(letter), orElse: () => 'Apple');

    speakInstruction() async {
      await tts.setLanguage("en-US");
      await tts.setSpeechRate(0.5);
      await tts.speak("Drag the letter $letter to the word $targetWord");
    }

    return Scaffold(
      appBar: AppBar(title: Text("Drag Letter to Word")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(targetWord, style: TextStyle(fontSize: 36)),
          Draggable<String>(
            data: letter,
            feedback: Material(
              child: Text(letter,
                  style: TextStyle(fontSize: 30, color: Colors.blue)),
            ),
            childWhenDragging: Text("...", style: TextStyle(fontSize: 30)),
            child: Text(letter, style: TextStyle(fontSize: 30)),
          ),
          SizedBox(height: 20),
          DragTarget<String>(
            onAcceptWithDetails: (value) {
              if (value == letter) tts.speak("Good job!");
            },
            builder: (context, candidates, rejected) {
              return Container(
                height: 100,
                width: 100,
                color: Colors.orange.shade100,
                child: Center(child: Text("Drop here")),
              );
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: speakInstruction,
            child: Text("Instructions"),
          )
        ],
      ),
    );
  }
}
