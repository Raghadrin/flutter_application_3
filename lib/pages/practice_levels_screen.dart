import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_application_3/letters/arabicLetter/ArabicLevel3/arabic_level3_screen.dart';
import 'package:flutter_application_3/letters/arabicLetter/arabicLevel2/arabic_level2_screen.dart';
import 'package:flutter_application_3/letters/arabicLetter/levelOne/arabic_level1_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/english_level1_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/english_level2_screen.dart';
import 'package:flutter_application_3/letters/englishLetters/practice/english_level3_screen.dart';
import 'package:flutter_application_3/math/math/math_level1_screen.dart';
import 'package:flutter_application_3/math/math/math_level2_screen.dart';
import 'package:flutter_application_3/math/math/math_level3_screen.dart';

class PracticeLevelsScreen extends StatelessWidget {
  final String subject;
  const PracticeLevelsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            subject,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Image.asset("images/subject_fox.jpg", height: 280),
          const SizedBox(height: 30),
          Text(
            tr("start learning"),
            style: const TextStyle(
              color: Color.fromARGB(255, 48, 47, 47),
              fontSize: 24,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 15),
          _buildLevelButton(context, tr("level 1")),
          _buildLevelButton(context, tr("level 2")),
          _buildLevelButton(context, tr("level 3")),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
      child: GestureDetector(
        onTap: () {
          final isArabic = subject == tr('arabic');
          final isEnglish = subject == tr('english');
          final isMath = subject == tr('math');

          if (level == tr("level 1")) {
            if (isArabic) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KaraokeSentenceScreen()));
            } else if (isEnglish) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnglishLevel1Screen(),
                ),
              );
            } else if (isMath) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MathLevel1Screen()),
              );
            }
          }

          if (level == tr("level 2")) {
            if (isArabic) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => KaraokeSentenceLevel2Screen()),
              );
            } else if (isEnglish) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EnglishLevel2Screen()),
              );
            } else if (isMath) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MathLevel2Screen()),
              );
            }
          }

          if (level == tr("level 3")) {
            if (isEnglish) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EnglishLevel3Screen()),
              );
            } else if (isMath) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MathLevel3Screen()),
              );
            } else if (isArabic) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => KaraokeSentenceLevel3Screen()),
              );
            }
          }
        },
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFFED2B5),
          ),
          child: Center(
            child: Text(
              level,
              style: const TextStyle(
                fontSize: 22,
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
