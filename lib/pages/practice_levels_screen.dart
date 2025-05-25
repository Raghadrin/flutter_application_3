import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_application_3/letters/arabicLetter/levelOne/sentence_selection_screen.dart';
import 'package:flutter_application_3/letters/arabicLetter/levelOne/sentence_selection_level2_screen.dart';
import 'package:flutter_application_3/letters/arabicLetter/levelOne/sentence_selection_level3_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/sentence_eng_selection_level2_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/sentence_eng_selection_level3_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/sentence_eng_selection_screen.dart';
import 'package:flutter_application_3/math/math/math_level1_screen.dart';
import 'package:flutter_application_3/math/math/math_level2_screen.dart';
import 'package:flutter_application_3/math/math/math_level3_screen.dart';

class PracticeLevelsScreen extends StatelessWidget {
  final String subject;
  const PracticeLevelsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Align(
          //alignment: Alignment.centerLeft,
          child: Text(
            subject,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.075, // Dynamic font size
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.05),
          Image.asset("images/subject_fox.jpg", height: screenHeight * 0.35),
          SizedBox(height: screenHeight * 0.04),
          Text(
            tr("start learning"),
            style: TextStyle(
              color: const Color.fromARGB(255, 48, 47, 47),
              fontSize: screenWidth * 0.06,
              fontFamily: 'Arial',
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          _buildLevelButton(context, tr("Level 1"), screenWidth),
          _buildLevelButton(context, tr("Level 2"), screenWidth),
          _buildLevelButton(context, tr("Level 3"), screenWidth),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLevelButton(
      BuildContext context, String level, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.01,
        horizontal: screenWidth * 0.1,
      ),
      child: GestureDetector(
        onTap: () {
          final isArabic = subject == tr('Arabic');
          final isEnglish = subject == tr('English');
          final isMath = subject == tr('Math');

          if (level == tr("Level 1")) {
            if (isArabic) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ArabicLevel1HomeScreen()),
              );
            } else if (isEnglish) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EnglishLevel1HomeScreen()),
              );
            } else if (isMath) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MathLevel1Screen()),
              );
            }
          } else if (level == tr("Level 2")) {
            if (isArabic) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ArabicLevel2HomeScreen()),
              );
            } else if (isEnglish) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EnglishLevel2HomeScreen()),
              );
            } else if (isMath) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MathLevel2Screen()),
              );
            }
          } else if (level == tr("Level 3")) {
            if (isArabic) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ArabicLevel3HomeScreen()),
              );
            } else if (isEnglish) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EnglishLevel3HomeScreen()),
              );
            } else if (isMath) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MathLevel3Screen()),
              );
            }
          }
        },
        child: Container(
          height: screenWidth * 0.18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFFED2B5),
          ),
          child: Center(
            child: Text(
              level,
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
