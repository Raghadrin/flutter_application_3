import 'package:flutter/material.dart';
import 'HearLetterScreen.dart';
import 'HearLetterInWordScreen.dart';
import 'FastTapGame.dart';
import 'LetterTracingGame.dart';
import 'LetterPuzzleGame.dart';
import 'DragLetterToWordGame.dart';

class EnglishLevel1Screen extends StatelessWidget {
  final String letter;

  const EnglishLevel1Screen({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("English - Letter $letter")),
      body: Column(
        children: [
          Image.asset("images/subject_fox.PNG", height: 120),
          SizedBox(height: 10),
          buildGameTile(
              context, "🔊 Hear the letter", HearLetterScreen(letter: letter)),
          buildGameTile(context, "📢 Hear in word",
              HearLetterInWordScreen(letter: letter)),
          buildGameTile(context, "⚡ Fast Tap", FastTapGame(letter: letter)),
          buildGameTile(context, "✏️ Trace", LetterTracingGame(letter: letter)),
          buildGameTile(context, "🧩 Puzzle", LetterPuzzleGame(letter: letter)),
          buildGameTile(
              context, "🔤 Drag to word", DragLetterToWordGame(letter: letter)),
          Spacer(),
          Container(height: 8, color: Color(0xFFFAAE71)),
        ],
      ),
    );
  }

  Widget buildGameTile(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: Color(0xFFFED2B5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
              child: Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}
