import 'package:flutter/material.dart';
import '../englishLevel2/ReorderSentenceGame.dart';
import '../englishLevel2/MatchSentenceToPictureGame.dart';
import '../englishLevel2/ListenRepeatSentenceGame.dart';
import '../englishLevel2/ChooseMissingWordGame.dart';
import '../englishLevel2/ComprehensionStoryGame.dart';

class EnglishLevel3Screen extends StatelessWidget {
  const EnglishLevel3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("English - Level 3", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Image.asset("images/subject_fox.PNG", height: 120),
          SizedBox(height: 10),
          buildGameTile(context, "🔁 Reorder sentence", ReorderSentenceGame()),
          buildGameTile(context, "📷 Match sentence to picture",
              MatchSentenceToPictureGame()),
          buildGameTile(context, "🎧 Listen and repeat sentence",
              ListenRepeatSentenceGame()),
          buildGameTile(
              context, "❓ Choose missing word", ChooseMissingWordGame()),
          buildGameTile(
              context, "📖 Story + Questions", ComprehensionStoryGame()),
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
              child: Text("تمرين", style: TextStyle(color: Colors.black)),
            ),
          ),
        ),
      ),
    );
  }
}
