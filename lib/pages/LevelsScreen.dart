import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/arabicLetter/levelOne/game1_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/bLetter/b_letters.dart';
import 'package:flutter_application_3/letters/mathmatics/game.dart';

class LevelsScreen extends StatelessWidget {
  final String subject;
  const LevelsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    // Define levels based on the subject
    List<Map<String, dynamic>> levels = _getLevelsForSubject(subject);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            subject,
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("images/subject_fox.jpg", height: 150),
          SizedBox(height: 20),
          ...levels.map((level) =>
              _buildLevelOption(context, level['title'], level['screen'])),
          Spacer(),
          Container(
              height: 8, width: double.infinity, color: Color(0xFFFAAE71)),
        ],
      ),
    );
  }

  // Function to determine the levels for each subject
  List<Map<String, dynamic>> _getLevelsForSubject(String subject) {
    if (subject == "English") {
      return [
        {"title": "Letters", "screen": LetterBTracingScreen()},
        {"title": "Words", "screen": EnglishWordsScreen()},
        {"title": "Sentences", "screen": EnglishSentencesScreen()},
      ];
    } else if (subject == "Arabic") {
      return [
        {"title": "Letters", "screen": Game1ScreenState()},
        {"title": "Words", "screen": ArabicWordsScreen()},
        {"title": "Sentences", "screen": ArabicSentencesScreen()},
      ];
    } else if (subject == "Mathematics") {
      return [
        {"title": "Games", "screen": GamesScreen()},
        {"title": "Math Operations Time", "screen": MathOperationsScreen()},
        {"title": "Number", "screen": NumberGameScreen()},
      ];
    }
    return [];
  }

  Widget _buildLevelOption(BuildContext context, String level, Widget screen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen));
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xFFFED2B5),
          ),
          child: Center(
            child: Text(
              level,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Arabic Screens
class ArabicLettersScreen extends StatelessWidget {
  const ArabicLettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Arabic Letters Level")),
        body: Center(child: Text("Welcome to Arabic Letters Level")));
  }
}

class ArabicWordsScreen extends StatelessWidget {
  const ArabicWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Arabic Words Level")),
        body: Center(child: Text("Welcome to Arabic Words Level")));
  }
}

class ArabicSentencesScreen extends StatelessWidget {
  const ArabicSentencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Arabic Sentences Level")),
        body: Center(child: Text("Welcome to Arabic Sentences Level")));
  }
}

// English Screens
class EnglishLettersScreen extends StatelessWidget {
  const EnglishLettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("English Letters Level")),
        body: Center(child: Text("Welcome to English Letters Level")));
  }
}

class EnglishWordsScreen extends StatelessWidget {
  const EnglishWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("English Words Level")),
        body: Center(child: Text("Welcome to English Words Level")));
  }
}

class EnglishSentencesScreen extends StatelessWidget {
  const EnglishSentencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("English Sentences Level")),
        body: Center(child: Text("Welcome to English Sentences Level")));
  }
}

// Mathematics Screens
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Games Level")),
        body: Center(child: Text("Welcome to Games Level")));
  }
}

class MathOperationsScreen extends StatelessWidget {
  const MathOperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Math Operations Time Level")),
        body: Center(child: Text("Welcome to Math Operations Time Level")));
  }
}

class NumberScreen extends StatelessWidget {
  const NumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Number Level")),
        body: Center(child: Text("Welcome to Number Level")));
  }
}
