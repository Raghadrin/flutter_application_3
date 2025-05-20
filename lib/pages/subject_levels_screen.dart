import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/arabicLetter/arabicLibrary/library_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/libeng/library_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/quiz/quiz_all_screen.dart';
import 'package:flutter_application_3/math/library/library_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_application_3/math/quiz/quiz_for_all.dart';
import 'practice_levels_screen.dart';
import '../letters/arabicLetter/quiz/quiz_all_screen.dart';

class SubjectLevelsScreen extends StatelessWidget {
  final String subject;

  const SubjectLevelsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          subject,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Image.asset("images/subject_fox.jpg", height: screenWidth * 0.6),
          const SizedBox(height: 30),
          _buildLevelButton(context, tr('Practice')),
          _buildLevelButton(context, tr('Quiz')),
          _buildLevelButton(context, tr('Library')),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.02,
        horizontal: screenWidth * 0.1,
      ),
      child: GestureDetector(
        onTap: () {
          if (text == tr('Practice')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PracticeLevelsScreen(subject: subject),
              ),
            );
          } else if (text == tr('Quiz')) {
            if (subject == tr('Arabic')) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizAScreen()),
              );
            } else if (subject == tr('Math')) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizForAll()),
              );
            } else if (subject == tr('English')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EnglishComprehensiveQuizScreen()),
              );
            }
          } else if (text == tr('Library')) {
            if (subject == tr('Arabic')) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArabicLibraryScreen()),
              );
            } else if (subject == tr('Math')) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LibraryScreen()),
              );
            } else if (subject == tr('English')) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EnglishLibraryScreen()),
              );
            }
          }
        },
        child: Container(
          height: screenWidth * 0.18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFFFED2B5),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.06,
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
