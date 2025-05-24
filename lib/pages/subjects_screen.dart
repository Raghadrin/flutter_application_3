import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'subject_levels_screen.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

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
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr("Subjects"),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Arial',
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Image.asset(
            "images/subject_fox.jpg",
            height: screenWidth * 0.7,
          ),
          const SizedBox(height: 20),
          Text(
            tr("Choose Subject"),
            style: const TextStyle(
              fontSize: 34,
              color: Color.fromARGB(255, 42, 42, 42),
              fontWeight: FontWeight.w600,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 30),
          _buildSubjectButton(
              context, tr("Arabic"), "images/arabicsubject.png", screenWidth),
          _buildSubjectButton(
              context, tr("English"), "images/englishsubject.png", screenWidth),
          _buildSubjectButton(
              context, tr("Math"), "images/mathsubject.png", screenWidth),
          //const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSubjectButton(
      BuildContext context, String text, String iconPath, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.01,
        horizontal: screenWidth * 0.1,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectLevelsScreen(subject: text),
            ),
          );
        },
        child: Container(
          height: screenWidth * 0.20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFBD1B2), Color(0xFFFEE5D3)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath, height: screenWidth * 0.15),
              const SizedBox(width: 15),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
