import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FastTapGame extends StatefulWidget {
  final String letter;
  const FastTapGame({super.key, required this.letter});

  @override
  _FastTapGameState createState() => _FastTapGameState();
}

class _FastTapGameState extends State<FastTapGame> {
  final FlutterTts tts = FlutterTts();
  List<String> letters = [];

  @override
  void initState() {
    super.initState();
    _initLetters();
    _sayLetter();
  }

  void _initLetters() {
    letters = List.generate(5, (index) => String.fromCharCode(65 + index));
    if (!letters.contains(widget.letter)) letters[0] = widget.letter;
    letters.shuffle();
  }

  void _sayLetter() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.speak(widget.letter);
  }

  void _handleTap(String selected) {
    if (selected == widget.letter) {
      tts.speak("Great!");
    } else {
      tts.speak("Try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fast Tap - ${widget.letter}")),
      body: Column(
        children: [
          ElevatedButton(onPressed: _sayLetter, child: Text("Repeat Letter")),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: letters.map((l) {
                return GestureDetector(
                  onTap: () => _handleTap(l),
                  child: Card(
                    child:
                        Center(child: Text(l, style: TextStyle(fontSize: 40))),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
