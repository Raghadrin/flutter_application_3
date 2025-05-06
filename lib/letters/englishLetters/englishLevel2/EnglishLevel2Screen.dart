import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/englishLetters/englishLevel2/ReorderWordLettersGame.dart';
//import 'package:flutter_application_3/letters/englishLetters/englishLevel2/ReorderWordLettersGame.dart';
import 'MatchWordToPictureScreen.dart';
//import 'ReorderWordLettersGame.dart';
import 'DragWordToSentenceGame.dart';
import 'ListenRepeatWordGame.dart';
import 'ChooseSimilarWordGame.dart';

class EnglishLevel2Screen extends StatelessWidget {
  const EnglishLevel2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("English - Level 2", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Image.asset("images/subject_fox.PNG", height: 120),
          SizedBox(height: 10),
          buildGameTile(
              context, "🖼️ Match word to picture", MatchWordToPictureScreen()),
          buildGameTile(context, "🔠 Reorder letters to form word",
              ReorderWordLettersGame()),
          buildGameTile(
              context, "🎧 Listen and repeat", ListenRepeatWordGame()),
          buildGameTile(
              context, "🧩 Drag word to sentence", DragWordToSentenceGame()),
          buildGameTile(
              context, "🔍 Choose similar word", ChooseSimilarWordGame()),
          Spacer(),
          Container(
              height: 8, width: double.infinity, color: Color(0xFFFAAE71)),
        ],
      ),
    );
  }

  Widget buildGameTile(BuildContext context, String title, Widget gameScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFED2B5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          title: Center(
              child: Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          subtitle: Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => gameScreen));
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30),
              ),
              child: Text("practice", style: TextStyle(color: Colors.black)),
            ),
          ),
        ),
      ),
    );
  }
}
