import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'subject_levels_screen.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          tr("subjects"),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Arial',
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Image.asset(
            "images/subject_fox.jpg",
            height: 280,
          ),
          const SizedBox(height: 20),
          Text(
            tr("choose subject"), // Add this to your translation files
            style: TextStyle(
              fontSize: 34,
              color: const Color.fromARGB(255, 42, 42, 42),
              fontWeight: FontWeight.w600,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 10),
          _buildSubjectButton(
              context, tr("arabic"), "images/arabicsubject.png"),
          _buildSubjectButton(
              context, tr("english"), "images/englishsubject.png"),
          _buildSubjectButton(context, tr("math"), "images/mathsubject.png"),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSubjectButton(
      BuildContext context, String text, String iconPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
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
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFBD1B2), Color(0xFFFEE5D3)],
            ),
          ),
          child: ListTile(
            leading: Image.asset(iconPath, height: 45),
            title: Text(
              text,
              //textAlign: Alignment.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arial',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
