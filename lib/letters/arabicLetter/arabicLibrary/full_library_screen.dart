import 'package:flutter/material.dart';
import 'package:flutter_application_3/letters/arabicLetter/arabicLibrary/match_word_sound_screen.dart';
import 'package:flutter_application_3/letters/arabicLetter/arabicLibrary/sen.dart';
import 'choose_word_screen.dart';
import 'missing_letter_screen.dart';
//import 'match_word_sound_screen.dart';
import 'record_word_screen.dart';
import 'Karaoke_Reading_Exercise.dart';
//import 'sen.dart'; // كاريوكي الجمل

class FullLibraryScreen extends StatelessWidget {
  final String title;

  const FullLibraryScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFF1F8E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            ExerciseButton(
              title: '١. ✏️ علامات الترقيم',
              screen: ChoosePunctuationScreen(),
              color: Colors.orangeAccent,
            ),
            ExerciseButton(
              title: '٢. 🌀 الحركات',
              screen: MissingTashkeelScreen(),
              color: Colors.purpleAccent,
            ),
            ExerciseButton(
              title: '٣. 🔊 مطابقة الكلمة بالصوت',
              screen: MatchWordSoundScreen(),
              color: Colors.lightGreen,
            ),
            ExerciseButton(
              title: '٤. ✍️ الهمزات',
              screen: HamzatGameScreen(),
              color: Colors.pinkAccent,
            ),
            ExerciseButton(
              title: '٥. 🎤 كاريوكي القراءة',
              screen: KaraokeReadingScreen(),
              color: Colors.cyan,
            ),
            ExerciseButton(
              title: '٦. 🧩 كاريوكي الجمل',
              screen: ArabicRecordSentenceGame(),
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseButton extends StatelessWidget {
  final String title;
  final Widget screen;
  final Color color;

  const ExerciseButton({
    super.key,
    required this.title,
    required this.screen,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        tileColor: color.withOpacity(0.2),
        title: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }
}
