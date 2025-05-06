import 'package:flutter/material.dart';
import '../../englishLetters/englishLevel2/ChooseWordLearningGame.dart';
import 'reorder_letters_game.dart';
import '../levelOne/drag_word_to_image_game.dart';
import 'record_word_game.dart';
import '../../englishLetters/englishLevel2/color_learning_and_quiz_game.dart';

class ArabicLevel2PracticeScreen extends StatelessWidget {
  const ArabicLevel2PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = [
      "اختر الكلمة للصورة",
      "رتب الحروف لتكوين كلمة",
      "اسحب الكلمة للصورة",
      "سجل الكلمة بعد سماعها",
      "تعلم الألوان",
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "المستوى الثاني - اللغة العربية",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          // Center(child: Image.asset("images/subject_fox.jpg", height: 150)),
          // SizedBox(height: 10),
          Center(
            child: Text(
              "اختر تمرينًا لبدء التعلم",
              style: TextStyle(
                  fontSize: 19.5, color: const Color.fromARGB(255, 91, 88, 88)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return Center(
                    child: _buildExerciseBox(context, exercises[index]));
              },
            ),
          ),
          Container(
              height: 8, width: double.infinity, color: Color(0xFFFAAE71)),
        ],
      ),
    );
  }

  Widget _buildExerciseBox(BuildContext context, String title) {
    return Container(
      width: 320,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFED2B5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Arial'),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          _buildActionButton(context, "تمرين", title),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String type, String title) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Color(0xFFEC5417)),
        ),
      ),
      onPressed: () {
        if (title == "اختر الكلمة للصورة") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChooseWordLearningGame()));
        } else if (title == "رتب الحروف لتكوين كلمة") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReorderLettersGame()));
        } else if (title == "اسحب الكلمة للصورة") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DragWordToImageGame()));
        } else if (title == "سجل الكلمة بعد سماعها") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => RecordWordGame()));
        } else if (title == "تعلم الألوان") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ColorLearningAndQuizGame()));
        }
      },
      child: Text(
        type,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
    );
  }
}
